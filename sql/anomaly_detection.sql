-- =====================================================
-- Anomaly Detection Queries
-- =====================================================
-- Purpose: Identify unusual patterns, fraud, and business risks
-- Techniques: Statistical analysis, pattern detection, LAG/LEAD
-- Date: 2025-11-23
-- =====================================================

-- =====================================================
-- ANOMALY 1: TRANSACTION AMOUNT SPIKES
-- =====================================================
-- Business Question: Detect unusually high transactions (potential fraud)
-- Methodology: Flag transactions > 3 standard deviations from user's average

WITH user_transaction_stats AS (
    SELECT 
        user_id,
        AVG(amount) as avg_amount,
        STDDEV(amount) as stddev_amount,
        COUNT(*) as transaction_count,
        MIN(amount) as min_amount,
        MAX(amount) as max_amount
    FROM transactions
    WHERE transaction_status = 'success'
    GROUP BY user_id
    HAVING COUNT(*) >= 3  -- Only users with 3+ transactions for statistical significance
),
transaction_zscores AS (
    SELECT 
        t.transaction_id,
        t.user_id,
        t.transaction_date,
        t.amount,
        t.product_category,
        t.payment_method,
        uts.avg_amount,
        uts.stddev_amount,
        -- Z-score calculation: (value - mean) / stddev
        CASE 
            WHEN uts.stddev_amount > 0 
            THEN (t.amount - uts.avg_amount) / uts.stddev_amount
            ELSE 0
        END as z_score
    FROM transactions t
    JOIN user_transaction_stats uts ON t.user_id = uts.user_id
    WHERE t.transaction_status = 'success'
)
SELECT 
    transaction_id,
    user_id,
    transaction_date,
    ROUND(amount, 2) as transaction_amount,
    product_category,
    payment_method,
    ROUND(avg_amount, 2) as user_avg_amount,
    ROUND(stddev_amount, 2) as user_stddev_amount,
    ROUND(z_score, 2) as z_score,
    ROUND(amount / NULLIF(avg_amount, 0), 2) as amount_vs_avg_ratio,
    CASE 
        WHEN ABS(z_score) > 3 THEN 'Critical - Investigate Immediately'
        WHEN ABS(z_score) > 2 THEN 'High - Review Required'
        WHEN ABS(z_score) > 1.5 THEN 'Medium - Monitor'
        ELSE 'Normal'
    END as anomaly_severity
FROM transaction_zscores
WHERE ABS(z_score) > 1.5  -- Flag transactions with z-score > 1.5
ORDER BY ABS(z_score) DESC, transaction_date DESC
LIMIT 100;

-- =====================================================
-- ANOMALY 2: CONSECUTIVE PAYMENT FAILURES
-- =====================================================
-- Business Question: Detect repeated payment failures (fraud or card issues)
-- Methodology: Use LAG window function to find consecutive failures

