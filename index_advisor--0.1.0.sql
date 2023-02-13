create function index_advisor(
    query text
)
    returns table( index_statement text )
    volatile
    language plpgsql
    as $$
declare
    n_args int;
    prepared_statement_name text = 'index_advisor_working_statement';
    hypopg_schema_name text = (select extnamespace::regnamespace::text from pg_extension where extname = 'hypopg');
    explain_plan_statement text;
    rec record;
    plan_initial jsonb;
    plan_final jsonb;
    statements text[] = '{}';
begin

        -- Disallow multiple statements
        if query ilike '%;%' then
            raise exception 'query must not contain a semicolon';
        end if;

        -- Create a prepared statement for the given query
        execute format('prepare %I as %s', prepared_statement_name, query);

        -- Detect how many arguments are present in the prepared statement
        n_args = (
            select
                coalesce(array_length(parameter_types, 1), 0)
            from
                pg_prepared_statements
            where
                name = prepared_statement_name
            limit
                1
        );

        -- Create a SQL statement that can be executed to collect the explain plan
        explain_plan_statement = format(
            'set local plan_cache_mode = force_generic_plan; explain (format json) execute %I%s',
            --'explain (format json) execute %I%s',
            prepared_statement_name,
            case
                when n_args = 0 then ''
                else format(
                    '(%s)', array_to_string(array_fill('null'::text, array[n_args]), ',')
                )
            end
        );

        -- Store the query plan before any new indexes
        execute explain_plan_statement into plan_initial;

        -- Create possible indexes
        for rec in (
            with extension_regclass as (
                select
                    distinct objid as oid
                from
                    pg_depend
                where
                    deptype = 'e'
            )
            select
                pc.relnamespace::regnamespace::text as schema_name,
                pc.relname as table_name,
                pa.attname as column_name,
                format(
                    'select %I.hypopg_create_index($i$create index on %I.%I(%I)$i$)',
                    hypopg_schema_name,
                    pc.relnamespace::regnamespace::text,
                    pc.relname,
                    pa.attname
                ) hypopg_statement
            from
                pg_catalog.pg_class pc
                join pg_catalog.pg_attribute pa
                    on pc.oid = pa.attrelid
                left join extension_regclass er
                    on pc.oid = er.oid
                left join pg_index pi
                    on pc.oid = pi.indrelid
                    and (select array_agg(x) from unnest(pi.indkey) v(x)) = array[pa.attnum]
                    and pi.indexprs is null -- ignore expression indexes
                    and pi.indpred is null -- ignore partial indexes
            where
                pc.relnamespace::regnamespace::text not in ( -- ignore schema list
                    'pg_catalog', 'pg_toast', 'information_schema'
                )
                and er.oid is null -- ignore entities owned by extensions
                and pc.relkind in ('r', 'm') -- regular tables, and materialized views
                and pc.relpersistence = 'p' -- permanent tables (not unlogged or temporary)
                and pa.attnum > 0
                and not pa.attisdropped
                and pi.indrelid is null
            )
            loop
                -- Create the hypothetical index
                execute rec.hypopg_statement;
            end loop;

    /*
    for rec in select * from hypopg()
        loop
            raise notice '%', rec;
        end loop;
    */

    -- Create a prepared statement for the given query
    -- The original prepared statement MUST be dropped because its plan is cached
    execute format('deallocate %I', prepared_statement_name);
    execute format('prepare %I as %s', prepared_statement_name, query);

    -- Store the query plan after new indexes
    execute explain_plan_statement into plan_final;

    --raise notice '%', plan_final;

    -- Idenfity referenced indexes in new plan
    execute format(
        'select
            coalesce(array_agg(hypopg_get_indexdef(indexrelid) order by indrelid, indkey::text), $i${}$i$::text[])
        from
            %I.hypopg()
        where
            %s ilike ($i$%%$i$ || indexname || $i$%%$i$)
        ',
        hypopg_schema_name,
        quote_literal(plan_final)::text
    ) into statements;

    -- Reset all hypothetical indexes
    perform hypopg_reset();
    -- Delete the prepared statement
    perform format('deallocate %I', prepared_statement_name);

    return query select * from unnest(statements);

end;
$$;
