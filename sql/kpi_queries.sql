-- =====================================================
-- KPI Queries - Business Metrics & Analytics
-- =====================================================
-- Purpose: Calculate key performance indicators for dashboard
-- Techniques: CTEs, Window Functions, Aggregations, Joins
-- Date: 2025-11-23
-- =====================================================

-- =====================================================
-- KPI 1: DAILY ACTIVE USERS (DAU) TREND
-- =====================================================
-- Business Question: How many unique users are active each day?
-- Methodology: Count distinct users with transactions or logins per day

WITH daily_activity AS (
    SELECT 
        DATE(transaction_date) as activity_date,
        COUNT(DISTINCT user_id) as active_users,
        COUNT(transaction_id) as total_transactions,
        SUM(CASE WHEN transaction_status = 'success' THEN amount ELSE 0 END) as revenue
    FROM transactions
    WHERE transaction_date >= DATE('now', '-90 days')
    GROUP BY DATE(transaction_date)
),
moving_average AS (
    SELECT 
        activity_date,
        active_users,
        total_transactions,
        revenue,
        AVG(active_users) OVER (
            ORDER BY activity_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as dau_7day_avg,
        AVG(revenue) OVER (
            ORDER BY activity_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as revenue_7day_avg
    FROM daily_activity
)
SELECT 
    activity_date,
    active_users as daily_active_users,
    ROUND(dau_7day_avg, 2) as dau_7day_moving_avg,
    total_transactions,
    ROUND(revenue, 2) as daily_revenue,
    ROUND(revenue_7day_avg, 2) as revenue_7day_moving_avg,
    ROUND(revenue / NULLIF(active_users, 0), 2) as revenue_per_user
FROM moving_average
ORDER BY activity_date DESC;

-- =====================================================
-- KPI 2: USER CHURN RATE BY COHORT
-- =====================================================
-- Business Question: What percentage of users become inactive within 90 days?
-- Methodology: Cohort analysis based on signup month

WITH user_cohorts AS (
    SELECT 
        user_id,
        DATE(signup_date, 'start of month') as cohort_month,
        is_active,
        JULIANDAY('now') - JULIANDAY(last_login_date) as days_since_login,
        subscription_tier
    FROM users
),
cohort_metrics AS (
    SELECT 
        cohort_month,
        subscription_tier,
        COUNT(*) as total_users,
        SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as churned_users,
        SUM(CASE WHEN days_since_login > 90 THEN 1 ELSE 0 END) as inactive_90days,
        AVG(days_since_login) as avg_days_since_login
    FROM user_cohorts
    GROUP BY cohort_month, subscription_tier
)
SELECT 
    cohort_month,
    subscription_tier,
    total_users,
    churned_users,
    inactive_90days,
    ROUND(100.0 * churned_users / NULLIF(total_users, 0), 2) as churn_rate_pct,
    ROUND(100.0 * inactive_90days / NULLIF(total_users, 0), 2) as inactive_90d_pct,
    ROUND(avg_days_since_login, 1) as avg_days_since_login
FROM cohort_metrics
ORDER BY cohort_month DESC, subscription_tier;

-- =====================================================
-- KPI 3: REFUND RATE & REFUND IMPACT
-- =====================================================
-- Business Question: What is our refund rate and financial impact?
-- Methodology: Calculate refunds as % of successful transactions

WITH transaction_summary AS (
    SELECT 
        DATE(transaction_date, 'start of month') as month,
        product_category,
        COUNT(*) as total_transactions,
        SUM(CASE WHEN transaction_status = 'success' THEN 1 ELSE 0 END) as successful_transactions,
        SUM(CASE WHEN transaction_status = 'success' THEN amount ELSE 0 END) as total_revenue
    FROM transactions
    GROUP BY DATE(transaction_date, 'start of month'), product_category
),
refund_summary AS (
    SELECT 
        DATE(r.refund_date, 'start of month') as month,
        t.product_category,
        COUNT(*) as total_refunds,
        SUM(r.refund_amount) as total_refund_amount,
        AVG(r.processing_time_days) as avg_processing_days
    FROM refunds r
    JOIN transactions t ON r.transaction_id = t.transaction_id
    WHERE r.refund_status IN ('processed', 'approved')
    GROUP BY DATE(r.refund_date, 'start of month'), t.product_category
)
SELECT 
    ts.month,
    ts.product_category,
    ts.total_transactions,
    ts.successful_transactions,
    ROUND(ts.total_revenue, 2) as gross_revenue,
    COALESCE(rs.total_refunds, 0) as refunds_count,
    ROUND(COALESCE(rs.total_refund_amount, 0), 2) as refunds_amount,
    ROUND(100.0 * COALESCE(rs.total_refunds, 0) / NULLIF(ts.successful_transactions, 0), 2) as refund_rate_pct,
    ROUND(100.0 * COALESCE(rs.total_refund_amount, 0) / NULLIF(ts.total_revenue, 0), 2) as refund_impact_pct,
    ROUND(ts.total_revenue - COALESCE(rs.total_refund_amount, 0), 2) as net_revenue,
    ROUND(COALESCE(rs.avg_processing_days, 0), 1) as avg_refund_processing_days
FROM transaction_summary ts
LEFT JOIN refund_summary rs 
    ON ts.month = rs.month 
    AND ts.product_category = rs.product_category
ORDER BY ts.month DESC, ts.product_category;

-- =====================================================
-- KPI 4: AVERAGE TICKET RESOLUTION TIME
-- =====================================================
-- Business Question: How efficiently are we resolving support tickets?
-- Methodology: Calculate avg resolution time by category and priority

WITH ticket_metrics AS (
    SELECT 
        ticket_category,
        priority,
        status,
        COUNT(*) as ticket_count,
        AVG(resolution_time_hours) as avg_resolution_hours,
        MIN(resolution_time_hours) as min_resolution_hours,
        MAX(resolution_time_hours) as max_resolution_hours,
        AVG(CASE WHEN satisfaction_rating IS NOT NULL THEN satisfaction_rating END) as avg_satisfaction,
        SUM(CASE WHEN satisfaction_rating <= 2 THEN 1 ELSE 0 END) as low_satisfaction_count
    FROM support_tickets
    WHERE status = 'resolved'
    GROUP BY ticket_category, priority
),
sla_benchmarks AS (
    SELECT 
        ticket_category,
        priority,
        ticket_count,
        ROUND(avg_resolution_hours, 2) as avg_resolution_hours,
        ROUND(min_resolution_hours, 2) as min_resolution_hours,
        ROUND(max_resolution_hours, 2) as max_resolution_hours,
        ROUND(avg_satisfaction, 2) as avg_satisfaction_rating,
        low_satisfaction_count,
        -- SLA targets: critical=4h, high=24h, medium=48h, low=72h
        CASE priority
            WHEN 'critical' THEN 4
            WHEN 'high' THEN 24
            WHEN 'medium' THEN 48
            WHEN 'low' THEN 72
        END as sla_target_hours
    FROM ticket_metrics
)
SELECT 
    ticket_category,
    priority,
    ticket_count,
    avg_resolution_hours,
    sla_target_hours,
    CASE 
        WHEN avg_resolution_hours <= sla_target_hours THEN 'Meeting SLA'
        ELSE 'Breach SLA'
    END as sla_status,
    ROUND(100.0 * (sla_target_hours - avg_resolution_hours) / NULLIF(sla_target_hours, 0), 2) as sla_performance_pct,
    avg_satisfaction_rating,
    low_satisfaction_count,
    min_resolution_hours,
    max_resolution_hours
FROM sla_benchmarks
ORDER BY 
    CASE priority WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END,
    ticket_category;

-- =====================================================
-- KPI 5: CUSTOMER LIFETIME VALUE (CLV) BY TIER
-- =====================================================
-- Business Question: What is the average lifetime value per customer segment?
-- Methodology: Calculate total spend, transaction frequency, and tenure

WITH user_value_metrics AS (
    SELECT 
        u.subscription_tier,
        u.user_id,
        u.total_spent,
        JULIANDAY('now') - JULIANDAY(u.signup_date) as tenure_days,
        COUNT(t.transaction_id) as transaction_count,
        AVG(t.amount) as avg_transaction_value,
        MAX(t.transaction_date) as last_transaction_date
    FROM users u
    LEFT JOIN transactions t 
        ON u.user_id = t.user_id 
        AND t.transaction_status = 'success'
    GROUP BY u.subscription_tier, u.user_id
),
tier_aggregates AS (
    SELECT 
        subscription_tier,
        COUNT(*) as total_customers,
        ROUND(AVG(total_spent), 2) as avg_lifetime_value,
        ROUND(AVG(tenure_days), 0) as avg_tenure_days,
        ROUND(AVG(transaction_count), 1) as avg_transactions_per_user,
        ROUND(AVG(avg_transaction_value), 2) as avg_order_value,
        ROUND(AVG(total_spent / NULLIF(tenure_days, 0) * 365), 2) as annual_value_per_user
    FROM user_value_metrics
    GROUP BY subscription_tier
)
SELECT 
    subscription_tier,
    total_customers,
    avg_lifetime_value as avg_clv,
    avg_tenure_days,
    ROUND(avg_tenure_days / 365.0, 1) as avg_tenure_years,
    avg_transactions_per_user,
    avg_order_value,
    annual_value_per_user,
    ROUND(avg_lifetime_value * total_customers, 2) as total_tier_value
FROM tier_aggregates
ORDER BY 
    CASE subscription_tier 
        WHEN 'enterprise' THEN 1 
        WHEN 'premium' THEN 2 
        WHEN 'basic' THEN 3 
        ELSE 4 
    END;

-- =====================================================
-- KPI 6: TRANSACTION SUCCESS RATE & FAILURE ANALYSIS
-- =====================================================
-- Business Question: What is our payment success rate and why do payments fail?
-- Methodology: Analyze transaction status distribution and failure reasons

WITH transaction_status_summary AS (
    SELECT 
        DATE(transaction_date, 'start of month') as month,
        payment_method,
        transaction_status,
        COUNT(*) as transaction_count,
        SUM(amount) as total_amount
    FROM transactions
    GROUP BY DATE(transaction_date, 'start of month'), payment_method, transaction_status
),
failure_reasons AS (
    SELECT 
        DATE(transaction_date, 'start of month') as month,
        failure_reason,
        COUNT(*) as failure_count
    FROM transactions
    WHERE transaction_status = 'failed'
    GROUP BY DATE(transaction_date, 'start of month'), failure_reason
)
SELECT 
    tss.month,
    tss.payment_method,
    SUM(tss.transaction_count) as total_attempts,
    SUM(CASE WHEN tss.transaction_status = 'success' THEN tss.transaction_count ELSE 0 END) as successful_count,
    SUM(CASE WHEN tss.transaction_status = 'failed' THEN tss.transaction_count ELSE 0 END) as failed_count,
    ROUND(100.0 * SUM(CASE WHEN tss.transaction_status = 'success' THEN tss.transaction_count ELSE 0 END) / 
        NULLIF(SUM(tss.transaction_count), 0), 2) as success_rate_pct,
    ROUND(SUM(CASE WHEN tss.transaction_status = 'success' THEN tss.total_amount ELSE 0 END), 2) as successful_amount,
    ROUND(SUM(CASE WHEN tss.transaction_status = 'failed' THEN tss.total_amount ELSE 0 END), 2) as failed_amount
FROM transaction_status_summary tss
GROUP BY tss.month, tss.payment_method
ORDER BY tss.month DESC, tss.payment_method;

-- =====================================================
-- KPI 7: USER COHORT RETENTION MATRIX
-- =====================================================
-- Business Question: How well do we retain users month-over-month?
-- Methodology: Cohort retention analysis with window functions

WITH user_monthly_activity AS (
    SELECT DISTINCT
        u.user_id,
        DATE(u.signup_date, 'start of month') as cohort_month,
        DATE(t.transaction_date, 'start of month') as activity_month,
        u.subscription_tier
    FROM users u
    LEFT JOIN transactions t 
        ON u.user_id = t.user_id 
        AND t.transaction_status = 'success'
),
cohort_size AS (
    SELECT 
        cohort_month,
        subscription_tier,
        COUNT(DISTINCT user_id) as cohort_users
    FROM user_monthly_activity
    GROUP BY cohort_month, subscription_tier
),
cohort_retention AS (
    SELECT 
        uma.cohort_month,
        uma.subscription_tier,
        uma.activity_month,
        COUNT(DISTINCT uma.user_id) as active_users,
        CAST((JULIANDAY(uma.activity_month) - JULIANDAY(uma.cohort_month)) / 30 AS INTEGER) as months_since_signup
    FROM user_monthly_activity uma
    WHERE uma.activity_month IS NOT NULL
    GROUP BY uma.cohort_month, uma.subscription_tier, uma.activity_month
)
SELECT 
    cr.cohort_month,
    cr.subscription_tier,
    cs.cohort_users,
    cr.months_since_signup,
    cr.active_users,
    ROUND(100.0 * cr.active_users / NULLIF(cs.cohort_users, 0), 2) as retention_rate_pct
FROM cohort_retention cr
JOIN cohort_size cs 
    ON cr.cohort_month = cs.cohort_month 
    AND cr.subscription_tier = cs.subscription_tier
WHERE cr.months_since_signup BETWEEN 0 AND 12
ORDER BY cr.cohort_month DESC, cr.subscription_tier, cr.months_since_signup;

-- =====================================================
-- KPI 8: USER RANKING BY ENGAGEMENT & SPEND
-- =====================================================
-- Business Question: Who are our top customers by various metrics?
-- Methodology: Window functions (ROW_NUMBER, RANK) for user segmentation

WITH user_engagement AS (
    SELECT 
        u.user_id,
        u.full_name,
        u.email,
        u.subscription_tier,
        u.total_spent,
        COUNT(DISTINCT t.transaction_id) as transaction_count,
        COUNT(DISTINCT st.ticket_id) as support_tickets,
        COUNT(DISTINCT r.refund_id) as refunds_count,
        MAX(t.transaction_date) as last_purchase_date,
        JULIANDAY('now') - JULIANDAY(MAX(t.transaction_date)) as days_since_purchase
    FROM users u
    LEFT JOIN transactions t ON u.user_id = t.user_id AND t.transaction_status = 'success'
    LEFT JOIN support_tickets st ON u.user_id = st.user_id
    LEFT JOIN refunds r ON u.user_id = r.user_id
    GROUP BY u.user_id, u.full_name, u.email, u.subscription_tier, u.total_spent
),
ranked_users AS (
    SELECT 
        user_id,
        full_name,
        email,
        subscription_tier,
        ROUND(total_spent, 2) as total_spent,
        transaction_count,
        support_tickets,
        refunds_count,
        last_purchase_date,
        ROUND(days_since_purchase, 0) as days_since_purchase,
        ROW_NUMBER() OVER (ORDER BY total_spent DESC) as rank_by_spend,
        ROW_NUMBER() OVER (ORDER BY transaction_count DESC) as rank_by_frequency,
        ROW_NUMBER() OVER (PARTITION BY subscription_tier ORDER BY total_spent DESC) as rank_within_tier,
        NTILE(4) OVER (ORDER BY total_spent DESC) as value_quartile
    FROM user_engagement
)
SELECT 
    rank_by_spend,
    user_id,
    full_name,
    subscription_tier,
    total_spent,
    transaction_count,
    support_tickets,
    refunds_count,
    rank_by_frequency,
    rank_within_tier,
    CASE value_quartile
        WHEN 1 THEN 'High Value'
        WHEN 2 THEN 'Medium-High Value'
        WHEN 3 THEN 'Medium-Low Value'
        ELSE 'Low Value'
    END as customer_segment,
    days_since_purchase,
    CASE 
        WHEN days_since_purchase <= 30 THEN 'Active'
        WHEN days_since_purchase <= 90 THEN 'At Risk'
        ELSE 'Churned'
    END as engagement_status
FROM ranked_users
WHERE rank_by_spend <= 50
ORDER BY rank_by_spend;

-- =====================================================
-- QUERY EXECUTION SUMMARY
-- =====================================================
-- Total KPIs: 8 comprehensive business metrics
-- Techniques demonstrated:
-- - CTEs for complex query organization
-- - Window functions (AVG, ROW_NUMBER, NTILE, RANK)
-- - Self-joins and multi-table joins
-- - Aggregations with conditional logic
-- - Cohort analysis and retention metrics
-- - Time-series analysis with moving averages
-- Output: Ready for CSV export and Power BI ingestion
-- =====================================================
