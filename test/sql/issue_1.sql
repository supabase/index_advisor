begin;

    create extension index_advisor version '0.1.1' cascade;

    create table public.book(
        id int,
        -- json type is not btree indexable. In version 0.1.1 this raises the error
        -- ERROR:  data type json has no default operator class for access method "btree"
        meta json
    );

    select index_advisor($$
        select * from book where id = $1
    $$);

rollback;
