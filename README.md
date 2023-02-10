# Index Advisor

A PostgreSQL extension for recommending indexes to improve query performance.

## Install

Requires Postgres with [hypopg](https://github.com/HypoPG/hypopg) installed. 

```sh
git clone https://github.com/supabase/index_advisor.git
cd index_advisor
sudo make install
```

## Run Tests

```sh
PGHOST=localhost make install; PGHOST=localhost make installcheck 
```

