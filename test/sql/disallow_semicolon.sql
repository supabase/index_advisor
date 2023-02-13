begin;

    create extension index_advisor;

    select index_advisor($$ select 1; $$);

rollback;
