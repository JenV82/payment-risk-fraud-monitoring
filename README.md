Payment Risk & Fraud Monitoring Database

Harvard CS50 SQL — Final Project

A relational SQLite database designed to support payment risk investigations, fraud monitoring, merchant account reviews, and chargeback management.

Project Overview

This project applies SQL database design to real-world payment risk scenarios. It organizes merchant accounts, payment transactions, chargebacks, and risk alerts into a relational database that analysts can query to identify potentially suspicious activity and prioritize investigations.

The database supports human-led risk reviews rather than automated fraud decisions.

Technologies Used

SQLite

SQL

Relational database design

Primary and foreign keys

CHECK constraints

SQL joins, subqueries, and CASE expressions

Database indexing

Database Structure

The database contains four interconnected tables:

merchants: Merchant account information and risk classifications.

transactions: Payment activity, transaction statuses, and verification results.

chargebacks: Payment disputes, response deadlines, and resolution outcomes.

risk_alerts: Merchant-level and transaction-level risk concerns.



SQL Analysis

The project includes eight analytical queries demonstrating how SQL can support payment risk operations.

Examples include:

Prioritizing open risk alerts by severity.

Identifying suspicious transaction verification results.

Monitoring declined transaction activity.

Identifying unresolved chargebacks and response deadlines.

Summarizing outstanding alerts by merchant and severity.

Project Files

File

Description

schema.sql

Database tables, relationships, constraints, and indexes

queries.sql

SQL queries supporting risk analysis

DESIGN.md

Detailed database design documentation

payment_risk_erd.png

Entity relationship diagram

payment_risk.db

SQLite database containing fictional sample records

Exploring the Database

Open the included sample database using SQLite:

sqlite3 payment_risk.db

To run the analytical queries from a terminal:

sqlite3 payment_risk.db < queries.sql

All sample merchant and transaction information is fictional.

Video Demonstration

Watch the CS50 SQL Final Project Demonstration

Future Improvements

Potential improvements include additional validation to ensure transaction-level alerts reference the correct merchant, larger datasets for performance testing, and expanded risk-monitoring capabilities.

Author

Jennifer Van Oster

Developed as the final project for Harvard University's CS50's Introduction to Databases with SQL.