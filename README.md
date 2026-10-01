# Ecommerce Data Engineering Platform

An end-to-end E-commerce Data Engineering project built using Python and Microsoft SQL Server, following the Medallion Architecture.

## Project Overview

This project demonstrates the process of ingesting, transforming, cleaning, and organizing e-commerce data into Bronze, Silver, and Gold layers for analytical purposes.

## Architecture

* **Bronze Layer:** Stores raw ingested data.
* **Silver Layer:** Cleans, validates, and transforms raw data.
* **Gold Layer:** Organizes business-ready data for reporting and analytics.

## Technologies Used

* Python
* Microsoft SQL Server
* SQL Server Management Studio (SSMS)
* SQL
* Pandas
* SQLAlchemy
* REST APIs
* Git & GitHub

## Project Structure

* `src/` — Python ingestion scripts
* `scripts/ddl/` — Layer table definitions
* `scripts/eda/` — Exploratory Data Analysis
* `scripts/stored_procedures/` — Data loading procedures
* `docs/` — Project documentation

## Key Features

* API-based data ingestion
* Bronze, Silver, and Gold data layers
* Data cleaning and transformation
* SQL stored procedures
* Exploratory Data Analysis
* Relational data modeling

## Setup

1. Clone this repository.
2. Install the required Python dependencies using `pip install -r requirements.txt`.
3. Configure your database connection using your own environment variables.
4. Create the database and schemas using the DDL scripts.
5. Execute the ingestion scripts and stored procedures in the appropriate order.

## Project Status

Developed as a hands-on Data Engineering portfolio project.
