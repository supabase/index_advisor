begin;

    create extension index_advisor cascade;

    select index_advisor($$ select 1; $$);

rollback;
