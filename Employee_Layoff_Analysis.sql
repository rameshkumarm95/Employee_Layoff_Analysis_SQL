-- Database
USE SQL_Portfolio_Projects;

/* 
Project_name: Employee Layoff Analysis

Dataset: (https://www.kaggle.com/datasets/paiky1995/warn-layoffs-dataset)

About Dataset

The federal WARN Act requires large employers to give advance
notice of layoffs to state governments and workers. States publish
this layoff information with varying degrees of specificity.

The dataset contains 73030 rows and 16 columns

Columns:

1.  State				: U.S. state where the layoff occurred.
2.  Company				: Name of the company.
3.  City				: City where the layoff occurred (missing values).
4.  Number of Workers	: Number of workers affected (some missing values).
5.  Received Date		: Date the layoff notice was received.
6.  Effective Date		: Date the layoff was effective (many missing values).
7.  Closure / Layoff	: Type of action (closure or layoff).
8.  Temporary/Permanent	: Type of layoff (temporary or permanent).
9.  Union				: Whether a union was involved (mostly missing).
10. Region				: The region where the layoff happened (many missing values).
11. County				: County information (many missing values).
12. Industry			: Industry of the company (many missing values).
13. Notes				: Additional notes on the layoff.
14. Date_of_Scrape		: Date the data was scraped.
15. Parent_Company		: Parent company (mostly missing).
16. Address				: Address of the company (mostly missing).


*/

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
.

/*
This project focused on analyzing layoff data to provide insights into the layoff trends, the most affected regions, industries, and companies. 
After cleaning the data and fixing date conversion issues, we explored several key factors, including:

1 .The states and industries most affected by layoffs.
2. Companies with the highest layoffs and the number of workers impacted.
3. The distinction between temporary and permanent layoffs.
4. The influence of unions and the time gap between receiving and enacting layoffs.

This analysis will provide valuable insights to better understand the scope and trends of layoffs across various industries and regions, 
helping stakeholders make informed decisions and plan mitigation strategies.

*/