WITH transaction_sequence AS (
    SELECT 
        transaction_id,
        user_id,
        transaction_date,
        amount,
        payment_method,
        transaction_status,
        failure_reason,
        -- Get previous transaction status for same user
        LAG(transaction_status, 1) OVER (PARTITION BY user_id ORDER BY transaction_date) as prev_status_1,
        LAG(transaction_status, 2) OVER (PARTITION BY user_id ORDER BY transaction_date) as prev_status_2,
        LAG(transaction_date, 1) OVER (PARTITION BY user_id ORDER BY transaction_date) as prev_date,
        -- Get time between transactions in minutes
        CAST((JULIANDAY(transaction_date) - JULIANDAY(LAG(transaction_date, 1) 
            OVER (PARTITION BY user_id ORDER BY transaction_date))) * 24 * 60 AS INTEGER) as minutes_since_last
    FROM transactions
    WHERE transaction_date >= DATE('now', '-180 days')
),
consecutive_failures AS (
    SELECT 
        user_id,
        transaction_id,
        transaction_date,
        amount,
        payment_method,
        failure_reason,
        prev_status_1,
        prev_status_2,
        minutes_since_last,
        -- Count consecutive failures
        CASE 
            WHEN transaction_status = 'failed' AND prev_status_1 = 'failed' AND prev_status_2 = 'failed' THEN 3
            WHEN transaction_status = 'failed' AND prev_status_1 = 'failed' THEN 2
            WHEN transaction_status = 'failed' THEN 1
            ELSE 0
        END as consecutive_failure_count
    FROM transaction_sequence
    WHERE transaction_status = 'failed'
)
SELECT 
    user_id,
    transaction_id,
    transaction_date,
    ROUND(amount, 2) as failed_amount,
    payment_method,
    failure_reason,
    consecutive_failure_count,
    minutes_since_last,
    CASE 
        WHEN consecutive_failure_count >= 3 THEN 'Critical - Possible Fraud/Block Card'
        WHEN consecutive_failure_count = 2 AND minutes_since_last <= 10 THEN 'High - Rapid Retry Pattern'
        WHEN consecutive_failure_count = 2 THEN 'Medium - Multiple Failures'
        ELSE 'Low - Single Failure'
    END as risk_level,
    CASE 
        WHEN minutes_since_last <= 5 THEN 'Immediate Retry (< 5 min)'
        WHEN minutes_since_last <= 60 THEN 'Quick Retry (< 1 hour)'
        ELSE 'Normal Retry'
    END as retry_pattern
FROM consecutive_failures
WHERE consecutive_failure_count >= 2
ORDER BY consecutive_failure_count DESC, transaction_date DESC;

-- =====================================================
-- ANOMALY 3: SUDDEN REFUND RATE SPIKE
-- =====================================================
-- Business Question: Detect unusual increases in refund requests
-- Methodology: Compare current refund rate to historical average

WITH daily_refund_metrics AS (
    SELECT 
        DATE(r.refund_date) as refund_day,
        t.product_category,
        COUNT(DISTINCT r.refund_id) as refunds_count,
        COUNT(DISTINCT r.user_id) as unique_refund_users,
        SUM(r.refund_amount) as total_refund_amount,
        -- Get successful transactions for same day
        (SELECT COUNT(*) 
         FROM transactions t2 
         WHERE DATE(t2.transaction_date) = DATE(r.refund_date)
         AND t2.product_category = t.product_category
         AND t2.transaction_status = 'success') as transactions_that_day
    FROM refunds r
    JOIN transactions t ON r.transaction_id = t.transaction_id
    WHERE r.refund_date >= DATE('now', '-180 days')
    GROUP BY DATE(r.refund_date), t.product_category
),
refund_statistics AS (
    SELECT 
        refund_day,
        product_category,
        refunds_count,
        unique_refund_users,
        total_refund_amount,
        transactions_that_day,
        ROUND(100.0 * refunds_count / NULLIF(transactions_that_day, 0), 2) as daily_refund_rate,
        -- Calculate 30-day moving average
        AVG(refunds_count) OVER (
            PARTITION BY product_category 
            ORDER BY refund_day 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) as avg_refunds_30day,
        AVG(100.0 * refunds_count / NULLIF(transactions_that_day, 0)) OVER (
            PARTITION BY product_category 
            ORDER BY refund_day 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) as avg_refund_rate_30day
    FROM daily_refund_metrics
)
SELECT 
    refund_day,
    product_category,
    refunds_count,
    unique_refund_users,
    ROUND(total_refund_amount, 2) as total_refund_amount,
    transactions_that_day,
    daily_refund_rate,
    ROUND(avg_refunds_30day, 1) as avg_refunds_30day,
    ROUND(avg_refund_rate_30day, 2) as avg_refund_rate_30day,
    ROUND(refunds_count / NULLIF(avg_refunds_30day, 0), 2) as spike_multiplier,
    CASE 
        WHEN refunds_count >= avg_refunds_30day * 3 THEN 'Critical Spike (3x+ normal)'
        WHEN refunds_count >= avg_refunds_30day * 2 THEN 'High Spike (2x+ normal)'
        WHEN refunds_count >= avg_refunds_30day * 1.5 THEN 'Moderate Spike (1.5x+ normal)'
        ELSE 'Normal'
    END as anomaly_status
