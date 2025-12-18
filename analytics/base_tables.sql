/* ===========================
   BASE TABLE CHECKS
   =========================== */

-- Validate all core tables exist and show row counts
SELECT 'campaigns' AS table_name, COUNT(*) AS row_count FROM roas.campaigns
UNION ALL
SELECT 'conversions', COUNT(*) FROM roas.conversions
UNION ALL
SELECT 'daily_spend', COUNT(*) FROM roas.daily_spend
UNION ALL
SELECT 'revenue', COUNT(*) FROM roas.revenue
UNION ALL
SELECT 'users', COUNT(*) FROM roas.users;

-- Display all campaigns
SELECT * FROM roas.campaigns;

-- Display all conversions
SELECT * FROM roas.conversions;

-- Display all daily spend records
SELECT * FROM roas.daily_spend;

-- Display all revenue transactions
SELECT * FROM roas.revenue;

-- Display all user records
SELECT * FROM roas.users;
