


-- CREATE DATABASE BookStoreDB;
-- GO

USE BookStoreDB;

/* ============================================================
    Procedurer för omkörning av hela skriptet i ett svep
============================================================ */
DROP PROCEDURE IF EXISTS TransferBookStock;

GO

-- återsställer användare och behörigheter (om de redan körts tidigare)
DROP USER IF EXISTS BookStorePythonUser;

GO

-- master databasen används för att hantera serverlogins, 
-- så vi måste byta till den innan vi kan ta bort login.
USE master;

GO

-- Kollar om login "BookStorePythonUser" finns och tar bort det om det gör det,
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'BookStorePythonUser')
BEGIN
    DROP LOGIN BookStorePythonUser;
END;

GO

USE BookStoreDB;

GO

-- Återsställer tabellerna och vyerna (om de redan körts tidigare)
DROP VIEW IF EXISTS AuthorStatistics;
DROP VIEW IF EXISTS CustomerOrderSummary;
DROP VIEW IF EXISTS BookSearchView; 
DROP VIEW IF EXISTS BestSellingBooks;

GO

DROP TABLE IF EXISTS OrderRows;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS BookAuthors;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Stores;
DROP TABLE IF EXISTS Publishers;
DROP TABLE IF EXISTS Authors;

GO

/* ============================================================
    Grundtabeller (kärnentiteter med 1NF) och deras data    
============================================================ */

/* -------------------- AUTHORS -------------------- */
-- Skapar "Authors"-Tabellen.
-- AuthorID är auto-genererad som primary key.
CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    BirthDate DATE NULL,
    DeathDate DATE NULL
);

-- Lägger till data i "Authors"-Tabellen.
INSERT INTO Authors (FirstName, LastName, BirthDate, DeathDate)
VALUES
('Astrid', 'Lindgren', '1907-11-14', '2002-01-28'),
('George', 'Orwell', '1903-06-25', '1950-01-21'),
('J.K.', 'Rowling', '1965-07-31', NULL),
('Tove', 'Jansson', '1914-08-09', '2001-06-27');

SELECT *
FROM Authors 

GO

/* -------------------- PUBLISHERS -------------------- */
-- Skapar "Publishers"-Tabellen. 
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

/* -------------------- STORES -------------------- */
-- Skapar "Stores" -Tabellen.
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

/* -------------------- CUSTOMERS -------------------- */
-- Skapar "Customers" -Tabellen.
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

/* -------------------- BOOKS -------------------- */
-- Skapar "Books" -Tabellen.
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

/* ============================================================
    Transaktions-/lagerhanteringstabeller (hanterar lager och beställningar)  
============================================================ */

/* -------------------- Inventory -------------------- */
-- Skapar "Inventory"-Tabellen som kopplar butiker till böcker.
-- StoreID och ISBN13 tillsammans utgör sammansatt primary key.
CREATE TABLE Inventory (
    StoreID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity >= 0),
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

/* -------------------- Orders -------------------- */

-- Skapar "Orders"-Tabellen som kopplar kunder till butiker och orderdatum.
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

