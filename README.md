# WVU_IENG_331_Project


# Milestone 1: SQL Analysis & Business Insights

---

## Project Overview

This milestone involved building a data product using the Olist dataset, which contains approximately 100,000 from a real-world online marketplace. The analysis for this milestone was performed within the DuckDB using SQL to explore nine interconnected tables.

Course Professor: Ozan Ozbeker
Institution: West Virginia University

- Audrey Doyle
- Ian Donnen
- Rylee Lindermuth

Due Date: Tuesday, March 24, 2026

---

## 1. Data Quality Audit (`data-audit.sql`)

Before conducting an analysis of the Olist, we audited the data to ensure it was organized. This audit used CTEs to organize the logic into clear, professional sections.

We looked into the following areas

- Row Counts: Verified that our data loaded as we expected.

- NULL Rates: This profiles the key columns to identify missing data that could skew data metrics.

- Relational Integrity: Identified "orphaned" foreign keys, which would be orders referencing customers that do not exist in the master table.

- Anomaly Detection: This would detect duplicate records and gaps in the date range.

- We found the audit revealed various data quality issues, including inconsistent formatting and messy text fields, which need to be navigated throughout the project


---

## 2. Analytical Queries

This section outlines four specific business questions investigated using well-structured SQL. At least two of these analyses utilize multi-step CTE chains (3 or more steps) where each CTE builds on the previous one to handle complex logic.

### A. Cohort Retention Analysis

- What percentage of customers return for a second purchase within 30, 60, and 90 days of their first order?

- For this analysis we identified the first purchase for each customer, computed the time between orders, and changed the results to calculate retention rates.
- We used chained CTEs to isolate cohorts by their initial purchase month.


### B. Seller Performance Scorecard

- Who are our top-performing sellers when balancing revenue, delivery reliability, and customer satisfaction?

- We used a composite score was created by joining four or more tables to aggregate revenue, on-time delivery rates, and average review scores. This requires separate CTEs for each metric before combining them into a final ranking.


### C. ABC Inventory Classification

- Which products represent the "vital few" that drive 80% of total revenue (A-Tier)?

- The products are classified into A, B, and C tiers based on pareto principles. We utilized window functions to calculate running totals and percentages for the tier assignments.


### D. Geographic Delivery Analysis

- Business Question: Which geographic corridors consistently fail to meet estimated delivery times?

- This query compares actual vs. estimated delivery dates across different customer regions by joining the order data with geolocation records. This involved date arithmetic, complex joins, and regional aggregation.


---

## 3. Git Discipline & Iterative Development

Our progress in this Milestone is documented through a meaningful commit history.
Rather than a single bulk submission, our repository was cohesive.

- We separated commits for the audit, individual analytical queries, and documentation. And cleared evidence of iterative refactoring and design choices.

---
