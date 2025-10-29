## Repository Overview

This repository contains a collection of projects that walk demonstrates the end-to-end workflow of a data analytics pipeline, showcasing practical implementations of data engineering and analytical concepts using SQL. Each project is designed to simulate real-world scenarios and includes the following stages:

- *Data Extraction*: This mainly includes pulling datasets from online sources, such as Kaggle.
- *Data Ingestion & Cleaning*: This involves importing raw data which is present in the form of flat files into a structured environment that has been prepared by analyzing the requirements, handling missing values, duplicates, and inconsistencies and finally standardizing formats for dates, strings, and categorical variables.
- *Data Transformation & Analysis*: This includes the creation of derived columns, calculated metrics and aggregations to reshape and enrich the data, support analysis and derive insights to solve business problems.

The projects span a wide range of concepts, ranging from foundational techniques like basic data exploration, string operations, conditional logic and date manipulations, to advanced SQL features such as, aggregations and window functions, common table expressions (CTEs), subqueries, temporary tables, views and stored procedures for modular and reusable logic.

## Repository Structure

```
SQL Projects
│
├── /                           # Raw datasets used for the project
│   ├── source_crm/                     # CRM datasets
|   ├── source_erp/                     # ERP datasets
|
├── docs/                               # Project documentation and architecture details
│   ├── architecture_diagram.png        # Image showing the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow_diagram.png           # Image for the data flow diagram
│   ├── data_model_diagram.png          # Image for data model (star schema)
|   ├── integration_diagram.png         # Image for integration diagram
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL, transformations and BI
|   ├── data_analysis/                  # Scripts related to exploratory data analysis
|   ├── data_warehouse/                 # Scripts for ETL
│       ├── bronze/                     # Scripts for extracting and loading raw data
│       ├── silver/                     # Scripts for cleaning and transforming data
│       ├── gold/                       # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions

```
