drop extension if exists index_advisor;
create extension index_advisor;


create table public.abc(id int, name text);

insert into public.abc(id, name)
select id, id::text from generate_series(1, 150000) id;


select
    optimal_indexes($$ select * from public.abc where id = $1 $$);


select * from hypopg();


explain select * from abc where id =1 ;
