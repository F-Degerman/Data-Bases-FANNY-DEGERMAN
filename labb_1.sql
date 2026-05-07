USE everyloop;

--- MOONMISSIONS
SELECT TOP 10 * FROM MoonMissions;

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