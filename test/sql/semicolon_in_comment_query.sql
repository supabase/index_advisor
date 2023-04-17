begin;
    -- Semicolons should be allowed in comments because they are common in prep stmts
    create extension index_advisor version '0.2.0' cascade;

    create table public.book(
        id int,
        name text
    );

    select index_advisor($$
        -- some comment with a semicolon;
        select * from book where id = $1
    $$);

rollback;
