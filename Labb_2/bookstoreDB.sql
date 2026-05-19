
-- CREATE DATABASE BookStoreDB;
-- GO

USE BookStoreDB;
GO

-- Återsställer tabellerna (om de redan körts tidigare)
DELETE FROM OrderRows;
DELETE FROM Orders;
DELETE FROM Inventory;
DELETE FROM BookAuthors;
DELETE FROM Books;
DELETE FROM Customers;
DELETE FROM Stores;
DELETE FROM Publishers;
DELETE FROM Authors;

-- återställer identity-seed för tabellerna så att nya rader börjar på 1 igen 
-- (vid körning av skriptet flera gånger) 
DBCC CHECKIDENT ('Authors', RESEED, 0);
DBCC CHECKIDENT ('Publishers', RESEED, 0);
DBCC CHECKIDENT ('Stores', RESEED, 0);
DBCC CHECKIDENT ('Customers', RESEED, 0);
DBCC CHECKIDENT ('Books', RESEED, 0);
DBCC CHECKIDENT ('Inventory', RESEED, 0);
DBCC CHECKIDENT ('Orders', RESEED, 0);
DBCC CHECKIDENT ('OrderRows', RESEED, 0);

GO

/* =====================================================
    AUTHORS
===================================================== */

-- Skapar "Authors"-Tabellen.
-- AuthorID är auto-genererad som primärnyckel.
CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    BirthDate DATE NULL
);

-- Lägger till data i "Authors"-Tabellen.
INSERT INTO Authors (FirstName, LastName, BirthDate)
VALUES
('Astrid', 'Lindgren', '1907-11-14'),
('George', 'Orwell', '1903-06-25'),
('J.K.', 'Rowling', '1965-07-31'),
('Tove', 'Jansson', '1914-08-09');

SELECT *
FROM Authors 

GO

/* =====================================================
    PUBLISHERS
===================================================== */

-- Skapar "Publishers"-Tabellen. 
-- PublisherID är auto-genererad som primärnyckel.
CREATE TABLE Publishers (
    PublisherID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Country NVARCHAR(50) NULL
);

-- Lägger till data i "Publishers"-Tabellen.
INSERT INTO Publishers (Name, Country)
VALUES
('Penguin Books', 'United Kingdom'),
('Rabén & Sjögren', 'Sweden');

SELECT *
FROM Publishers

GO

/* =====================================================
    STORES
===================================================== */

-- Skapar "Stores" -Tabellen.
-- StoreID är auto-genererad som primärnyckel.
CREATE TABLE Stores (
    StoreID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL
);

-- Lägger till data i "Stores"-Tabellen.
INSERT INTO Stores (Name, Address)
VALUES
('Bokhörnan Stockholm', 'Drottninggatan 12, Stockholm'),
('Bokhörnan Göteborg', 'Avenyn 8, Göteborg'),
('Bokhörnan Malmö', 'Södra Förstadsgatan 22, Malmö');

SELECT *
FROM Stores

GO

/* =====================================================
    CUSTOMERS
===================================================== */

-- Skapar "Customers" -Tabellen.
-- CustomerID är auto-genererad som primärnyckel
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE
);

-- Lägger till data i "Customers"-Tabellen.
INSERT INTO Customers (FirstName, LastName, Email)
VALUES
('Anna', 'Svensson', 'anna.svensson@email.com'),
('Erik', 'Johansson', 'erik.johansson@email.com'),
('Maja', 'Karlsson', 'maja.karlsson@email.com');

SELECT *
FROM Customers

GO

/* =====================================================
    BOOKS
===================================================== */

-- Skapar "Books" -Tabellen.
-- ISBN13 används som primärnyckel.
-- PublisherID är en sekundärnyckel som refererar till Publishers-tabellen.
CREATE TABLE Books (
    ISBN13 CHAR(13) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Language NVARCHAR(50) NOT NULL, 
    PublisherID INT NOT NULL,
    PublicationDate DATE NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID)
);

-- Lägger till data i "Books"-Tabellen.
INSERT INTO Books (ISBN13, Title, Language, PublisherID, PublicationDate, Price)
VALUES
('9789129688313', 'Bröderna Lejonhjärta', 'Swedish', 2, '1973-01-01', 129.00),
('9789129697056', 'Ronja Rövardotter', 'Swedish', 2, '1981-01-01', 139.00),
('9780451524935', '1984', 'English', 1, '1949-06-08', 149.00),
('9780141036144', 'Animal Farm', 'English', 1, '1945-08-17', 119.00),
('9780747532699', 'Harry Potter and the Philosopher''s Stone', 'English', 1, '1997-06-26', 159.00),
('9789129707298', 'Mumintrollet', 'Swedish', 2, '1945-01-01', 129.00),
('9789129715613', 'Pippi Långstrump', 'Swedish', 2, '1945-01-01', 119.00),
('9789129723946', 'Emil i Lönneberga', 'Swedish', 2, '1963-01-01', 129.00),
('9780141187761', 'Down and Out in Paris and London', 'English', 1, '1933-01-09', 139.00),
('9789129740424', 'Trollkarlens hatt', 'Swedish', 2, '1948-01-01', 119.00);

SELECT *
FROM Books

GO

/* =====================================================
    BookAuthors 
===================================================== */

