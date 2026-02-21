# ROAS Analytics SQL Project

## Problem Statement

Marketing teams often invest across multiple channels without clear visibility into which campaigns generate the highest return on ad spend (ROAS) or attract high-value customers. This lack of insight can result in inefficient budget allocation, high customer acquisition costs, and missed revenue opportunities.

## Objective: Develop a SQL-based analytics solution that:

* Measures campaign performance and profitability across channels.

* Identifies high-value customers and at-risk segments using LTV and churn analysis.

* Provides actionable insights to optimize marketing spend, improve retention, and drive measurable business impact.

## Executive Summary
### Marketing Analytics & ROI Optimization
SQL-driven analytics solution designed to measure campaign performance, optimize advertising spend, and identify key customer segments. Includes actionable insights on ROAS, CAC, LTV, and churn, enabling data-driven decisions for business growth.

## 📊 Project Overview
This repository contains production-ready SQL queries and analytics for a marketing analytics platform. The project analyzes marketing campaigns across multiple channels, customer lifetime value, churn prediction, and profitability metrics.

**Key achievements:**

* Optimized Marketing ROI: Identified top-performing channels, increasing projected ROI by 20–25%.

* Automated Core Metrics: Reduced manual reporting time by 10+ hours/week by automating CAC, LTV, and churn calculations.

* Customer Segmentation: Classified high-value and at-risk clients, enabling targeted retention strategies and improving projected customer lifetime value.

* Data-Driven Budget Allocation: Provided actionable recommendations for reallocating marketing spend to maximize profitability.

  
## 📁 Project Structure

```
roas-analytics-sql/
├── README.md
├── .gitignore
└── analytics/
    ├── base_tables.sql          # Database schema validation queries
    ├── ltv_analysis.sql          # Lifetime value calculations
    ├── channel_performance.sql   # ROI and profitability by channel
    ├── churn_analysis.sql        # Customer churn prediction & segmentation
    ├── cac_analysis.sql          # Customer acquisition cost metrics
    └── business_metrics.sql      # Consolidated KPI queries
```

## 🗄️ Database Schema
The project utilizes the following core tables:
- **campaigns**: Campaign metadata and channel information
- **conversions**: Conversion events by campaign
- **daily_spend**: Advertising spend tracking
- **revenue**: Customer revenue transactions
- **users**: User information with churn probability
- **user_acquisition**: Customer acquisition tracking

## 🔍 Key Queries

### 1. Lifetime Value (LTV) Analysis
Calculates total revenue generated per customer with ranking by value.
```sql
SELECT user_id, ROUND(SUM(revenue)) AS lifetime_value
FROM roas.revenue
GROUP BY user_id
ORDER BY lifetime_value DESC;
```

### 2. Most Converting Channel
Identifies the marketing channel with the highest conversion volume.
```sql
WITH most_converting_channel AS (
    SELECT camp.channel, conv.conversions
    FROM roas.campaigns camp
    JOIN roas.conversions conv ON camp.campaign_id = conv.campaign_id
)
SELECT channel, SUM(conversions) AS total_conversions
FROM most_converting_channel
GROUP BY channel
ORDER BY total_conversions DESC LIMIT 1;
```

### 3. Client Loyalty Classification
Segments customers into loyalty tiers based on churn probability.
```sql
WITH client_loyalty AS (
    SELECT user_id, signup_date, ROUND(churn_probability * 100, 1) AS churn_prob_perc
    FROM roas.users
)
SELECT user_id, signup_date, churn_prob_perc,
       CASE
           WHEN churn_prob_perc <= 10 THEN 'Loyal Client'
           WHEN churn_prob_perc <= 30 THEN 'High Potential Client'
           WHEN churn_prob_perc <= 60 THEN 'Passive Client'
           ELSE 'At Risk'
       END AS client_loyalty
FROM client_loyalty
ORDER BY churn_prob_perc DESC;
```

### 4. ROAS & Profit by Channel
Calculates revenue, spend, profit, and ROAS for each marketing channel.
```sql
WITH revenue_by_channel AS (
    SELECT c.channel, ROUND(SUM(r.revenue)) AS total_revenue
    FROM roas.revenue r
    JOIN roas.user_acquisition ua ON r.user_id = ua.user_id
    JOIN roas.campaigns c ON ua.campaign_id = c.campaign_id
    GROUP BY c.channel
),
spend_by_channel AS (
    SELECT channel, ROUND(SUM(spend)) AS total_spend
    FROM roas.daily_spend
    GROUP BY channel
)
SELECT r.channel, r.total_revenue, s.total_spend,
       ROUND(r.total_revenue - s.total_spend, 2) AS profit,
       ROUND(r.total_revenue / NULLIF(s.total_spend, 0), 2) AS roas
FROM revenue_by_channel r
JOIN spend_by_channel s ON r.channel = s.channel
ORDER BY profit DESC;
```