FROM refund_statistics
WHERE refunds_count >= avg_refunds_30day * 1.5
ORDER BY refund_day DESC, spike_multiplier DESC;

-- =====================================================
-- ANOMALY 4: DORMANT USER REACTIVATION PATTERN
-- =====================================================
-- Business Question: Identify users returning after long inactivity (churn risk)
-- Methodology: Use LAG to find gaps in transaction history

WITH user_transaction_timeline AS (
    SELECT 
        t.user_id,
        u.full_name,
        u.email,
        u.subscription_tier,
        t.transaction_id,
        t.transaction_date,
        t.amount,
        -- Days since previous transaction
        CAST(JULIANDAY(t.transaction_date) - JULIANDAY(
            LAG(t.transaction_date) OVER (PARTITION BY t.user_id ORDER BY t.transaction_date)
        ) AS INTEGER) as days_since_last_transaction,
        -- Previous transaction amount
        LAG(t.amount) OVER (PARTITION BY t.user_id ORDER BY t.transaction_date) as prev_transaction_amount,
        -- Next transaction date (to see if they continue)
        LEAD(t.transaction_date) OVER (PARTITION BY t.user_id ORDER BY t.transaction_date) as next_transaction_date
    FROM transactions t
    JOIN users u ON t.user_id = u.user_id
    WHERE t.transaction_status = 'success'
)
SELECT 
    user_id,
    full_name,
    email,
    subscription_tier,
    transaction_id,
    transaction_date as reactivation_date,
    ROUND(amount, 2) as reactivation_amount,
    days_since_last_transaction as dormant_days,
    ROUND(days_since_last_transaction / 30.0, 1) as dormant_months,
    ROUND(prev_transaction_amount, 2) as previous_amount,
    next_transaction_date,
    CASE 
        WHEN next_transaction_date IS NULL THEN 'One-time Return (No Follow-up)'
        WHEN JULIANDAY(next_transaction_date) - JULIANDAY(transaction_date) <= 7 THEN 'Successful Reactivation'
        ELSE 'Partial Reactivation'
    END as reactivation_outcome,
    CASE 
        WHEN days_since_last_transaction >= 180 THEN 'Critical - Dormant 6+ months'
        WHEN days_since_last_transaction >= 90 THEN 'High - Dormant 3-6 months'
        WHEN days_since_last_transaction >= 60 THEN 'Medium - Dormant 2-3 months'
        ELSE 'Low - Short Gap'
    END as churn_risk_category
FROM user_transaction_timeline
WHERE days_since_last_transaction >= 60  -- Focus on users dormant for 2+ months
ORDER BY days_since_last_transaction DESC, transaction_date DESC
LIMIT 100;

-- =====================================================
-- ANOMALY 5: TICKET RESOLUTION TIME OUTLIERS
-- =====================================================
-- Business Question: Identify support tickets taking unusually long to resolve
-- Methodology: Statistical outlier detection for resolution times

