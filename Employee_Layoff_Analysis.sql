-- Database
USE SQL_Portfolio_Projects;


-- View all the attributes and records
SELECT * FROM [dbo].[Employee_Layoff_Analysis];


-- Data Cleaning

-- 1. Handling missing values

-- A. Drop columns with too many missing values
ALTER TABLE Employee_Layoff_Analysis
DROP COLUMN address, date_of_scrape;


-- B. Replace missing values in important columns with suitable defaults
UPDATE Employee_Layoff_Analysis
SET number_of_workers = 0
WHERE number_of_workers IS NULL;


UPDATE Employee_Layoff_Analysis
SET city = 'Unknown'
WHERE city IS NULL;


-- 2. Check and Convert to proper formats (Date, float, string, int)
ALTER TABLE Employee_Layoff_Analysis
ALTER COLUMN received_date DATE;


-- Analysis

-- 1. state has had the most layoffs or closure
SELECT TOP 1 state, COUNT(*) AS most_layoffs
FROM Employee_Layoff_Analysis
WHERE closure_layoff IS NOT NULL
GROUP BY state
ORDER BY 2 DESC;

-- 2. TOP 5 companies with the highest number of affected workers

SELECT TOP 5 company, SUM(number_of_workers)
AS affected_workers FROM Employee_Layoff_Analysis
WHERE number_of_workers IS NOT NULL
GROUP BY company
ORDER BY 2 DESC;

-- Industry has seen the most layoffs or closures
SELECT industry,COUNT(closure_layoff) AS layoffs_or_closures
FROM Employee_Layoff_Analysis
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;


-- Percentage of layoffs were temporary vs permanent
SELECT temporary_permanent, COUNT(*)*100.0/
(SELECT COUNT(*) FROM Employee_Layoff_Analysis)
AS percentage
FROM Employee_Layoff_Analysis
WHERE temporary_permanent IS NOT NULL
AND (temporary_permanent = 'Permanent'
OR temporary_permanent = 'Temporary')
GROUP BY temporary_permanent;



-- 5. Layoffs occured each year
SELECT YEAR(received_date) AS years, 
COUNT(closure_layoff) AS layoffs_occured 
FROM Employee_Layoff_Analysis
WHERE closure_layoff IS NOT NULL
GROUP BY YEAR(received_date)
ORDER BY 2 DESC;


-- 6. Average number of workers affected per layoff
SELECT FLOOR(AVG(number_of_workers))
AS avg_workers_affected
FROM Employee_Layoff_Analysis
WHERE number_of_workers IS NOT NULL;


-- 7. The city which had the highest number of layoffs
SELECT city, COUNT(closure_layoff) AS number_of_layoffs
FROM Employee_Layoff_Analysis
WHERE city NOT LIKE 'Unknown'
GROUP BY city
ORDER BY 2 DESC;


-- 8. Layoffs involved unionized workers
SELECT COUNT(*) AS union_layoffs
FROM Employee_Layoff_Analysis
WHERE "union" IS NOT NULL OR "union" !='';


-- 9. Longest time gap between the 'Received date' and the 'Effective date'
SELECT TOP 1
DATEDIFF(DAY,received_date,effective_date) AS days_gap,
company
FROM Employee_Layoff_Analysis
WHERE received_date IS NOT NULL AND effective_date IS NOT NULL
GROUP BY company,DATEDIFF(DAY,received_date,effective_date)
ORDER BY 1 DESC;


-- 10. Companies had more than 500 workers affected in a single layoff
SELECT COUNT(DISTINCT company) AS companies
FROM Employee_Layoff_Analysis
WHERE number_of_workers > 500;

