use Company
go

--    Query 1
-- Write a query that returns the names of
-- All employees that work in department 5 and work more than 10 hours per week on the ProductX project.
SELECT E.*
FROM dbo.Employee E
    JOIN dbo.Works_on Wo on E.SSN = Wo.Essn
    JOIN dbo.Project P on P.PNumber = Wo.Pno
WHERE Dno = 5
  AND Wo.Hours > 10
  AND P.PName = 'ProductX'
    -- Any alternative ways of doing the query?
    -- What's expensive in this query?
    -- Can you make it more efficient?

--    Query 2
-- List
-- All employees that have a dependent with the same first name as themselves.
SELECT E.*
FROM dbo.Employee E
    JOIN dbo.Dependent D on E.SSN = D.Essn
WHERE Dependent_Name LIKE E.FName + '%'
    -- What's expensive in this query?
    -- Can you make it more efficient?
    -- Does this have any real world applications?

--    Query 3
-- Find
-- All employees that are directly supervised by Franklin Wong.
SELECT E.*
FROM dbo.Employee E
JOIN dbo.Employee Supervisor ON E.SuperSSN = Supervisor.SSN
WHERE Supervisor.FName = 'Franklin' AND Supervisor.LName = 'Wong'
    -- What changes if we want to find all employees that are supervised by `Franklin Wong` (directly or indirectly)?
    -- What relations change if we change `Franklin Wong` to e.g. `Jane Doe`?
    -- The same change above, but in a NoSQL database?

--    Query 4
-- For each project, list
-- The project name and the total hours per week (by all employees) spent on that project.
SELECT P.PName, SUM(Wo.Hours)
FROM Project P
LEFT JOIN dbo.Works_on Wo on P.PNumber = Wo.Pno
GROUP BY P.PName
    -- What's expensive in this query?
    -- Can you make it more efficient?

--    Query 5
-- Retreive the names of
-- All employees who work on every project.
SELECT E.FName, E.LName
FROM dbo.Employee E
    JOIN dbo.Works_on Wo ON E.SSN = Wo.Essn
GROUP BY E.SSN, E.FName, E.LName
HAVING COUNT(DISTINCT Wo.Pno) = (SELECT COUNT(*) FROM dbo.Project);
    -- How does this query scale with the number of projects?
    -- How can the query be made more efficient?

--    Query 6
-- Retreive the names of
-- All employees who do not work on any project.
SELECT E.FName, E.LName
FROM dbo.Employee E
    LEFT JOIN dbo.Works_on Wo on E.SSN = Wo.Essn
WHERE Wo.Pno IS NULL
    -- Is your query optimal?
    -- How does this query scale with the number of projects?

--    Query 7
-- For each department
-- Retrieve the department name and the average salary of all employees working in that department.
SELECT D.DName, AVG(E.Salary)
FROM Department D
LEFT JOIN dbo.Employee E on E.Dno = D.DNumber
group by D.DName
    -- How expensive is calculating the average salary?
    -- How does this query scale with the number of employees?
    -- How does this query scale with the number of departments?

--    Query 8
-- Retrieve the average salary of all female employees
SELECT AVG(E.Salary)
FROM Employee E
WHERE E.Sex = 'F'

--    Query 9
-- Find the name and address of all Employee who work on at least one project located in Houston but whose controlling department has no location in Houston.
SELECT DISTINCT E.FName, E.LName, E.Address
FROM Employee E
JOIN dbo.Works_on Wo on E.SSN = Wo.Essn
JOIN dbo.Project P on Wo.Pno = P.PNumber
JOIN dbo.Department D on E.Dno = D.DNumber
JOIN dbo.Dept_Locations DL on D.DNumber = DL.DNUmber
WHERE P.PLocation = 'Houston' AND DL.DLocation != 'Houston'
    -- What's expensive in this query?

--    Query 10
--List the Lname of all Employee who have no dependents
SELECT E.LName
FROM Employee E
LEFT JOIN dbo.Dependent D on E.SSN = D.Essn
WHERE D.Essn IS NULL