/* -------------------- OrderRows -------------------- */
-- Skapar "OrderRows"-Tabellen som kopplar order till böcker och kvantitet.
-- OrderRowID är auto-genererad som primary key.
CREATE TABLE OrderRows (
    OrderRowID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
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

/* ============================================================
    Junction-/kopplingstabell (many-to-many relationer) 
============================================================ */

/* -------------------- BookAuthors -------------------- */

-- Skapar "BookAuthors" -Tabellen som kopplar böcker till författare. 
-- ISBN13 och AuthorID tillsammans utgör den sammansatta primary key.
-- ISBN13 är en foreign key som refererar till Books-tabellen.
-- AuthorID är en foreign key som refererar till Authors-tabellen.
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

/* ============================================================
    Vyer
============================================================ */

  /* -------------------- VY: AuthorStatistics (TitlarPerFörfattare) -------------------- */
  -- Denna vy sammanfattar statistik om författare, inklusive deras namn, ålder (eller livslängd), 
  -- antal titlar de har skrivit och det totala värdet av deras böcker i lager.
CREATE VIEW AuthorStatistics AS
SELECT
    CONCAT(a.FirstName, ' ', a.LastName) AS AuthorName,

    CONCAT(
        DATEDIFF(YEAR, a.BirthDate, ISNULL(a.DeathDate, GETDATE())) -
        CASE 
            WHEN DATEADD(
                YEAR, 
                DATEDIFF(YEAR, a.BirthDate, ISNULL(a.DeathDate, GETDATE())), 
                a.BirthDate
            ) > ISNULL(a.DeathDate, GETDATE())
            THEN 1 
            ELSE 0 
        END,
        ' år'
    ) AS Age,

    CONCAT(COUNT(DISTINCT b.ISBN13), ' st') AS Titles,

    CONCAT(SUM(b.Price * i.Quantity), ' kr') AS InventoryValue

FROM Authors a
JOIN BookAuthors ba ON a.AuthorID = ba.AuthorID
JOIN Books b ON ba.ISBN13 = b.ISBN13
JOIN Inventory i ON b.ISBN13 = i.ISBN13
GROUP BY 
    a.AuthorID,
    a.FirstName,
    a.LastName,
    a.BirthDate,
    a.DeathDate;

GO

SELECT *
FROM AuthorStatistics;

GO

 /* -------------------- VY: CustomerOrderSummary -------------------- */
 -- Denna vy sammanfattar kundernas beställningar, inklusive antal beställningar, totalt antal böcker köpta och total spenderad summa.
 -- Den används för att snabbt få en översikt över kundernas köpbeteende och kan vara användbar för marknadsföring och kundanalys.
CREATE VIEW CustomerOrderSummary AS
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
    SUM(orw.Quantity) AS TotalBooksBought,
    SUM(orw.Quantity * orw.UnitPrice) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderRows orw ON o.OrderID = orw.OrderID
GROUP BY 
    c.CustomerID,
    c.FirstName,
    c.LastName;

GO

SELECT *
FROM CustomerOrderSummary;

GO

/* -------------------- VY: BookSearchView -------------------- */
-- Denna vy används i app.py för att söka efter böcker baserat på titel.
CREATE VIEW BookSearchView AS
SELECT
    b.Title,
    b.ISBN13,
    s.Name AS Store,
    i.Quantity
FROM Books b
JOIN Inventory i ON b.ISBN13 = i.ISBN13
JOIN Stores s ON i.StoreID = s.StoreID;

GO

SELECT *
FROM BookSearchView 

GO

/* ============================================================
    Användare och behörigheter
============================================================ */

-- Skapar en SQL Server login och user för att ge åtkomst till databasen,
-- med specifika behörigheter att läsa från BookSearchView, vilket används i app.py.
CREATE LOGIN BookStorePythonUser
WITH PASSWORD = 'StrongPassword123!';

GO

CREATE USER BookStorePythonUser
FOR LOGIN BookStorePythonUser;

GO

GRANT SELECT ON BookSearchView TO BookStorePythonUser;

GO

/* ============================================================
    Stored Procedures
============================================================ */

/* -------------------- SP: TransferBookStock -------------------- */
   -- Denna stored procedure flyttar ett antal exemplar av en bok 
   -- från en butik till en annan. Den hanterar även fel som kan uppstå,
   -- t.ex. om det inte finns tillräckligt med böcker i källbutiken eller 
   -- om butikerna är desamma.

CREATE PROCEDURE TransferBookStock
    @FromStoreID INT,
    @ToStoreID INT,
    @ISBN13 CHAR(13),
    @Quantity INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Quantity <= 0
            THROW 50001, 'Quantity must be greater than 0.', 1;

        IF @FromStoreID = @ToStoreID
            THROW 50002, 'FromStoreID and ToStoreID cannot be the same.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM Inventory
            WHERE StoreID = @FromStoreID
              AND ISBN13 = @ISBN13
              AND Quantity >= @Quantity
        )
            THROW 50003, 'Not enough books in source store.', 1;

        UPDATE Inventory
        SET Quantity = Quantity - @Quantity
        WHERE StoreID = @FromStoreID
          AND ISBN13 = @ISBN13;

        IF EXISTS (
            SELECT 1
            FROM Inventory
            WHERE StoreID = @ToStoreID
              AND ISBN13 = @ISBN13
        )
        BEGIN
            UPDATE Inventory
            SET Quantity = Quantity + @Quantity
            WHERE StoreID = @ToStoreID
              AND ISBN13 = @ISBN13;
        END
        ELSE
        BEGIN
            INSERT INTO Inventory (StoreID, ISBN13, Quantity)
            VALUES (@ToStoreID, @ISBN13, @Quantity);
        END

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;

GO  


/* ============================================================
    TESTING
============================================================ */

-- Testar centrala relationer, vyer och stored procedure.

/* -------------------- Inventory, Books och Stores -------------------- */
SELECT 
    b.Title,
    s.Name AS Store,
    i.Quantity
FROM Inventory i
JOIN Books b ON i.ISBN13 = b.ISBN13
JOIN Stores s ON i.StoreID = s.StoreID;

GO

/* -------------------- BookAuthors, Books och Authors -------------------- */
SELECT 
    b.Title,
    a.FirstName,
    a.LastName
FROM BookAuthors ba
JOIN Books b ON ba.ISBN13 = b.ISBN13
JOIN Authors a ON ba.AuthorID = a.AuthorID;

GO

/* -------------------- Orders, Customers och OrderRows -------------------- */
SELECT 
    o.OrderID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    b.Title,
    orw.Quantity,
    orw.UnitPrice
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderRows orw ON o.OrderID = orw.OrderID
JOIN Books b ON orw.ISBN13 = b.ISBN13;

GO

/* -------------------- View: AuthorStatistics -------------------- */
SELECT *
FROM AuthorStatistics;

GO

/* -------------------- View: CustomerOrderSummary -------------------- */
SELECT *
FROM CustomerOrderSummary;

GO

/* -------------------- View: BookSearchView -------------------- */
SELECT *
FROM BookSearchView;

GO

/* -------------------- Stored Procedure: TransferBookStock -------------------- */
EXEC TransferBookStock 
    @FromStoreID = 1,
    @ToStoreID = 2,
    @ISBN13 = '9780451524935',
    @Quantity = 2;

GO

SELECT *
FROM Inventory
WHERE ISBN13 = '9780451524935';

GO
