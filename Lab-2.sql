CREATE TABLE movies
(
    movie_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    title VARCHAR(200) NOT NULL,

    release_year INTEGER NOT NULL
        CHECK (release_year BETWEEN 1900 AND 2100),

    duration_minutes INTEGER
        CHECK (duration_minutes > 0),

    country VARCHAR(100),

    language VARCHAR(100),

    budget NUMERIC(15,2)
        CHECK (budget >= 0),

    revenue NUMERIC(15,2)
        CHECK (revenue >= 0),

    created_at TIMESTAMP
        DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE movies IS
'Stores basic movie information';
CREATE TABLE persons
(
    person_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    person_name VARCHAR(150) NOT NULL,

    birth_date DATE,

    country VARCHAR(100)
);
CREATE TABLE genres
(
    genre_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    genre_name VARCHAR(50)
        UNIQUE NOT NULL
);
CREATE TABLE movie_genres
(
    movie_id BIGINT NOT NULL,

    genre_id BIGINT NOT NULL,

    PRIMARY KEY (movie_id, genre_id),

    CONSTRAINT fk_movie_genre_movie

        FOREIGN KEY (movie_id)

        REFERENCES movies(movie_id)

        ON DELETE CASCADE,

    CONSTRAINT fk_movie_genre_genre

        FOREIGN KEY (genre_id)

        REFERENCES genres(genre_id)

        ON DELETE CASCADE
);
CREATE TABLE movie_cast
(
    movie_id BIGINT NOT NULL,

    person_id BIGINT NOT NULL,

    character_name VARCHAR(150),

    billing_order INTEGER,

    PRIMARY KEY (movie_id, person_id),

    CONSTRAINT fk_cast_movie

        FOREIGN KEY (movie_id)

        REFERENCES movies(movie_id)

        ON DELETE CASCADE,

    CONSTRAINT fk_cast_person

        FOREIGN KEY (person_id)

        REFERENCES persons(person_id)

        ON DELETE CASCADE
);
CREATE TABLE movie_directors
(
    movie_id BIGINT NOT NULL,

    person_id BIGINT NOT NULL,

    PRIMARY KEY (movie_id, person_id),

    CONSTRAINT fk_director_movie

        FOREIGN KEY (movie_id)

        REFERENCES movies(movie_id)

        ON DELETE CASCADE,

    CONSTRAINT fk_director_person

        FOREIGN KEY (person_id)

        REFERENCES persons(person_id)

        ON DELETE CASCADE
);
CREATE TABLE ratings
(
    movie_id BIGINT PRIMARY KEY,

    average_rating NUMERIC(3,1)

        CHECK (average_rating BETWEEN 0 AND 10),

    total_votes INTEGER

        CHECK (total_votes >= 0),

    CONSTRAINT fk_rating_movie

        FOREIGN KEY (movie_id)

        REFERENCES movies(movie_id)

        ON DELETE CASCADE
);
INSERT INTO genres (genre_name)

VALUES

('Action'),
('Drama'),
('Comedy'),
('Science Fiction'),
('Thriller'),
('Crime'),
('Adventure');
INSERT INTO persons
(person_name, birth_date, country)

VALUES

('Christopher Nolan','1970-07-30','UK'),

('Leonardo DiCaprio','1974-11-11','USA'),

('Christian Bale','1974-01-30','UK'),

('Robert Downey Jr','1965-04-04','USA'),

('Morgan Freeman','1937-06-01','USA'),

('Steven Spielberg','1946-12-18','USA'),

('Tom Hanks','1956-07-09','USA'),

('James Cameron','1954-08-16','Canada'),

('Kate Winslet','1975-10-05','UK'),

('Matthew McConaughey','1969-11-04','USA');
INSERT INTO movies
(title, release_year, duration_minutes,
 country, language, budget, revenue)

VALUES

('Inception',2010,148,'USA','English',
160000000,836000000),

('The Dark Knight',2008,152,'USA','English',
185000000,1005000000),

('Interstellar',2014,169,'USA','English',
165000000,731000000),

('Titanic',1997,195,'USA','English',
200000000,2264000000),

('Avatar',2009,162,'USA','English',
237000000,2923000000),

('Forrest Gump',1994,142,'USA','English',
55000000,678000000),

('Saving Private Ryan',1998,169,'USA','English',
70000000,482000000),

('The Prestige',2006,130,'USA','English',
40000000,109000000),

('Dunkirk',2017,106,'UK','English',
100000000,527000000),

('Tenet',2020,150,'USA','English',
205000000,365000000);
INSERT INTO ratings
(movie_id, average_rating, total_votes)

VALUES

(1,8.8,2500000),

(2,9.0,2900000),

(3,8.7,2100000),

(4,7.9,1300000),

(5,7.9,1400000),

(6,8.8,2200000),

(7,8.6,1500000),

(8,8.5,1400000),

(9,7.8,750000),

(10,7.3,600000);
INSERT INTO movie_genres
(movie_id, genre_id)

VALUES

(1,1),
(1,4),
(1,5),

(2,1),
(2,6),

(3,2),
(3,4),
(3,7),

(4,2),

(5,1),
(5,4),
(5,7),

(6,2),
(6,3),

(7,2),
(7,1),

(8,2),
(8,5),

(9,1),
(9,2),

(10,1),
(10,4);
INSERT INTO movie_directors
(movie_id, person_id)

VALUES

(1,1),
(2,1),
(3,1),
(4,8),
(5,8),
(6,6),
(7,6),
(8,1),
(9,1),
(10,1);
INSERT INTO movie_cast
(movie_id, person_id, character_name, billing_order)

VALUES

(1,2,'Cobb',1),
(1,5,'Professor',2),

(2,3,'Bruce Wayne',1),
(2,5,'Lucius Fox',2),

(3,10,'Cooper',1),

(4,2,'Jack Dawson',1),
(4,9,'Rose',2),

(6,7,'Forrest Gump',1),

(7,7,'Captain Miller',1),

(8,3,'Alfred Borden',1),

(9,3,'Soldier',1),

(10,2,'Protagonist',1);
SELECT *

FROM movies;
SELECT
    title,
    release_year

FROM movies

WHERE release_year > 2010

ORDER BY release_year;
SELECT
    m.title,
    r.average_rating

FROM movies m

JOIN ratings r
ON m.movie_id = r.movie_id

WHERE r.average_rating > 8.5

ORDER BY r.average_rating DESC;
SELECT
    m.title,
    g.genre_name

FROM movies m

JOIN movie_genres mg
ON m.movie_id = mg.movie_id

JOIN genres g
ON mg.genre_id = g.genre_id

ORDER BY m.title;
SELECT
    g.genre_name,

    COUNT(mg.movie_id) AS movie_count

FROM genres g

LEFT JOIN movie_genres mg
ON g.genre_id = mg.genre_id

GROUP BY
    g.genre_id,
    g.genre_name

ORDER BY movie_count DESC;
SELECT
    g.genre_name,

    ROUND(AVG(r.average_rating),2)
        AS average_genre_rating

FROM genres g

JOIN movie_genres mg
ON g.genre_id = mg.genre_id

JOIN ratings r
ON mg.movie_id = r.movie_id

GROUP BY
    g.genre_id,
    g.genre_name

ORDER BY average_genre_rating DESC;
