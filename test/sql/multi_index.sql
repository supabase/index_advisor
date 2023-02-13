begin;

    create extension index_advisor;

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

rollback;
