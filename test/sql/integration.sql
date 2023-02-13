begin;

    create extension index_advisor cascade;

    create table if not exists public.book(id int, name text);

    select optimal_indexes($$ select * from book where id = $1 $$);

rollback;