WITH ticket_resolution_stats AS (
    SELECT 
        ticket_category,
        priority,
        AVG(resolution_time_hours) as avg_resolution,
        STDDEV(resolution_time_hours) as stddev_resolution,
        MIN(resolution_time_hours) as min_resolution,
        MAX(resolution_time_hours) as max_resolution,
        COUNT(*) as total_tickets
    FROM support_tickets
    WHERE status = 'resolved' 
    AND resolution_time_hours IS NOT NULL
    GROUP BY ticket_category, priority
),
ticket_outliers AS (
    SELECT 
        st.ticket_id,
        st.user_id,
        st.created_date,
        st.resolved_date,
        st.ticket_category,
        st.priority,
        st.resolution_time_hours,
        st.satisfaction_rating,
        st.agent_id,
        trs.avg_resolution,
        trs.stddev_resolution,
        -- Calculate z-score
        CASE 
            WHEN trs.stddev_resolution > 0 
            THEN (st.resolution_time_hours - trs.avg_resolution) / trs.stddev_resolution
            ELSE 0
        END as z_score
    FROM support_tickets st
    JOIN ticket_resolution_stats trs 
        ON st.ticket_category = trs.ticket_category 
        AND st.priority = trs.priority
    WHERE st.status = 'resolved'
    AND st.resolution_time_hours IS NOT NULL
)
SELECT 
    ticket_id,
    user_id,
    created_date,
    resolved_date,
    ticket_category,
    priority,
    ROUND(resolution_time_hours, 2) as resolution_hours,
    ROUND(resolution_time_hours / 24.0, 1) as resolution_days,
    ROUND(avg_resolution, 2) as category_avg_hours,
    ROUND(z_score, 2) as z_score,
    satisfaction_rating,
    agent_id,
    CASE 
        WHEN z_score > 3 THEN 'Critical Outlier (3+ SD)'
        WHEN z_score > 2 THEN 'High Outlier (2-3 SD)'
        WHEN z_score > 1.5 THEN 'Moderate Outlier (1.5-2 SD)'
        ELSE 'Normal'
    END as outlier_severity,
    CASE 
        WHEN satisfaction_rating <= 2 THEN 'Customer Dissatisfied'
        WHEN satisfaction_rating IS NULL THEN 'No Feedback'
        ELSE 'Acceptable Feedback'
    END as satisfaction_status
FROM ticket_outliers
WHERE z_score > 1.5
ORDER BY z_score DESC, created_date DESC
LIMIT 100;

-- =====================================================
-- ANOMALY 6: UNUSUAL LOGIN PATTERNS (User Behavior)
-- =====================================================
-- Business Question: Detect accounts with suspicious login/activity patterns
-- Methodology: Identify users with irregular time gaps between logins

WITH user_login_patterns AS (
    SELECT 
        user_id,
        full_name,
        email,
        subscription_tier,
        signup_date,
        last_login_date,
        CAST(JULIANDAY(last_login_date) - JULIANDAY(signup_date) AS INTEGER) as account_age_days,
        CAST(JULIANDAY('now') - JULIANDAY(last_login_date) AS INTEGER) as days_since_last_login,
        is_active,
        total_spent
    FROM users
),
transaction_activity AS (
    SELECT 
        user_id,
        COUNT(*) as total_transactions,
        COUNT(DISTINCT DATE(transaction_date)) as active_days,
        MIN(transaction_date) as first_transaction,
        MAX(transaction_date) as last_transaction
    FROM transactions
    WHERE transaction_status = 'success'
    GROUP BY user_id
)
SELECT 
    ulp.user_id,
    ulp.full_name,
    ulp.email,
    ulp.subscription_tier,
    ulp.account_age_days,
    ROUND(ulp.account_age_days / 365.0, 1) as account_age_years,
    ulp.days_since_last_login,
    ulp.is_active,
    ROUND(ulp.total_spent, 2) as total_spent,
    COALESCE(ta.total_transactions, 0) as total_transactions,
    COALESCE(ta.active_days, 0) as active_days,
    -- Calculate engagement rate
    ROUND(100.0 * COALESCE(ta.active_days, 0) / NULLIF(ulp.account_age_days, 0), 2) as engagement_rate_pct,
    CASE 
        WHEN ulp.total_spent > 10000 AND ulp.days_since_last_login > 90 THEN 'High Value - Churn Risk'
        WHEN ulp.total_spent > 10000 AND COALESCE(ta.total_transactions, 0) = 0 THEN 'High Spend - No Recent Activity'
        WHEN ulp.is_active = 1 AND ulp.days_since_last_login > 180 THEN 'Active Status - But Dormant'
        WHEN ulp.account_age_days > 365 AND COALESCE(ta.total_transactions, 0) < 3 THEN 'Old Account - Low Engagement'
        WHEN COALESCE(ta.active_days, 0) < 5 AND ulp.total_spent > 5000 THEN 'High Spend - Few Active Days (Anomaly)'
        ELSE 'Normal'
    END as behavior_anomaly
