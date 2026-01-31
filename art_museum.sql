-- Nayha Rehman
-- Himaal Ishaq
-- Simon Ryabinkin

DROP DATABASE IF EXISTS art_museum;
CREATE DATABASE art_museum;
USE art_museum;

-- ----------------------------------------------------------
-- TABLES

CREATE TABLE ARTIST (
    Name                VARCHAR(100) PRIMARY KEY,
    Date_born           DATE NULL,
    Date_died           DATE NULL,
    Country_of_origin   VARCHAR(100),
    Epoch               VARCHAR(100),
    Main_style          VARCHAR(100),
    Description         TEXT
);

CREATE TABLE ART_OBJECT (
    Id_no       INT PRIMARY KEY,
    Artist      VARCHAR(100),
    Year        INT,
    Title       VARCHAR(200),
    Description TEXT,
    Origin      VARCHAR(100),
    Epoch       VARCHAR(100),
    CONSTRAINT fk_artobject_artist FOREIGN KEY (Artist) REFERENCES ARTIST(Name) ON DELETE CASCADE
);

CREATE TABLE COLLECTIONS (
    Name            VARCHAR(100) PRIMARY KEY,
    Type            VARCHAR(100),
    Description     TEXT,
    Address         VARCHAR(200),
    Phone           VARCHAR(20),
    Contact_person  VARCHAR(100)
);

CREATE TABLE EXHIBITION (
    Name        VARCHAR(100) PRIMARY KEY,
    Start_date  DATE,
    End_date    DATE
);

CREATE TABLE PAINTING (
    Id_no       INT PRIMARY KEY,
    Paint_type  VARCHAR(100),
    Drawn_on    VARCHAR(100),
    Style       VARCHAR(100),
    CONSTRAINT fk_painting_artobject FOREIGN KEY (Id_no) REFERENCES ART_OBJECT(Id_no) ON DELETE CASCADE
);

CREATE TABLE STATUE (
    Id_no       INT PRIMARY KEY,
    Material    VARCHAR(100),
    Height      DECIMAL(8,2),
    Weight      DECIMAL(8,2),
    Style       VARCHAR(100),
    CONSTRAINT fk_statue_artobject FOREIGN KEY (Id_no) REFERENCES ART_OBJECT(Id_no) ON DELETE CASCADE
);

CREATE TABLE SCULPTURE (
    Id_no       INT PRIMARY KEY,
    Material    VARCHAR(100),
    Height      DECIMAL(8,2),
    Weight      DECIMAL(8,2),
    Style       VARCHAR(100),
    CONSTRAINT fk_sculpture_artobject FOREIGN KEY (Id_no) REFERENCES ART_OBJECT(Id_no) ON DELETE CASCADE
);

CREATE TABLE OTHER (
    Id_no       INT PRIMARY KEY,
    Type        VARCHAR(100),
    Style       VARCHAR(100),
    CONSTRAINT fk_other_art FOREIGN KEY (Id_no) REFERENCES ART_OBJECT(Id_no) ON DELETE CASCADE
);

CREATE TABLE EXHIBITION_ITEMS (
    Exhibition_name VARCHAR(100),
    Art_id          INT,
    PRIMARY KEY (Exhibition_name, Art_id),
    CONSTRAINT fk_exitems_exhibition FOREIGN KEY (Exhibition_name) REFERENCES EXHIBITION(Name) ON DELETE CASCADE,
    CONSTRAINT fk_exitems_art FOREIGN KEY (Art_id) REFERENCES ART_OBJECT(Id_no) ON DELETE CASCADE
);

CREATE TABLE BORROWED (
    Id_no           INT PRIMARY KEY,
    Collection_name VARCHAR(100),
    Date_borrowed   DATE,
    Date_returned   DATE,
    CONSTRAINT fk_borrow_artobject FOREIGN KEY (Id_no) REFERENCES ART_OBJECT(Id_no) ON DELETE CASCADE,
    CONSTRAINT fk_borrow_collection FOREIGN KEY (Collection_name) REFERENCES COLLECTIONS(Name) ON DELETE CASCADE
);

