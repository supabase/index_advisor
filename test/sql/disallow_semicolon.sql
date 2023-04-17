begin;

    create extension index_advisor version '0.2.0' cascade;

    -- This is okay because semicolon gets stripped from the end of the statement
    select * from index_advisor($$ select 1; $$);

    -- This is not okay because it contains multiple statements
    select * from index_advisor($$ select 1; select 1 $$);

rollback;
