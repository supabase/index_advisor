begin;

    -- The comment-stripping regex was greedy across /* */ pairs, so a query
    -- with two or more separate block comments had everything between the
    -- first "/*" and the last "*/" deleted - including real code - with no
    -- error raised. Confirms a query with two block comments still returns
    -- a real index recommendation, not a mangled/empty one.
    create extension index_advisor cascade;

    create table public.book(
        id int
    );

    select index_advisor($$
        select /* first comment */ id /* second comment */ from book where id = $1
    $$);

rollback;
