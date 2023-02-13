drop extension if exists index_advisor;
create extension index_advisor;

select
    optimal_indexes($$ select 1; $$);
