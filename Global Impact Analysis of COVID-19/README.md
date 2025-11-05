# Global Impact Analysis of COVID-19

<p align="justify"> This project demonstrates a comprehensive SQL-based exploratory analysis of global COVID-19 data using SQL Server. It leverages the dataset to extract insights on infection rates, mortality, vaccination coverage, and temporal trends across countries and continents and provide oppurtunities to transform raw epidemiological data into structured insights that support public health decision-making, policy evaluation, and global comparisons. </p> 

Jump to end for [Findings & Conclusions](https://github.com/TSgthb/SQL_Projects/tree/main/Global%20Impact%20Analysis%20of%20COVID-19#findings-and-conclusion).

## Project Objectives

1. Download and preprocess the global COVID-19 dataset from Our World in Data.
2. Split the original dataset into two logical tables: deaths and vaccinations.
3. Import both datasets into SQL Server with appropriate data types and NULL handling.
4. Perform analytical queries to understand infection spread, mortality rates, vaccination coverage, and other patterns.

## Project Structure

### 1. Database Setup & Dataset Preparation
- **Database creation:** Create a database named `covid19_data`.
- **Dataset sourcing:** Download the global COVID-19 dataset from [Our World in Data COVID-19 Dataset](https://docs.owid.io/projects/etl/api/covid/#download-data).
- **Dataset preparation:** Preprocess the global COVID-19 dataset, `covid19_dataset.csv` and make following transformations:
  - Move `code`, `continent`, and `population` columns to columns A, B, and E respectively.
  - Delete all columns after column AE (starting from `total_tests` to `human_development_index`). Save this as `covid19_deaths_dataset_aftersplit.csv`.
  - Reopen the original file and delete columns from E (`population`) to AE (`reproduction_rate`). Save this as the `covid19_vaccinations_dataset_aftersplit.csv`.
  - Import both datasets into SQL Server using the **Import Flat File** wizard in SSMS as following tables and column datatypes:
    - **deaths**
      1. `country`, `date`, `code`, `continent` → `NVARCHAR`
      2. `date` → `DATETIME2`
      3. All numeric columns → `FLOAT` or `BIGINT` as appropriate
      4. Allow NULLs on all except `country` and `date`
    - **vaccinations**
      1. `country`, `date`, `code`, `continent` → `NVARCHAR`
      2. `date` → `DATETIME2`
      3. `population`, `total_tests`, `new_tests` → `BIGINT`
      4. All other numeric columns → `FLOAT`

### 2. Data Exploration & Advanced Analytics

**The following queries analyze infection rates, death percentages, vaccination coverage, and temporal trends across countries and continents using aggregation, conditional logic, joins, and date-based grouping to derive insights.**

1. **Check Row Counts in Both Tables**

```sql
-- ============================================================
-- Objective: Count total rows in deaths and vaccinations tables.
-- ============================================================
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

9. **Temporary table: Yearly Country-Level Aggregates with Vaccination Data**

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
    ROUND((MAX(CAST(v.total_vaccinations AS FLOAT))/MAX(d.population)) * 100, 2) AS tot_vaccines_vs_tot_population_perc
INTO #tt_world_stats
FROM dbo.deaths d
INNER JOIN dbo.vaccinations v
    ON d.country = v.country AND d.date = v.date
WHERE d.continent IS NOT NULL
      AND d.population IS NOT NULL AND d.population != 0
      AND d.total_cases IS NOT NULL AND d.total_cases != 0
      AND d.total_deaths IS NOT NULL AND d.total_deaths != 0
GROUP BY d.continent, d.country, YEAR(d.date)
ORDER BY d.continent, d.country, YEAR(d.date);
GO

-- ============================================================
-- Objective: View the yearly country-level summary from the temp table.
-- ============================================================
SELECT *
FROM #tt_world_stats
ORDER BY continent, country, year_of_wave;
GO
```

## Findings and Conclusion

- **Data Structuring:** The original dataset was split into two focused tables, deaths and vaccinations, enabling modular analysis and efficient joins.
  
- **Data Quality Observations:** Several records had missing or zero values for critical fields like population, total_cases, or total_deaths. These were filtered out to ensure analytical integrity.
  
- **Infection Trends:** Countries like the United States, China, India and France showed the highest infection counts. However, smaller nations like Faroe Islands, Andorra and San Marino were amonng the highest infection rates relative to population.
  
- **Mortality Insights:** Death-to-case ratios varied significantly across countries and continents. Some regions with high case counts maintained relatively low mortality rates, indicating stronger healthcare responses.
  
- **Vaccination Coverage:** Countries with high vaccination percentages generally showed lower death rates in later waves, suggesting a strong correlation between vaccine rollout and reduced mortality.
  
- **Temporal Patterns:** The pandemic exhibited clear wave patterns, with spikes in cases and deaths aligning with global surges. Year-over-year analysis highlighted the impact of variants and public health interventions.
- **Continental Disparities:** Africa and Asia showed lower reported case and death percentages, possibly due to underreporting or demographic advantages. Ocenia, Europe, Americas had higher mortality ratios.


