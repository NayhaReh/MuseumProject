-- Nayha Rehman
-- Himaal Ishaq
-- Simon Ryabinkin

USE art_museum;

-- ----------------------------------------------------------
-- 1: Show all tables and explain relationships
SHOW TABLES;
SHOW CREATE TABLE ART_OBJECT;
SHOW CREATE TABLE PAINTING;
SHOW CREATE TABLE STATUE;
SHOW CREATE TABLE SCULPTURE;
SHOW CREATE TABLE OTHER;
SHOW CREATE TABLE BORROWED;
SHOW CREATE TABLE COLLECTIONS;
SHOW CREATE TABLE EXHIBITION;
SHOW CREATE TABLE EXHIBITION_ITEMS;
SHOW CREATE TABLE ARTIST;
SHOW CREATE TABLE PERMANENT_COLLECTION;

-- Explanation of the relationships between tables:
-- 1. ART_OBJECT is the main (parent) table containing general info about all art objects.
-- 2. PAINTING, STATUE, SCULPTURE, OTHER are subtype tables referencing ART_OBJECT(Id_no) via foreign key.
--      It enforces one-to-one relationship between parent and subtype tables.
-- 3. COLLECTIONS and ARTIST are independent entity tables storing collection and artist info.
-- 4. BORROWED links ART_OBJECT with COLLECTIONS to track borrowed art objects.
-- 5. EXHIBITION_ITEMS links ART_OBJECT with EXHIBITION in a many-to-many relationship.
-- 6. PERMANENT_COLLECTION stores art objects that belong permanently to the museum.
-- 7. Triggers:
--      borrowed_auto_return: automatically marks a borrowed art object as returned when it is inserted into PERMANENT_COLLECTION
--      perm_collection_default_cost: sets the Cost to 0 if no value is provided when inserting into PERMANENT_COLLECTION
--      exhibition_default_end: sets the End_date of an exhibition to 1 year after Start_date if End_date is NULL


-- ----------------------------------------------------------
-- 2: Basic retrieval query
SELECT Id_no, Title, Artist, Year, Origin, Epoch
FROM ART_OBJECT;

-- ----------------------------------------------------------
-- 3: Retrieval query with ordered results
SELECT Id_no, Title, Artist, Year, Origin, Epoch
FROM ART_OBJECT
ORDER BY Year ASC;

-- ----------------------------------------------------------
-- 4: Nested retrieval query
SELECT Id_no, Title, Artist, Year, Origin, Epoch
FROM ART_OBJECT
WHERE Id_no IN (
    SELECT Art_id
    FROM EXHIBITION_ITEMS
);

-- ----------------------------------------------------------
-- 5: Retrieval query using joined tables
SELECT 
    e.Name AS Exhibition_Name, 
    e.Start_date, 
    e.End_date, 
    ao.Id_no AS Art_ID, 
    ao.Title AS Art_Title, 
    ao.Artist AS Artist_Name, 
    ao.Year AS Art_Year
FROM EXHIBITION_ITEMS ei
JOIN EXHIBITION e ON ei.Exhibition_name = e.Name
JOIN ART_OBJECT ao ON ei.Art_id = ao.Id_no
ORDER BY e.Name, ao.Year;

-- ----------------------------------------------------------
-- 6: Update operation with trigger
-- This trigger prevents invalid exhibition date updates by enforcing Start_date ≤ End_date

DELIMITER $$

DROP TRIGGER IF EXISTS trg_exhibition_date_check$$
CREATE TRIGGER trg_exhibition_date_check
BEFORE UPDATE ON EXHIBITION
FOR EACH ROW
BEGIN
    IF NEW.Start_date IS NOT NULL AND NEW.End_date IS NOT NULL
       AND NEW.Start_date > NEW.End_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'INVALID: Start_date cannot be later than End_date';
    END IF;
END$$

DELIMITER ;

UPDATE EXHIBITION
SET End_date = '2023-01-01'
WHERE Name = 'The Tudors: Art and Majesty in Renaissance England';

-- Verify update
SELECT Name, Start_date, End_date
FROM EXHIBITION
WHERE Name = 'The Tudors: Art and Majesty in Renaissance England';

-- Invalid update blocked by trigger
UPDATE EXHIBITION
SET End_date = '2020-01-01'
WHERE Name = 'The Tudors: Art and Majesty in Renaissance England';

-- ----------------------------------------------------------
-- 7: Deletion operation with proper explanation

-- Check if the exhibition exists
SELECT * 
FROM EXHIBITION
WHERE Name = 'Cubism and the Trompe l''Oeil Tradition';

-- Check associated items in EXHIBITION_ITEMS
SELECT * 
FROM EXHIBITION_ITEMS
WHERE Exhibition_name = 'Cubism and the Trompe l''Oeil Tradition';

-- Delete the exhibition
DELETE FROM EXHIBITION
WHERE Name = 'Cubism and the Trompe l''Oeil Tradition';

-- Verify deletion in EXHIBITION
SELECT * 
FROM EXHIBITION
WHERE Name = 'Cubism and the Trompe l''Oeil Tradition';

-- Verify deletion in EXHIBITION_ITEMS
SELECT * 
FROM EXHIBITION_ITEMS
WHERE Exhibition_name = 'Cubism and the Trompe l''Oeil Tradition';

-- Confirm count of deleted items
SELECT COUNT(*) AS Deleted_Items
FROM EXHIBITION_ITEMS
WHERE Exhibition_name = 'Cubism and the Trompe l''Oeil Tradition';