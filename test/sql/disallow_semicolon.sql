begin;

    create extension index_advisor version '0.1.1' cascade;

    select index_advisor($$ select 1; $$);

rollback;