CREATE TABLE PERMANENT_COLLECTION (
    Id_no           INT PRIMARY KEY,
    Date_acquired   DATE,
    Status          VARCHAR(50),
    Cost            DECIMAL(12,2),
    CONSTRAINT fk_perm_artobject FOREIGN KEY (Id_no) REFERENCES ART_OBJECT(Id_no) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- SAMPLE DATA

INSERT INTO ARTIST (Name, Date_born, Date_died, Country_of_origin, Epoch, Main_style, Description)
VALUES
('Hans Holbein the Younger', '1497-01-01', '1543-11-01', 'Germany', 'Northern Renaissance', 'Portraiture', 'A Swiss-German painter known for his splendid portraits of the Tudor court'),
('William Michael Harnett', '1848-08-10', '1892-10-29', 'United States/Ireland', '19th Century', 'Still life', 'An Irish/American painter known to paint realistic still lifes'),
('Dave (David Drake)', NULL, NULL, 'United States', '19th Century', 'Stoneware Pottery', 'An enslaved African American from Edgefield known to make and inscribe jars/vessels'),
('Leonardo da Vinci', '1452-04-15', '1519-05-02', 'Italy', 'High Renaissance', 'Painting', 'An Italian Renaissance painter, best known for his work of the Mona Lisa');

INSERT INTO ART_OBJECT (Id_no, Artist, Year, Title, Description, Origin, Epoch)
VALUES
(1, 'Hans Holbein the Younger', 1532, 'Hermann von Wedigh III (died 1560)', 'Renaissance portrait of a Cologne official holding a book', 'Germany', 'Renaissance'),
(2, 'William Michael Harnett', 1888, 'Still life - Violin and Music', 'Realistic portrait of a violin and sheet music hanging from a door', 'United States', '19th century'),
(3, 'Dave (David Drake)', 1585, 'Storage jar', 'Large pottery jar with a hand written message carved on it', 'United States', '19th century American'),
(4, 'Leonardo da Vinci', 1503, 'Portrait de Lisa Gherardini (La Jaconde)', 'A portrait of Lisa Gherardini, famously known as Mona Lisa, with her mysterious smile', 'Italy', 'High Renaissance');

INSERT INTO COLLECTIONS (Name, Type, Description, Address, Phone, Contact_person)
VALUES
('The Metropolitan Museum of Art', 'Art Museum', 'Prestigious art museum in New York that organized the Tudors, Cubism, and Edgefield exhibitions', '1000 Fifth Ave. New York, NY 10028', '212-535-7710', NULL),
('Musee du Louvre', 'Art Museum', 'The famous museum in Paris which holds the well-known Mona Lisa portrait', 'Rue de Rivoli, 75001 Paris, France', NULL, NULL);

INSERT INTO EXHIBITION (Name, Start_date, End_date)
VALUES
('The Tudors: Art and Majesty in Renaissance England', '2022-10-10', '2023-01-08'),
('Cubism and the Trompe l''Oeil Tradition', '2022-10-20', '2023-01-22'),
('Hear Me Now: The Black Potters of Old Edgefield, South Carolina', '2022-09-09', '2023-02-05');

INSERT INTO PAINTING (Id_no, Paint_type, Drawn_on, Style)
VALUES
(1, 'Oil and gold', 'Oak panel', 'Renaissance portrait'),
(2, 'Oil', 'Canvas', 'Trompe-l''oeil still life'),
(4, 'Oil', 'Poplar panel', 'High Renaissance portrait');

INSERT INTO OTHER (Id_no, Type, Style)
VALUES
(3, 'Stoneware storage jar', 'Edgefield alkaline-glazed pottery');

INSERT INTO EXHIBITION_ITEMS (Exhibition_name, Art_id)
VALUES
('The Tudors: Art and Majesty in Renaissance England', 1),
('Cubism and the Trompe l''Oeil Tradition', 2),
('Hear Me Now: The Black Potters of Old Edgefield, South Carolina', 3);

INSERT INTO BORROWED (Id_no, Collection_name, Date_borrowed, Date_returned)
VALUES
(1, 'The Metropolitan Museum of Art', '2024-01-15', NULL),
(2, 'The Metropolitan Museum of Art', '2024-01-15', NULL),
(3, 'The Metropolitan Museum of Art', '2024-01-15', NULL),
(4, 'Musee du Louvre', '2024-01-15', NULL);

-- ----------------------------------------------------------
-- TRIGGERS

-- 1. Automatically mark borrowed art as returned when inserted into permanent collection
CREATE TRIGGER borrowed_auto_return 
BEFORE INSERT ON PERMANENT_COLLECTION 
FOR EACH ROW
UPDATE BORROWED 
SET Date_returned = CURDATE() 
WHERE Id_no = NEW.Id_no AND Date_returned IS NULL;

-- 2. Set default cost to 0 if NULL
CREATE TRIGGER perm_collection_default_cost
BEFORE INSERT ON PERMANENT_COLLECTION
FOR EACH ROW
SET NEW.Cost = IFNULL(NEW.Cost, 0);

-- 3. Set default end date to 1 year after start date if NULL
CREATE TRIGGER exhibition_default_end
BEFORE INSERT ON EXHIBITION
FOR EACH ROW
SET NEW.End_date = IFNULL(NEW.End_date, DATE_ADD(NEW.Start_date, INTERVAL 1 YEAR));