FROM user_login_patterns ulp
LEFT JOIN transaction_activity ta ON ulp.user_id = ta.user_id
WHERE 
    (ulp.total_spent > 10000 AND ulp.days_since_last_login > 90)
    OR (ulp.total_spent > 10000 AND COALESCE(ta.total_transactions, 0) = 0)
    OR (ulp.is_active = 1 AND ulp.days_since_last_login > 180)
    OR (ulp.account_age_days > 365 AND COALESCE(ta.total_transactions, 0) < 3)
    OR (COALESCE(ta.active_days, 0) < 5 AND ulp.total_spent > 5000)
ORDER BY ulp.total_spent DESC, ulp.days_since_last_login DESC;

-- =====================================================
-- ANOMALY 7: PAYMENT METHOD SWITCHING PATTERN
-- =====================================================
-- Business Question: Detect users rapidly switching payment methods (fraud indicator)
-- Methodology: Track payment method changes within short time windows

WITH payment_method_sequence AS (
    SELECT 
        user_id,
        transaction_id,
        transaction_date,
        amount,
        payment_method,
        transaction_status,
        -- Previous payment method
        LAG(payment_method) OVER (PARTITION BY user_id ORDER BY transaction_date) as prev_payment_method,
        -- Time since last transaction in hours
        CAST((JULIANDAY(transaction_date) - JULIANDAY(
            LAG(transaction_date) OVER (PARTITION BY user_id ORDER BY transaction_date)
        )) * 24 AS INTEGER) as hours_since_last,
        -- Count distinct payment methods used in last 24 hours
        COUNT(DISTINCT payment_method) OVER (
            PARTITION BY user_id 
            ORDER BY transaction_date 
            RANGE BETWEEN INTERVAL 1 DAY PRECEDING AND CURRENT ROW
        ) as payment_methods_24h
    FROM transactions
    WHERE transaction_date >= DATE('now', '-90 days')
),
method_switches AS (
    SELECT 
        user_id,
        transaction_id,
        transaction_date,
        ROUND(amount, 2) as amount,
        payment_method,
        prev_payment_method,
        hours_since_last,
        payment_methods_24h,
        transaction_status,
        CASE 
            WHEN payment_method != prev_payment_method THEN 1 
            ELSE 0 
        END as is_method_switch
    FROM payment_method_sequence
    WHERE prev_payment_method IS NOT NULL
)
SELECT 
    user_id,
    transaction_id,
    transaction_date,
    amount,
    payment_method,
    prev_payment_method,
    hours_since_last,
    payment_methods_24h,
    transaction_status,
    CASE 
        WHEN payment_methods_24h >= 4 THEN 'Critical - 4+ Methods in 24h'
        WHEN payment_methods_24h = 3 AND hours_since_last <= 2 THEN 'High - Rapid Method Switching'
        WHEN payment_methods_24h = 3 THEN 'Medium - Multiple Methods'
        WHEN is_method_switch = 1 AND hours_since_last <= 1 THEN 'Medium - Quick Method Change'
        ELSE 'Normal'
    END as fraud_risk_level
FROM method_switches
WHERE 
    payment_methods_24h >= 3 
    OR (is_method_switch = 1 AND hours_since_last <= 1)
ORDER BY payment_methods_24h DESC, transaction_date DESC
LIMIT 100;

-- =====================================================
-- QUERY EXECUTION SUMMARY
-- =====================================================
-- Total Anomaly Detections: 7 critical patterns
-- Techniques demonstrated:
-- - Statistical analysis (Z-scores, standard deviation)
-- - Window functions (LAG, LEAD, moving averages)
-- - Pattern detection (consecutive failures, spikes)
-- - Behavioral analysis (dormancy, reactivation)
-- - Fraud indicators (rapid retries, method switching)
-- Use cases: Fraud prevention, risk management, customer retention
-- Output: Actionable alerts for business operations team
-- =====================================================
