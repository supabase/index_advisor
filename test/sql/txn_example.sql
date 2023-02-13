create extension if not exists hypopg;
select hypopg_reset();

drop table if exists public.book;

create table public.book(id int, name text);

begin;

    select hypopg_create_index('create index on public.book(id)');

    explain select * from public.book where id = 1;

commit;


explain select * from public.book where id = 1;

select hypopg_reset();
