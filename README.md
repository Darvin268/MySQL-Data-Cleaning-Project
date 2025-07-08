# 🧹 SQL Data Cleaning Project – Tech Layoffs 2020–2023

## 📌 Project Overview

This project focuses on cleaning a real-world dataset of tech company layoffs from 2020 to 2023 using **SQL only**. The dataset includes information such as company name, location, industry, number of employees laid off, funding raised, and the date of the layoff. The goal is to prepare this dataset for future analysis by resolving duplicates, standardizing formats, handling nulls/blanks, and fixing inconsistent data.

---

## 🎯 Objective

- Remove duplicate rows using `ROW_NUMBER()`
- Standardize inconsistent text fields (e.g., country, industry)
- Convert date strings to `DATE` datatype
- Handle `NULL` and blank values across important columns
- Impute missing values where possible using self-joins
- Remove rows/columns that add no analytical value

---

## 🛠 Tools & Technologies

- MySQL (Structured Query Language)
- MySQL Workbench or CLI


---

## 🧠 Key Skills Demonstrated

- Perform multi-step data cleaning:
  - Remove duplicates
  - Standardize inconsistent values
  - Handle null and blank entries
  - Create staging tables for safe editing
  - Use `TRIM()`, `LIKE`, `UPDATE`, `ROW_NUMBER()` window functions
- String manipulation with `TRIM()`, `TRAILING`, `LIKE`
- Date formatting using `STR_TO_DATE()`
- Self-joins to fill missing values
- Schema modifications with `ALTER TABLE`, `UPDATE`, `DELETE`
- Data quality thinking (e.g., deciding when to drop data)

---

## 🗃 Dataset Structure (Before Cleaning)

| Column                 | Description                          |
|------------------------|--------------------------------------|
| company                | Company name                         |
| location               | City or region of layoff             |
| industry               | Company industry                     |
| total_laid_off         | Number of employees laid off         |
| percentage_laid_off    | Percentage of workforce affected     |
| date                   | Layoff date (in string format)       |
| stage                  | Startup funding stage                |
| funds_raised_millions  | Total funds raised (in millions)     |
| country                | Country name                         |
| region                 | Macro-region (e.g., North America)   |
| row_num                | Temporary row identifier for dedupe  |

---

## 🔧 Cleaning Steps Summary

### 1. 🧬 Remove Duplicates
Used a CTE with `ROW_NUMBER()` to identify duplicates based on company, location, and date, and deleted all `row_num > 1`.

### 2. 🧽 Standardize Text
Fixed issues like trailing periods (e.g., United States. → United States) and blank spaces using TRIM() and TRAILING.

### 3. 📅 Convert Date Format
Converted date column from TEXT to DATE using STR_TO_DATE() and then altered its data type.

### 4. ❓ Handle Null and Blank Values
Replaced blanks ('') in industry with NULL.
Populated missing industry values via self-join

### 5. 🗑 Remove Irrelevant Data
Deleted rows with no layoff count or percentage.
Dropped the helper row_num column.

## ✅ Results

- Cleaned and standardized over 2300 records
- Converted all date values to proper format for time-series use
- Filled missing industry values using company/location matching
- Removed rows that lacked any measurable layoff data


## 📁 Files in this Repo
| File | Description |
|------|-------------|
| `layoffs.xlsx` | raw dataset |
| `DATA CLEANING.sql` | data cleaning queries |

