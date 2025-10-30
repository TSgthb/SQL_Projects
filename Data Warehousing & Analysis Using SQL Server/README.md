# Data Warehousing & Analysis Using SQL Server

This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. It highlights industry best practices in data engineering and analytics.

## Project Overview

This project involves:

1. **Data Architecture**: Designing a modern data warehouse using Medallion Architecture.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights. 

## Data Architecture

![AD](https://github.com/TSgthb/SQL_Data_Warehouse_Project/blob/main/documents/data_warehouse/architecture_diagram.png)

The data architecture for this project follows Medallion Architecture. There are 3 different layers - **Bronze**, **Silver**, and **Gold**.

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

## Project Requirements

### 1. Building the Data Warehouse

**Objective:** Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

**Specifications:**
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Clean and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

### 2. BI: Analytics & Reporting

**Objective:** Develop SQL-based analytics to deliver detailed insights into:
- Customer Behavior
- Product Performance
- Sales Trends

## Repository Structure
```
SQL_Data_Warehouse_Project/
│
├── datasets/                           # Raw datasets used for the project
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