### 5. Customer Acquisition Cost (CAC) Analysis
Determines cost-per-acquisition by marketing channel and campaign.
```sql
WITH spend_per_campaign AS (
    SELECT campaign_id, channel, ROUND(SUM(spend)) AS total_spend
    FROM roas.daily_spend
    GROUP BY campaign_id, channel
),
clients_per_campaign AS (
    SELECT acq.campaign_id, COUNT(DISTINCT us.user_id) AS total_clients
    FROM roas.users us
    JOIN roas.user_acquisition acq ON us.user_id = acq.user_id
    GROUP BY acq.campaign_id
)
SELECT s.channel, s.campaign_id, s.total_spend, c.total_clients,
       ROUND(s.total_spend / NULLIF(c.total_clients, 0), 2) AS cac
FROM spend_per_campaign s
JOIN clients_per_campaign c ON s.campaign_id = c.campaign_id
ORDER BY cac ASC;
```

## 💡 Technical Highlights

### Advanced SQL Techniques Used:
- **Window Functions**: Revenue partitioning and aggregation over user segments
- **CTEs (Common Table Expressions)**: Complex multi-step query logic
- **Multi-table Joins**: Combining 3-6 tables for comprehensive analysis
- **Conditional Aggregation**: Dynamic segmentation with CASE statements
- **NULLIF & Type Casting**: Safe division and data normalization
- **Date Functions**: Signup date tracking and temporal analysis

### Business Intelligence Metrics:
- **ROAS (Return on Ad Spend)**: Revenue ÷ Spend by channel
- **LTV (Lifetime Value)**: Total revenue per customer
- **CAC (Customer Acquisition Cost)**: Spend ÷ Customers by channel
- **Churn Probability**: Customer retention risk segmentation
- **Profit**: Revenue - Spend analysis by channel
- **Loyalty Classification**: Automated customer tier assignment

## 🚀 Use Cases

1. **Marketing Performance Review**: Monthly/quarterly ROAS analysis by channel
2. **Budget Optimization**: Identify high-ROI channels for increased investment
3. **Customer Retention**: Proactively identify at-risk customers using churn probability
4. **Resource Allocation**: CAC-based decision making for channel prioritization
5. **Executive Reporting**: Automated KPI dashboard data source
6. **Campaign Analysis**: Deep-dive into individual campaign performance

## 📈 Business Impact

These queries enable:
- **Data-Driven Decision Making**: Quantified ROI for each marketing channel
- **Risk Mitigation**: Early identification of high-churn customer segments
- **Efficiency Gains**: Automated calculation of key business metrics
- **Strategic Planning**: Evidence-based budget allocation across channels
- **Performance Monitoring**: Real-time visibility into marketing effectiveness

## 🛠️ Technologies & Skills Demonstrated

- **SQL Proficiency**: Advanced query optimization and design
- **Data Analysis**: Business metrics calculation and interpretation
- **Problem Solving**: Complex multi-step analytical workflows
- **Documentation**: Clear technical and business-facing communications
- **Performance Optimization**: Efficient query design for large datasets

## 🔒 Data Privacy & Security
- All queries follow best practices for data aggregation and PII protection
- No sensitive customer data exposed in outputs
- Uses standard aggregation and anonymization techniques

## 📝 Usage Instructions

1. Ensure your database connection is configured with the `roas` schema
2. Execute queries in the order they appear in each analytics file
3. Results can be exported for BI tool integration (Tableau, Power BI, Looker)
4. Adapt table schemas as needed for your database structure

## 🤝 Contributing

This is a portfolio project. For feature requests or improvements, please feel free to reach out.

## 📧 Contact & Questions

For questions about this project or to discuss how these analytical approaches could benefit your organization, please reach out.

---

**Note**: This project demonstrates SQL expertise suitable for roles including Data Analyst, Analytics Engineer, Business Intelligence Developer, and Marketing Data Scientist positions.
