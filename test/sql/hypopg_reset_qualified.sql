begin;

    -- hypopg installed outside the caller's search_path (e.g. Supabase installs
    -- it into a separate "extensions" schema). Versions through 0.2.0 call
    -- hypopg_reset() unqualified, which fails to resolve in this setup with
    -- "function hypopg_reset() does not exist".
    create schema ext;
    create extension hypopg with schema ext;
    create extension index_advisor version '0.2.1';

    set local search_path = public;

    create table public.book(
        id int
    );

    select index_advisor($$
        select * from book where id = $1
    $$);

rollback;
