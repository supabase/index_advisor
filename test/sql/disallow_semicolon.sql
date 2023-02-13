begin;

    create extension index_advisor;

    select optimal_indexes($$ select 1; $$);

rollback;
