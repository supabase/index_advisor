# Index Advisor

A PostgreSQL extension for recommending indexes to improve query performance.

Features:
- Supports generic parameters e.g. `$1`, `$2`
- Supports materialized views
- Identifies tables/columns obfuscaed by views


## API

### index_advisor(query text) returns table( index_statement text )

#### Description
For a given *query*, searches for a set of SQL DDL `create index` statements that improve the query's execution time;

#### Signature
```sql
index_advisor(
    query text
)
    returns table( index_statement text )
    volatile
    language plpgsql
```

## Usage

For a minimal example, the `index_advisor` function can be given a single table query with a filter on an unindexed column.

```sql
create extension if not exists index_advisor cascade;

create table if not exists public.book(
    id int,
    name text
);

select
    index_advisor($$ select * from book where id = $1 $$);

                index_advisor
----------------------------------------------
 CREATE INDEX ON public.book USING btree (id)
```

More complex queries may generate additional suggested indexes

```sql
create extension if not exists index_advisor cascade;

create table author(
    id serial primary key,
    name text not null
);

create table publisher(
    id serial primary key,
    name text not null,
    corporate_address text
);

create table book(
    id serial primary key,
    author_id int not null references author(id),
    publisher_id int not null references publisher(id),
    title text
);

create table review(
    id serial primary key,
    book_id int references book(id),
    body text not null
);

select
    index_advisor('
        select
            book.id,
            book.title,
            publisher.name as publisher_name,
            author.name as author_name,
            review.body review_body
        from
            book
            join publisher
                on book.publisher_id = publisher.id
            join author
                on book.author_id = author.id
            join review
                on book.id = review.book_id
        where
            author.id = $1
            and publisher.id = $2
    ');

                     index_advisor
--------------------------------------------------------
 CREATE INDEX ON public.review USING btree (book_id)
 CREATE INDEX ON public.book USING btree (author_id)
 CREATE INDEX ON public.book USING btree (publisher_id)
(3 rows)
```


## Install

Requires Postgres with [hypopg](https://github.com/HypoPG/hypopg) installed.

```sh
git clone https://github.com/supabase/index_advisor.git
cd index_advisor
sudo make install
```

## Run Tests

```sh
make install; make installcheck
```
