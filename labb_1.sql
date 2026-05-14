USE everyloop;

--- översikt över vilka tabeller som finns i databasen. 
SELECT name
FROM sys.tables
ORDER BY name;

--- MOONMISSIONS
SELECT TOP 10 * FROM MoonMissions;

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

GO

--- Visar de 10 första raderna i tabellen SuccessfulMissions 
--- för att verifiera att data har överförts korrekt.
SELECT TOP 10 * 
FROM SuccessfulMissions;

GO

--- Tar bort eventuella mellanslag i början eller slutet av Operator-kolumnen. 
UPDATE SuccessfulMissions
SET Operator = TRIM(Operator);

GO

--- DISTINCT för att få unika värden. Genom ORDER BY sorteras dessa alfabetiskt, 
--- vilket gör att vi lätt kan se om mellanslag har tagits bort eller inte.
SELECT DISTINCT Operator
FROM SuccessfulMissions
ORDER BY Operator; 

GO

--- Tar bort eventuella parenteser och text inom parentes i Spacecraft-kolumnen.
UPDATE SuccessfulMissions
SET Spacecraft = LEFT(Spacecraft, CHARINDEX('(', Spacecraft) - 1)
WHERE Spacecraft LIKE '%(%';

GO

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

SELECT TOP 10 * FROM Users;

--- Skapar en ny tabell NewUsers där vi kombinerar förnamn och efternamn till en fullständig namnkolumn,
--- samt använder en CASE-sats för att bestämma kön baserat på det näst sista tecknet i ID-kolumnen.

DROP TABLE IF EXISTS NewUsers;
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

--- Visar användares ID som inte har unika användarnamn. 
SELECT *
FROM NewUsers
WHERE Username IN (
    SELECT Username
    FROM NewUsers
    GROUP BY Username
    HAVING COUNT(*) > 1
)
ORDER BY Username; 

--- Visar datatyp och maxlängd för kolumnen Username i tabellen NewUsers. 
--- (visar i detta fall navchar, vilket innebär att många olika tecken kan användas,
--- och maxlängd 6).  
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NewUsers'
  AND COLUMN_NAME = 'Username';

--- Uppdaterar användarnamn för specifika ID:n för att åtgärda dubbletter.
UPDATE NewUsers SET Username = 'felb£r' WHERE Id = '880706-3713';
UPDATE NewUsers SET Username = 's1gpet' WHERE Id = '580802-4175';
UPDATE NewUsers SET Username = 'sigp£t' WHERE Id = '630303-4894';

--- kollar om dubbletterna har åtgärdats
SELECT *
FROM NewUsers
WHERE Username IN (
    SELECT Username
    FROM NewUsers
    GROUP BY Username
    HAVING COUNT(*) > 1
)
ORDER BY Username;

GO 

--- Visar alla kvinnliga användare vars ID börjar med ett nummer mellan 26 och 69.
--- spannet 26-69 är valt eftersom personnumret endast består av tiotal, 
--- får anta att personer födda ex 20 är födda 2020. 
--- (istället för ex WHERE BirthDate < '1970-01-01')
SELECT *
FROM NewUsers
WHERE Gender = 'Female'
AND LEFT(Id, 2) BETWEEN '26' AND '69';  

--- tar bort alla kvinnor inom det angivna spannet
DELETE FROM NewUsers
WHERE Gender = 'Female'
AND (
    LEFT(Id, 2) BETWEEN '26' AND '69'
);

--- kollar så att alla kvinnor inom det angivna spannet har tagits bort
SELECT *
FROM NewUsers
WHERE Gender = 'Female'
AND LEFT(Id, 2) BETWEEN '26' AND '69'; 

GO

SELECT TOP 10 * FROM NewUsers;

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
            CASE 
                WHEN LEFT(Id, 2) BETWEEN '00' AND '25'
                    THEN CONVERT(date, '20' + LEFT(Id, 6))
                ELSE CONVERT(date, '19' + LEFT(Id, 6))
            END,
            GETDATE()
        )
    )) AS [Average age]
FROM NewUsers
GROUP BY Gender;

GO

--- COMPANY (JOINS)

SELECT TOP 10 * FROM company.products;

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

--- Kollar vilka tabeller som finns i company.
SELECT
    t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name = 'company'
ORDER BY t.name;

--- kollar vilka kolumner som finns i tabellerna för att se hur de hänger ihop. 
SELECT TOP 10 * FROM company.employees;
SELECT TOP 10 * FROM company.regions;


--- Då employees och regions inte är direkt kopplade kollar jag 
--- foreign keys för att se tabellernas relation till varandra.
SELECT
    OBJECT_NAME(fk.parent_object_id) AS [From Table],
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS [From Column],
    OBJECT_NAME(fk.referenced_object_id) AS [→ To Table],
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS [→ To Column]
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) IN 
    ('employees', 'employee_territory', 'territories', 'regions')
ORDER BY [From Table];
--- visar relationen mellan tabellerna: 
--- employees.Id = employee_territory.EmployeeId -> 
--- employee_territory.TerritoryId = territories.Id -> 
--- territories.RegionId = regions.Id -> 
--- Och då kan vi koppla company.regions till employee.Id (regions.RegionDescription)

--- Kollar även på tabellerna employee_territory och territories. 
SELECT TOP 10 * FROM company.employee_territory;
SELECT TOP 10 * FROM company.territories;


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

--- översikt över tabellen och dess kolumner
SELECT TOP 10 * FROM company.employees;

--- väljer de kolumner som är relevanta utifrån uppgiften för att förstå hierarkin i företaget. 
SELECT 
    Id,
    Title, 
    FirstName, 
    LastName,
    ReportsTo
FROM company.employees;

--- 
SELECT
    e.Id,
    CONCAT(e.Title, ' ', e.FirstName, ' ', e.LastName) AS Name,
    CASE
        WHEN e.ReportsTo IS NULL THEN 'Nobody!'
        ELSE CONCAT(m.Title, ' ', m.FirstName, ' ', m.LastName)
    END AS [Reports to]
FROM company.employees e
LEFT JOIN company.employees m
    ON e.ReportsTo = m.Id;

GO
