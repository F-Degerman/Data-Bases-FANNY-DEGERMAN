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

UPDATE SuccessfulMissions
SET Spacecraft = LEFT(Spacecraft, CHARINDEX('(', Spacecraft) - 1)
WHERE Spacecraft LIKE '%(%';

GO

SELECT DISTINCT Spacecraft
FROM SuccessfulMissions
ORDER BY Spacecraft;