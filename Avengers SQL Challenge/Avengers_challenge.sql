CREATE DATABASE avengers;
USE avengers;
SHOW TABLES;
    
SELECT * FROM Characters;
		
SELECT * FROM Locations;

SELECT * FROM Events;
    
SELECT * FROM Relationships;

SELECT * FROM Monsters;

-- Retrieve the names of the characters?
SELECT name FROM Characters;

-- Find characters with age greater than 18?
SELECT name AS character_name FROM Characters WHERE age > 18;

-- Find events in Season 2?
SELECT event_name FROM Events WHERE season = 2;

-- Get details of the 'Mind Flayer' monster?
SELECT * FROM Monsters WHERE name = 'Mind Flayer';

-- Calculate the total number of characters from each hometown?
SELECT hometown,COUNT(name) AS number_of_characters FROM Characters GROUP BY hometown;

-- Find the top 3 oldest characters?
SELECT name, age FROM Characters ORDER BY age DESC LIMIT 3;

-- Find the average age of characters in Hawkins?
SELECT ROUND(AVG(age)) AS avg_age FROM Characters WHERE hometown='Hawkins';

-- Rank characters by age in descending order?
SELECT name, age, RANK() OVER(ORDER BY age DESC) FROM Characters;
