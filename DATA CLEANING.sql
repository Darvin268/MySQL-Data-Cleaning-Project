-- View raw data
SELECT *
FROM layoffs;

-- Step 1: Create a staging table for data cleaning
-- This avoids altering the original data
CREATE TABLE layoffs_staging
LIKE layoffs;

-- View the newly created staging table
SELECT *
FROM layoffs_staging;

-- Copy data from original table into staging table
INSERT layoffs_staging
SELECT *
FROM layoffs;


-- Step 2: Detect Duplicate Records
-- Add row numbers partitioned by key fields that might indicate duplicates
SELECT *,
    row_number() OVER (
        PARTITION BY company, industry, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_staging;


-- Step 3: Create a CTE to filter out duplicate records
WITH duplicate_cte AS (
    SELECT *,
        row_number() OVER (
            PARTITION BY company, industry, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1; -- View only the duplicates


-- Step 4: Create a new table with row numbers for easier duplicate deletion
CREATE TABLE `layoffs_staging2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert data with row numbers into the new table
INSERT INTO layoffs_staging2
SELECT *,
    row_number() OVER (
        PARTITION BY company, industry, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

-- Delete duplicate rows based on row number
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Double check if duplicates are removed
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;



-- Step 5: Standardize Data

-- Trim spaces in 'company' column
SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry naming (e.g., merge all 'Crypto...' into 'Crypto')
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Fix country naming issues (e.g., remove trailing '.' from 'United States.')
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert 'date' from text to proper DATE format
SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter column type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- Step 6: Handle NULL and Missing Values

-- Check records with both total_laid_off and percentage_laid_off as NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Find records with missing or empty industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

-- Example: Investigate company with missing industry
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Set empty industry strings to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Use self-join to fill in missing industry values from matching company & location
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Update missing industries using values from matched records
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;



-- Step 7: Final Cleaning

-- Remove rows with no layoff data at all
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Drop the helper column used for duplicate detection
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- Step 8: Final Check

-- View the cleaned dataset
SELECT *
FROM layoffs_staging2;













