USE everyloop;

DROP TABLE IF EXISTS SuccessfulMissions; 
-- successful moon missions
SELECT 
    Spacecraft,
    [Launch date],
    [Carrier rocket],
    Operator,
    [Mission type]
INTO SuccessfulMissions
FROM MoonMissions
WHERE Outcome = 'Successful';

--- Visar de 10 första raderna i tabellen SuccessfulMissions 
--- för att verifiera att data har överförts korrekt.
SELECT TOP 10 * 
FROM SuccessfulMissions;

GO

--- Tar bort eventuella mellanslag i början eller slutet av Operator-kolumnen. 
UPDATE SuccessfulMissions
SET Operator = TRIM(Operator);

--- DISTINCT för att få unika värden. Genom ORDER BY sorteras dessa alfabetiskt, 
--- vilket gör att vi lätt kan se om mellanslag har tagits bort eller inte.
SELECT DISTINCT Operator
FROM SuccessfulMissions
ORDER BY Operator; 

GO

--- Tar bort eventuella parenteser och text inom parentes i Spacecraft-kolumnen.
--- Samt TRIM för att ta bort eventuella mellanslag som kan finnas kvar efter 
--- att parenteser tagits bort.
UPDATE SuccessfulMissions
SET Spacecraft = TRIM(LEFT(Spacecraft, CHARINDEX('(', Spacecraft) - 1))
WHERE Spacecraft LIKE '%(%';

--- DISTINCT för att få unika värden. Genom ORDER BY sorteras dessa alfabetiskt,
--- vilket gör att vi lätt kan se om parenteser har tagits bort eller inte.
SELECT DISTINCT Spacecraft
FROM SuccessfulMissions
ORDER BY Spacecraft;

GO 

--- Gruppindelning av antalet framgångsrika uppdrag per operatör och uppdragstyp. 
--- HAVING COUNT(*) > 1 används för att endast inkludera grupper där det finns mer än ett uppdrag. 
SELECT
    Operator,
    [Mission type],
    COUNT(*) AS [Mission count]
FROM SuccessfulMissions
GROUP BY
    Operator,
    [Mission type]
HAVING COUNT(*) > 1
ORDER BY
    Operator,
    [Mission type]; 

GO

--- USERS
DROP TABLE IF EXISTS NewUsers;

--- Skapar en ny tabell NewUsers där vi kombinerar förnamn och efternamn till en namnkolumn,
--- samt använder en CASE-sats för kön baserat på det näst sista tecknet i ID-kolumnen.
SELECT
    Id,
    Username,
    Password, 
    FirstName + ' ' + LastName AS Name,
    Email,
    Phone,
    CASE
        WHEN SUBSTRING(ID, LEN(ID) - 1, 1) % 2 = 0
            THEN 'Female'
        ELSE 'Male'
    END AS Gender
INTO NewUsers
FROM Users;

--- verifierar att den nya tabellen NewUsers har skapats korrekt
SELECT TOP 10 * FROM NewUsers;

GO

--- Gruppindelning av användarnamn och räkning av dubbletter. 
--- HAVING COUNT(*) > 1 för att endast inkludera användarnamn som har dubbletter. 
SELECT
    Username,
    COUNT(*) AS [Duplicate count]
FROM NewUsers
GROUP BY Username
HAVING COUNT(*) > 1;

GO

--- Uppdaterar användarnamn för specifika ID:n för att åtgärda dubbletter.
UPDATE NewUsers SET Username = 'felb£r' WHERE Id = '880706-3713';
UPDATE NewUsers SET Username = 's1gpet' WHERE Id = '580802-4175';
UPDATE NewUsers SET Username = 'sigp£t' WHERE Id = '630303-4894';


--- Visa de uppdaterade användarnamnen för tydlighet
SELECT Id, Username
FROM NewUsers
WHERE Id IN ('880706-3713', '580802-4175', '630303-4894')
ORDER BY Id;

GO

--- kollar så dubletterna har åtgärdats 
SELECT
    Username,
    COUNT(*) AS [Duplicate count]
FROM NewUsers
GROUP BY Username
HAVING COUNT(*) > 1;

GO

--- Tar bort alla kvinnor födda innan 1970.
DELETE FROM NewUsers
WHERE (LEFT(Id, 2)) < '70' AND Gender = 'Female';

--- kollar så att alla kvinnor innan 1970 har tagits bort
SELECT *
FROM NewUsers
WHERE Gender = 'Female'
ORDER BY Id DESC;

GO

--- Lägger till en ny användare i tabellen NewUsers. 
INSERT INTO NewUsers (
    Id, 
    Username, 
    Password, 
    Name, 
    Email, 
    Phone, 
    Gender
    )
VALUES (
    '990101-1234', 
    'test01', 
    'testingpassword1234', 
    'Test Person', 
    'test01@example.com', 
    '123456789', 
    'Male'
    );

--- Kollar så att den nya användaren har lagts till korrekt.
SELECT *
FROM NewUsers
WHERE Name = 'Test Person';

GO

--- Beräknar den genomsnittliga åldern för användare i tabellen NewUsers, 
--- grupperat efter kön. lägger till århundrade, sedan DATEDIFF för att 
--- räkna ut åldern baserat på födelsedatum och dagens datum (GETDATE).
SELECT
    Gender,
    FLOOR(AVG(
        DATEDIFF(YEAR, 
            CONVERT(date, '19' + LEFT(Id, 6)),
            GETDATE()
        )
    )) AS [Average age]
FROM NewUsers
GROUP BY Gender;

GO

--- COMPANY (JOINS)

--- Visar en lista över produkter tillsammans med deras leverantörsnamn och kategorinamn.
SELECT
    p.Id,
    p.ProductName AS Product,
    s.CompanyName AS Supplier,
    c.CategoryName AS Category
FROM company.products p
JOIN company.suppliers s
    ON p.SupplierId = s.Id
JOIN company.categories c
    ON p.CategoryId = c.Id;

GO

--- Visar en lista över regioner tillsammans med 
--- antalet anställda som är verksamma i varje region.
--- Då Employee Id och Region Id inte finns i samma tabell, 
--- krävs flera JOINs för att koppla ihop tabellerna Employees, 
--- EmployeeTerritories, Territories och Regions.
--- DESTINCT används för att räkna unika anställda, 
--- eftersom en anställd kan vara verksam i flera regioner.
SELECT
    r.RegionDescription AS Region,
    COUNT(DISTINCT e.Id) AS [Employee count]
FROM company.regions r
JOIN company.territories t
    ON r.Id = t.RegionId
JOIN company.employee_territory et
    ON t.Id = et.TerritoryId
JOIN company.employees e
    ON et.EmployeeId = e.Id
GROUP BY r.RegionDescription;

GO

--- Joinar tabellen Employees med sig själv för att visa varje anställds namn 
--- tillsammans med namnet på den person de rapporterar till.
SELECT
    e.Id,
    CONCAT(e.TitleOfCourtesy, ' ', e.FirstName, ' ', e.LastName) AS Name,
    CASE
        WHEN e.ReportsTo IS NULL THEN 'Nobody!'
        ELSE CONCAT(m.TitleOfCourtesy, ' ', m.FirstName, ' ', m.LastName)
    END AS [Reports to]
FROM company.employees e
LEFT JOIN company.employees m
    ON e.ReportsTo = m.Id;

GO