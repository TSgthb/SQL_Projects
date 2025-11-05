# COVID-19 Global Impact Analysis

<p align="justify">
This project demonstrates a comprehensive SQL-based exploratory analysis of global COVID-19 data using SQL Server. It leverages the dataset to extract insights on infection rates, mortality, vaccination coverage, and temporal trends across countries and continents.
</p>

---

## Project Objectives

1. **Download and preprocess the global COVID-19 dataset from Our World in Data.**
2. **Split the original dataset into two logical tables: deaths and vaccinations.**
3. **Import both datasets into SQL Server with appropriate data types and NULL handling.**
4. **Perform analytical queries to understand infection spread, mortality rates, vaccination coverage, and temporal patterns.**

---

## Project Structure

### 1. Dataset Preparation Instructions

- **Source:** [Our World in Data COVID-19 Dataset](https://docs.owid.io/projects/etl/api/covid/#download-data)
- **Step 1:** Move `code`, `continent`, and `population` columns to columns A, B, and E respectively.
- **Step 2:** Delete all columns after column AE (starting from `total_tests` to `human_development_index`). Save this as the **deaths dataset**.
- **Step 3:** Reopen the original file and delete columns from E (`population`) to AE (`reproduction_rate`). Save this as the **vaccinations dataset**.
- **Step 4:** Import both datasets into SQL Server using the **Import Flat File** wizard in SSMS.
  - For **deaths dataset**:
    - `country`, `date`, `code`, `continent` → `NVARCHAR`
    - `date` → `DATETIME2`
    - All numeric columns → `FLOAT` or `BIGINT` as appropriate
    - Allow NULLs on all except `country` and `date`
  - For **vaccinations dataset**:
    - `country`, `date`, `code`, `continent` → `NVARCHAR`
    - `date` → `DATETIME2`
    - `population`, `total_tests`, `new_tests` → `BIGINT`
    - All other numeric columns → `FLOAT`

---

### 2. Data Exploration & Advanced Analytics

- **The following queries analyze infection rates, death percentages, vaccination coverage, and temporal trends across countries and continents.**
- **This section uses aggregation, conditional logic, joins, and date-based grouping to derive insights.**

1. **Check Row Counts in Both Tables**

```sql
-- ============================================================
-- Objective: Count total rows in deaths and vaccinations tables.
-- ============================================================
USE covid19_data;
GO

SELECT COUNT(*) AS total_rows_deaths
FROM dbo.deaths;
GO

SELECT COUNT(*) AS total_rows_vaccinations
FROM dbo.vaccinations;
GO
```

2. **Preview Sample Data**

```sql
-- ============================================================
-- Objective: View first 10 records from each table.
-- ============================================================
SELECT TOP (10) *
FROM dbo.deaths
ORDER BY date;
GO

SELECT TOP (10) *
FROM dbo.vaccinations
ORDER BY date DESC;
GO
```

3. **Daily Death Percentage by Country**

```sql
-- ============================================================
-- Objective: Calculate daily death percentage from total cases.
-- ============================================================
SELECT
    country,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN (total_cases IS NULL OR total_cases = 0) OR (total_deaths IS NULL OR total_deaths = 0) THEN NULL
        ELSE ROUND((CAST(total_deaths AS FLOAT) / total_cases) * 100, 2)
    END AS death_perc
FROM dbo.deaths
ORDER BY country, date;
GO
```

4. **Daily Infection Percentage by Country**

```sql
-- ============================================================
-- Objective: Calculate daily infection percentage from population.
-- ============================================================
SELECT
    country,
    date,
    total_cases,
    population,
    CASE
        WHEN (population IS NULL OR population = 0) OR (total_cases IS NULL OR total_cases = 0) THEN NULL
        ELSE ROUND((CAST(total_cases AS FLOAT) / population) * 100, 2)
    END AS infection_perc
FROM dbo.deaths;
GO
```

5. **Top 10 Countries by Infection Rate**

```sql
-- ============================================================
-- Objective: Identify countries with highest infection vs. population percentage.
-- ============================================================
SELECT TOP (10)
    country,
    MAX(total_cases) AS overall_infection_cases,
    MAX(population) AS tot_population,
    ROUND(MAX(CAST(total_cases AS FLOAT))/MAX(population) * 100, 2) AS max_infection_vs_population_perc
FROM dbo.deaths
WHERE population IS NOT NULL AND population != 0
      AND total_cases IS NOT NULL AND total_cases != 0
GROUP BY country
ORDER BY max_infection_vs_population_perc DESC;
GO
```

6. **Continents by Death Rate**

```sql
-- ============================================================
-- Objective: Rank continents by death vs. population percentage.
-- ============================================================
SELECT
    continent,
    MAX(total_deaths) AS overall_deaths,
    MAX(population) AS tot_population,
    ROUND((MAX(CAST(total_deaths AS FLOAT))/MAX(population)) * 100, 2) AS max_deaths_vs_population_perc
FROM dbo.deaths
WHERE continent IS NOT NULL
      AND population IS NOT NULL AND population != 0
      AND total_cases IS NOT NULL AND total_cases != 0
      AND total_deaths IS NOT NULL AND total_deaths != 0
GROUP BY continent
ORDER BY max_deaths_vs_population_perc DESC;
GO
```

7. **Monthly and Yearly Aggregates**

```sql
-- ============================================================
-- Objective: Aggregate cases, deaths, and percentages by month and year.
-- ============================================================
SELECT
    YEAR(date) AS year_of_wave,
    MONTH(date) AS month_of_year,
    MAX(total_cases) AS tot_cases,
    MAX(total_deaths) AS tot_deaths,
    MAX(population) AS tot_population,
    ROUND((MAX(CAST(total_cases AS FLOAT))/MAX(population)) * 100, 2) AS tot_cases_vs_tot_population,
    ROUND((MAX(CAST(total_deaths AS FLOAT))/MAX(population)) * 100, 2) AS tot_deaths_vs_tot_population,
    ROUND((MAX(CAST(total_deaths AS FLOAT))/MAX(total_cases)) * 100, 2) AS tot_deaths_vs_tot_cases_perc
FROM dbo.deaths
WHERE continent IS NOT NULL
      AND population IS NOT NULL AND population != 0
      AND total_cases IS NOT NULL AND total_cases != 0
      AND total_deaths IS NOT NULL AND total_deaths != 0
GROUP BY YEAR(date), MONTH(date)
ORDER BY YEAR(date), MONTH(date);
GO
```

8. **Country-Level Aggregates with Vaccination Data**

```sql
-- ============================================================
-- Objective: Merge deaths and vaccinations data to compute country-level metrics.
-- ============================================================
SELECT
    d.continent,
    d.country,
    MAX(d.population) AS tot_population,
    MAX(d.total_cases) AS tot_cases,
    MAX(d.total_deaths) AS tot_deaths,
    ROUND((MAX(CAST(d.total_cases AS FLOAT))/MAX(d.population)) * 100, 2) AS tot_cases_vs_tot_population_perc,
    ROUND((MAX(CAST(d.total_deaths AS FLOAT))/MAX(d.population)) * 100, 2) AS tot_deaths_vs_tot_population_perc,
    ROUND((MAX(CAST(d.total_deaths AS FLOAT))/MAX(d.total_cases)) * 100, 2) AS tot_deaths_vs_tot_cases_perc,
    MAX(v.total_tests) AS tot_tests,
    MAX(v.total_vaccinations) AS tot_vaccinations,
    MAX(v.total_boosters) AS tot_boosters,
    ROUND((MAX(CAST(v.total_vaccinations AS FLOAT))/MAX(d.population)) * 100, 2) AS tot_vaccines_vs_tot_population_perc
FROM dbo.deaths d
INNER JOIN dbo.vaccinations v
    ON d.country = v.country AND d.date = v.date
WHERE d.continent IS NOT NULL
      AND d.population IS NOT NULL AND d.population != 0
      AND d.total_cases IS NOT NULL AND d.total_cases != 0
      AND d.total_deaths IS NOT NULL AND d.total_deaths != 0
GROUP BY d.continent, d.country
ORDER BY d.continent, d.country;
GO
```

9. **Yearly Country-Level Aggregates with Vaccination Data**

```sql
-- ============================================================
-- Objective: Create yearly summary of cases, deaths, and vaccinations per country.
-- ============================================================
SELECT
    d.continent,
    d.country,
    YEAR(d.date) AS year_of_wave,
    MAX(d.population) AS tot_population,
    MAX(d.total_cases) AS tot_cases,
    SUM(d.new_cases) AS cases_reported,
    MAX(d.total_deaths) AS tot_deaths,
    SUM(d.new_deaths) AS deaths_reported,
    MAX(v.total_tests) AS tot_tests,
    MAX(v.total_vaccinations) AS tot_vaccinations,
    MAX(v.total_boosters) AS tot_boosters,
    ROUND((MAX(CAST(v.total_vaccinations AS FLOAT))/MAX(d.population)) * 100