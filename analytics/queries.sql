/* ===========================
   LIFETIME VALUE (LTV) ANALYSIS
   =========================== */

-- Calculate total lifetime revenue per customer, ranked by value
SELECT 
    user_id,
    ROUND(SUM(revenue)) AS lifetime_value
FROM roas.revenue
GROUP BY user_id
ORDER BY lifetime_value DESC;


/* ===========================
   MOST CONVERTING CHANNEL
   =========================== */

-- Identify the marketing channel with highest conversion volume
WITH most_converting_channel AS (
    SELECT 
        camp.channel,
        conv.conversions
    FROM roas.campaigns camp
    JOIN roas.conversions conv
        ON camp.campaign_id = conv.campaign_id
)
SELECT 
    channel,
    SUM(conversions) AS total_conversions
FROM most_converting_channel
GROUP BY channel
ORDER BY total_conversions DESC
LIMIT 1;


/* ===========================
   HIGHEST VALUE CLIENT (LTV)
   =========================== */

-- Find the single customer with highest lifetime value
SELECT 
    user_id,
    ROUND(SUM(revenue)) AS lifetime_value
FROM roas.revenue
GROUP BY user_id
ORDER BY lifetime_value DESC
LIMIT 1;


/* ===========================
   CLIENT LOYALTY CLASSIFICATION
   Segments customers by churn probability
   =========================== */

WITH client_loyalty AS (
    SELECT 
        user_id,
        signup_date,
        ROUND(churn_probability * 100, 1) AS churn_prob_perc
    FROM roas.users
)
SELECT 
    user_id,
    signup_date,
    churn_prob_perc,
    CASE
        WHEN churn_prob_perc <= 10 THEN 'Loyal Client'
        WHEN churn_prob_perc <= 30 THEN 'High Potential Client'
        WHEN churn_prob_perc <= 60 THEN 'Passive Client'
        ELSE 'At Risk'
    END AS client_loyalty
FROM client_loyalty
ORDER BY churn_prob_perc DESC;


/* ===========================
   USER REVENUE BY LOYALTY TIER
   Combines LTV with churn segmentation
   =========================== */

WITH user_revenue AS (
    SELECT 
        us.user_id,
        us.churn_probability,
        ROUND(SUM(rev.revenue) OVER (PARTITION BY us.user_id)) AS lifetime_value
    FROM roas.users us
    JOIN roas.revenue rev
        ON us.user_id = rev.user_id
)
SELECT 
    user_id,
    lifetime_value,
    churn_probability,
    CASE
        WHEN churn_probability <= 0.10 THEN 'Loyal Client'
        WHEN churn_probability <= 0.30 THEN 'High Potential Client'
        WHEN churn_probability <= 0.60 THEN 'Passive Client'
        ELSE 'At Risk'
    END AS client_loyalty
FROM user_revenue
ORDER BY churn_probability DESC;


/* ===========================
   CHURN VS AVERAGE INCOME
   Analyzes correlation between churn and revenue
   =========================== */

WITH churn_bucket_income AS (
    SELECT 
        FLOOR(churn_probability * 10) / 10 AS churn_bucket,
        ROUND(AVG(revenue)) AS avg_income
    FROM roas.users us
    JOIN roas.revenue rev
        ON us.user_id = rev.user_id
    GROUP BY churn_bucket
)
SELECT 
    churn_bucket,
    avg_income,
    CASE
        WHEN churn_bucket <= 0.10 THEN 'Loyal Client'
        WHEN churn_bucket <= 0.30 THEN 'High Potential Client'
        WHEN churn_bucket <= 0.60 THEN 'Passive Client'
        ELSE 'At Risk'
    END AS client_loyalty
FROM churn_bucket_income
ORDER BY avg_income DESC;


/* ===========================
   PROFIT & ROAS BY CHANNEL
   Complete marketing performance analysis
   =========================== */

WITH revenue_by_channel AS (
    SELECT 
        c.channel,
        ROUND(SUM(r.revenue)) AS total_revenue
    FROM roas.revenue r
    JOIN roas.user_acquisition ua
        ON r.user_id = ua.user_id
    JOIN roas.campaigns c
        ON ua.campaign_id = c.campaign_id
    GROUP BY c.channel
),
spend_by_channel AS (
    SELECT 
        channel,
        ROUND(SUM(spend)) AS total_spend
    FROM roas.daily_spend
    GROUP BY channel
)
SELECT 
    r.channel,
    r.total_revenue,
    s.total_spend,
    ROUND(r.total_revenue - s.total_spend, 2) AS profit,
    ROUND(r.total_revenue / NULLIF(s.total_spend, 0), 2) AS roas
FROM revenue_by_channel r
JOIN spend_by_channel s
    ON r.channel = s.channel
ORDER BY profit DESC;


/* ===========================
   CUSTOMER ACQUISITION COST (CAC)
   Cost per customer by channel and campaign
   =========================== */

WITH spend_per_campaign AS (
    SELECT 
        campaign_id,
        channel,
        ROUND(SUM(spend)) AS total_spend
    FROM roas.daily_spend
    GROUP BY campaign_id, channel
),
clients_per_campaign AS (
    SELECT 
        acq.campaign_id,
        COUNT(DISTINCT us.user_id) AS total_clients
    FROM roas.users us
    JOIN roas.user_acquisition acq
        ON us.user_id = acq.user_id
    GROUP BY acq.campaign_id
)
SELECT 
    s.channel,
    s.campaign_id,
    s.total_spend,
    c.total_clients,
    ROUND(s.total_spend / NULLIF(c.total_clients, 0), 2) AS cac
FROM spend_per_campaign s
JOIN clients_per_campaign c
    ON s.campaign_id = c.campaign_id
ORDER BY cac ASC;
