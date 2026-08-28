# Blinkit Grocery Sales Analysis

An end-to-end analytics project using Blinkit grocery outlet data to understand sales performance, product categories, outlet characteristics, and customer ratings. The project includes a Power BI dashboard, the source CSV dataset, and reusable SQL analysis queries.

## Project Objectives

- Measure total sales, average sales, average item visibility, and average rating.
- Compare sales across outlet type, location tier, size, and establishment year.
- Identify high-performing product categories and fat-content segments.
- Examine data quality and prepare consistent fields for analysis.
- Present business insights through an interactive Power BI report.

## Repository Contents

| File | Description |
| --- | --- |
| `BlinkIT Grocery Data.csv` | Source dataset with 8,523 grocery item and outlet records. |
| `BlinkitPowerBIdataProject.pbix` | Power BI report and dashboard. Open with Power BI Desktop. |
| `Blinkit_Analysis_Queries.sql` | SQL schema, validation checks, KPIs, and analysis queries. |

## Dataset Fields

The dataset contains item attributes (`Item Identifier`, `Item Type`, `Item Fat Content`, `Item Weight`), outlet dimensions (`Outlet Identifier`, `Outlet Establishment Year`, `Outlet Location Type`, `Outlet Size`, `Outlet Type`), and measures (`Item Visibility`, `Total Sales`, `Rating`).

## Tools and Skills

- Power BI Desktop
- Power Query for data preparation
- DAX measures and data modeling
- SQL aggregations, conditional logic, CTEs, and window functions
- Data visualization and business KPI analysis

## How to Use

1. Download or clone this repository.
2. Open `BlinkitPowerBIdataProject.pbix` in Power BI Desktop.
3. If Power BI asks for the data source, point it to `BlinkIT Grocery Data.csv`.
4. Load the SQL file into a database after importing the CSV into a table named `blinkit_grocery_data`.

The SQL uses broadly supported SQL syntax. The window-function query requires a database that supports `RANK()` and CTEs, such as PostgreSQL, MySQL 8+, SQL Server, or SQLite 3.25+.

## Key Business Questions

- Which outlet types generate the most sales?
- Which product categories contribute most to revenue?
- How do location tier and outlet size affect performance?
- Which items combine strong sales with high customer ratings?
- Are there data-quality issues that could affect dashboard results?

## Notes

`Item Fat Content` contains inconsistent capitalization in the source data, so the SQL analysis normalizes it before grouping. `Total Sales` is treated as the sales measure provided by the dataset; it is not recalculated from quantity or price because those fields are not included.
