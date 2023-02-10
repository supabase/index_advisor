create function optimal_indexes(query text)
    returns table(create_statement text)
    volatile
    language plpgsql
    as $$
declare
    i int;
begin

    return query select ('create index abc as ...;');

end;
$$;



