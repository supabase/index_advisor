begin;

    -- Simulates a project that installed index_advisor at its very first
    -- version and later runs ALTER EXTENSION ... UPDATE (e.g. during a
    -- Postgres major-version upgrade, or a manual extension update) -
    -- exercises the full 0.1.0 -> 0.1.1 -> 0.1.2 -> default_version upgrade
    -- chain end to end, including the 0.1.2->default_version return-type
    -- change (drop + recreate), not just a fresh install pinned at one
    -- version.
    create extension index_advisor version '0.1.0' cascade;

    alter extension index_advisor update;

    select extversion from pg_extension where extname = 'index_advisor';

    create table public.book(
        id int
    );

    select index_advisor($$
        select * from book where id = $1
    $$);

rollback;
