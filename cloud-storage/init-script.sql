CREATE TABLE heroes (
	hero_id serial PRIMARY KEY,
	name VARCHAR ( 100 ) UNIQUE NOT NULL
);

insert into heroes (name) 
values 
    ('Wolverine'),
    ('Captain America'),
    ('Iron Man'),
    ('Hulk'),
    ('Black Widow'),
    ('Black Panther'),
    ('Winter Soldier'),
    ('Spiderman'),
    ('War Machine'),
    ('Ant Man');