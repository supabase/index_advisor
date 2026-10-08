begin;

    -- index_advisor used to call bare "deallocate all", which wipes every
    -- prepared statement in the session - not just its own internal one.
    -- In a pooled/persistent connection (PostgREST, pgbouncer session mode)
    -- this silently breaks whatever else that connection had prepared.
    -- Confirms an unrelated prepared statement survives a call.
    create extension index_advisor cascade;

    create table public.book(
        id int
    );

    prepare unrelated_statement as select 1;

    select index_advisor($$
        select * from book where id = $1
    $$);

    select name from pg_prepared_statements where name = 'unrelated_statement';

rollback;
