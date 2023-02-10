create extension index_advisor;

select
    optimal_indexes($$ select 1 $$);
