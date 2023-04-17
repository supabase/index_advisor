begin;
    -- Semicolons should be allowed in comments because they are common in prep stmts
    create extension index_advisor version '0.2.0' cascade;

    select * from index_advisor(
      'SELECT concat(schemaname, $1, tablename, $2, policyname) as policy
        FROM   pg_policies
        ORDER  BY 1 desc'
    );

rollback;