-- Skapar "BookAuthors" -Tabellen som kopplar böcker till författare. 
-- ISBN13 och AuthorID tillsammans utgör den sammansatta primärnyckeln.
-- ISBN13 är en sekundärnyckel som refererar till Books-tabellen.
-- AuthorID är en sekundärnyckel som refererar till Authors-tabellen.
CREATE TABLE BookAuthors (
    ISBN13 CHAR(13) NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (ISBN13, AuthorID),
    FOREIGN KEY (ISBN13) REFERENCES Books(ISBN13),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- Lägger till data i "BookAuthors"-Tabellen.
INSERT INTO BookAuthors (ISBN13, AuthorID)
VALUES
('9789129688313', 1),
('9789129697056', 1),
('9780451524935', 2),
('9780141036144', 2),
('9780747532699', 3),
('9789129707298', 4),
('9789129715613', 1),
('9789129723946', 1),
('9780141187761', 2),
('9789129740424', 4);

SELECT *
FROM BookAuthors

GO

/* =====================================================
    Inventory
===================================================== */

-- Skapar "Inventory"-Tabellen som kopplar butiker till böcker.
-- StoreID och ISBN13 tillsammans utgör den sammansatta primärnyckeln.
-- StoreID är en sekundärnyckel som refererar till Stores-tabellen.
-- ISBN13 är en sekundärnyckel som refererar till Books-tabellen.
CREATE TABLE Inventory (
    StoreID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Quantity INT NOT NULL,
    PRIMARY KEY (StoreID, ISBN13),
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID),
    FOREIGN KEY (ISBN13) REFERENCES Books(ISBN13)
);

-- Lägger till data i "Inventory"-Tabellen.
INSERT INTO Inventory (StoreID, ISBN13, Quantity)
VALUES
(1, '9789129688313', 5),
(1, '9780451524935', 8),
(1, '9780747532699', 4),
(2, '9789129697056', 6),
(2, '9780141036144', 7),
(2, '9789129715613', 10),
(3, '9789129707298', 3),
(3, '9789129723946', 5),
(3, '9780141187761', 2),
(3, '9789129740424', 6);  

SELECT *
FROM Inventory

GO

/* =====================================================
    Orders
===================================================== */

-- Skapar "Orders"-Tabellen som kopplar kunder till butiker och orderdatum.
-- OrderID är auto-genererad som primärnyckel.
-- CustomerID är en sekundärnyckel som refererar till Customers-tabellen.
-- StoreID är en sekundärnyckel som refererar till Stores-tabellen.
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    StoreID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID)
);

-- Lägger till data i "Orders"-Tabellen.
INSERT INTO Orders (CustomerID, StoreID, OrderDate)
VALUES
(1, 1, '2026-05-01'),
(2, 2, '2026-05-02'),
(3, 3, '2026-05-03');

SELECT *
FROM Orders

GO

/* =====================================================
    OrderRows
===================================================== */

-- Skapar "OrderRows"-Tabellen som kopplar order till böcker och kvantitet.
-- OrderRowID är auto-genererad som primärnyckel.
-- OrderID är en sekundärnyckel som refererar till Orders-tabellen.
-- ISBN13 är en sekundärnyckel som refererar till Books-tabellen.
CREATE TABLE OrderRows (
    OrderRowID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ISBN13) REFERENCES Books(ISBN13)
);

-- Lägger till data i "OrderRows"-Tabellen.
INSERT INTO OrderRows (OrderID, ISBN13, Quantity, UnitPrice)
VALUES
(1, '9789129688313', 1, 129.00),
(1, '9780451524935', 2, 149.00),
(2, '9780141036144', 1, 119.00),
(3, '9789129707298', 1, 129.00);

SELECT *
FROM OrderRows

GO

/* =====================================================
    TESTING 
===================================================== */

-- Testar att tabellerna skapats korrekt och att data lagts in som förväntat.
SELECT * FROM INFORMATION_SCHEMA.TABLES;

GO

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

GO

/* =====================================================
    TESTING AV RELATIONER
===================================================== */

-- Kollar så att relationerna mellan tabellerna fungerar som de ska 
-- genom att göra några JOINs.

-- Inventory, Books och Stores
SELECT 
    b.Title,
    s.Name AS Store,
    i.Quantity
FROM Inventory i
JOIN Books b ON i.ISBN13 = b.ISBN13
JOIN Stores s ON i.StoreID = s.StoreID;

GO

-- Books och Publishers
SELECT *
FROM Books
JOIN Publishers ON Books.PublisherID = Publishers.PublisherID;

GO

-- BookAuthors, Books och Authors
SELECT 
    b.Title,
    a.FirstName,
    a.LastName
FROM BookAuthors ba
JOIN Books b ON ba.ISBN13 = b.ISBN13
JOIN Authors a ON ba.AuthorID = a.AuthorID;

GO

-- Orders, Customers och Stores
SELECT 
    o.OrderID,
    c.FirstName,
    c.LastName,
    s.Name AS Store,
    o.OrderDate
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Stores s ON o.StoreID = s.StoreID;

GO

-- OrderRows, Orders och Books
SELECT 
    o.OrderID,
    b.Title,
    orw.Quantity,
    orw.UnitPrice
FROM OrderRows orw
JOIN Orders o ON orw.OrderID = o.OrderID
JOIN Books b ON orw.ISBN13 = b.ISBN13;

GO

  