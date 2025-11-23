-- =====================================================
-- Operational Analytics Dashboard - Seed Data
-- =====================================================
-- Purpose: Generate realistic sample data for analytics
-- Records: 1000 users, 5000+ transactions, 800+ tickets, 150+ refunds
-- Date: 2025-11-23
-- =====================================================

-- =====================================================
-- SEED USERS TABLE (1000 records)
-- =====================================================
-- Generate diverse user base across subscription tiers and countries

INSERT INTO users (user_id, email, full_name, country, signup_date, subscription_tier, is_active, last_login_date, total_spent) VALUES
-- Premium users (high value customers)
(1, 'rajesh.kumar@email.com', 'Rajesh Kumar', 'India', '2023-01-15', 'premium', 1, '2025-11-22', 45000.00),
(2, 'priya.sharma@email.com', 'Priya Sharma', 'India', '2023-02-20', 'premium', 1, '2025-11-23', 38500.00),
(3, 'amit.patel@email.com', 'Amit Patel', 'India', '2023-03-10', 'premium', 1, '2025-11-21', 52000.00),
(4, 'sneha.reddy@email.com', 'Sneha Reddy', 'India', '2023-01-25', 'enterprise', 1, '2025-11-23', 125000.00),
(5, 'vikram.singh@email.com', 'Vikram Singh', 'India', '2023-04-05', 'premium', 1, '2025-11-20', 41000.00),
(6, 'ananya.iyer@email.com', 'Ananya Iyer', 'India', '2023-02-14', 'enterprise', 1, '2025-11-22', 98000.00),
(7, 'rohit.mehta@email.com', 'Rohit Mehta', 'India', '2023-05-20', 'premium', 1, '2025-11-23', 35000.00),
(8, 'kavya.nair@email.com', 'Kavya Nair', 'India', '2023-03-18', 'premium', 0, '2025-09-10', 28000.00),
(9, 'arjun.gupta@email.com', 'Arjun Gupta', 'India', '2023-06-12', 'premium', 1, '2025-11-21', 47000.00),
(10, 'diya.shah@email.com', 'Diya Shah', 'India', '2023-04-25', 'enterprise', 1, '2025-11-23', 145000.00),

-- Basic tier users (moderate engagement)
(11, 'john.doe@email.com', 'John Doe', 'USA', '2023-07-10', 'basic', 1, '2025-11-22', 12000.00),
(12, 'emily.chen@email.com', 'Emily Chen', 'USA', '2023-08-15', 'basic', 1, '2025-11-20', 9500.00),
(13, 'michael.brown@email.com', 'Michael Brown', 'UK', '2023-09-05', 'basic', 1, '2025-11-23', 11000.00),
(14, 'sarah.wilson@email.com', 'Sarah Wilson', 'Canada', '2023-07-22', 'basic', 1, '2025-11-21', 8700.00),
(15, 'david.martinez@email.com', 'David Martinez', 'USA', '2023-10-03', 'basic', 1, '2025-11-22', 10500.00),
(16, 'lisa.anderson@email.com', 'Lisa Anderson', 'Australia', '2023-08-28', 'basic', 0, '2025-08-15', 7200.00),
(17, 'james.taylor@email.com', 'James Taylor', 'UK', '2023-11-12', 'basic', 1, '2025-11-23', 9800.00),
(18, 'olivia.white@email.com', 'Olivia White', 'USA', '2023-09-19', 'basic', 1, '2025-11-20', 11500.00),
(19, 'daniel.lee@email.com', 'Daniel Lee', 'Singapore', '2023-12-01', 'basic', 1, '2025-11-22', 13000.00),
(20, 'sophia.garcia@email.com', 'Sophia Garcia', 'USA', '2024-01-10', 'basic', 1, '2025-11-21', 8900.00),

-- Free tier users (high volume, low engagement)
(21, 'user001@email.com', 'Aarav Verma', 'India', '2024-02-15', 'free', 1, '2025-11-23', 1200.00),
(22, 'user002@email.com', 'Isha Kapoor', 'India', '2024-03-20', 'free', 1, '2025-11-22', 800.00),
(23, 'user003@email.com', 'Vivaan Joshi', 'India', '2024-04-10', 'free', 0, '2025-06-12', 450.00),
(24, 'user004@email.com', 'Aanya Desai', 'India', '2024-02-28', 'free', 1, '2025-11-21', 950.00),
(25, 'user005@email.com', 'Reyansh Kumar', 'India', '2024-05-05', 'free', 1, '2025-11-23', 1100.00),
(26, 'user006@email.com', 'Kiara Singh', 'India', '2024-03-14', 'free', 1, '2025-11-20', 720.00),
(27, 'user007@email.com', 'Advik Sharma', 'India', '2024-06-22', 'free', 1, '2025-11-22', 890.00),
(28, 'user008@email.com', 'Myra Patel', 'India', '2024-04-18', 'free', 0, '2025-07-30', 320.00),
(29, 'user009@email.com', 'Vihaan Reddy', 'India', '2024-07-09', 'free', 1, '2025-11-23', 1050.00),
(30, 'user010@email.com', 'Saanvi Gupta', 'India', '2024-05-25', 'free', 1, '2025-11-21', 680.00);

-- Continue with more diverse seed data (patterns: seasonal signups, churn, reactivation)
-- Note: In production, this would be a script generating 1000 rows with realistic distributions
-- For demonstration, showing pattern samples across all tiers and behaviors

-- Additional premium users with varied activity patterns
INSERT INTO users (user_id, email, full_name, country, signup_date, subscription_tier, is_active, last_login_date, total_spent) VALUES
(31, 'neha.agarwal@email.com', 'Neha Agarwal', 'India', '2024-01-20', 'premium', 1, '2025-11-23', 32000.00),
(32, 'karan.malhotra@email.com', 'Karan Malhotra', 'India', '2024-02-12', 'premium', 1, '2025-11-22', 29000.00),
(33, 'pooja.bhatia@email.com', 'Pooja Bhatia', 'India', '2024-03-08', 'premium', 0, '2025-10-05', 18000.00),
(34, 'rahul.chopra@email.com', 'Rahul Chopra', 'India', '2024-04-15', 'premium', 1, '2025-11-21', 36000.00),
(35, 'simran.kaur@email.com', 'Simran Kaur', 'India', '2024-05-22', 'premium', 1, '2025-11-23', 31500.00);

-- Enterprise users (highest value, lowest churn)
INSERT INTO users (user_id, email, full_name, country, signup_date, subscription_tier, is_active, last_login_date, total_spent) VALUES
(36, 'techcorp.admin@email.com', 'Tech Corp Admin', 'USA', '2023-01-10', 'enterprise', 1, '2025-11-23', 350000.00),
(37, 'financeplus.manager@email.com', 'Finance Plus Manager', 'UK', '2023-02-15', 'enterprise', 1, '2025-11-22', 285000.00),
(38, 'retail.analytics@email.com', 'Retail Analytics Team', 'India', '2023-03-20', 'enterprise', 1, '2025-11-23', 420000.00),
(39, 'healthcare.ops@email.com', 'Healthcare Ops', 'USA', '2023-04-05', 'enterprise', 1, '2025-11-21', 195000.00),
(40, 'ecommerce.lead@email.com', 'Ecommerce Lead', 'Singapore', '2023-05-12', 'enterprise', 1, '2025-11-23', 310000.00);

-- Bulk user generation placeholder (representing remaining 960 users)
-- Pattern: 70% free, 20% basic, 8% premium, 2% enterprise
-- Geographic distribution: 60% India, 20% USA, 10% UK, 10% Others
-- Activity: 85% active, 15% churned

-- =====================================================
-- SEED TRANSACTIONS TABLE (5000+ records)
-- =====================================================
-- Generate realistic transaction patterns with anomalies

-- Successful premium user transactions
INSERT INTO transactions (transaction_id, user_id, transaction_date, amount, currency, payment_method, transaction_status, product_category, is_first_purchase, failure_reason) VALUES
(1, 1, '2023-01-16 10:30:00', 5000.00, 'INR', 'credit_card', 'success', 'electronics', 1, NULL),
(2, 1, '2023-02-20 14:45:00', 3500.00, 'INR', 'credit_card', 'success', 'fashion', 0, NULL),
(3, 1, '2023-03-15 09:20:00', 8000.00, 'INR', 'upi', 'success', 'electronics', 0, NULL),
(4, 1, '2023-04-22 16:10:00', 2500.00, 'INR', 'credit_card', 'success', 'groceries', 0, NULL),
(5, 1, '2023-05-30 11:55:00', 12000.00, 'INR', 'credit_card', 'success', 'electronics', 0, NULL),
(6, 1, '2023-07-18 13:40:00', 4500.00, 'INR', 'upi', 'success', 'fashion', 0, NULL),
(7, 1, '2023-09-10 10:15:00', 9500.00, 'INR', 'credit_card', 'success', 'electronics', 0, NULL),

(8, 2, '2023-02-21 11:20:00', 4200.00, 'INR', 'debit_card', 'success', 'fashion', 1, NULL),
(9, 2, '2023-03-28 15:30:00', 6800.00, 'INR', 'upi', 'success', 'electronics', 0, NULL),
(10, 2, '2023-05-12 09:45:00', 3200.00, 'INR', 'debit_card', 'success', 'groceries', 0, NULL),
(11, 2, '2023-06-25 14:20:00', 7500.00, 'INR', 'credit_card', 'success', 'electronics', 0, NULL),
(12, 2, '2023-08-14 10:50:00', 5300.00, 'INR', 'upi', 'success', 'fashion', 0, NULL),
(13, 2, '2023-10-05 16:15:00', 11500.00, 'INR', 'credit_card', 'success', 'electronics', 0, NULL),

-- Failed transactions (demonstrating anomaly patterns)
(14, 3, '2023-03-11 10:30:00', 15000.00, 'INR', 'credit_card', 'failed', 'electronics', 0, 'insufficient_funds'),
(15, 3, '2023-03-11 10:35:00', 15000.00, 'INR', 'credit_card', 'failed', 'electronics', 0, 'card_declined'),
(16, 3, '2023-03-11 10:40:00', 14500.00, 'INR', 'debit_card', 'success', 'electronics', 0, NULL),
(17, 5, '2023-04-10 14:20:00', 8500.00, 'INR', 'net_banking', 'failed', 'services', 0, 'session_timeout'),
(18, 7, '2023-06-15 09:15:00', 5200.00, 'INR', 'upi', 'failed', 'fashion', 0, 'payment_gateway_error'),

-- High-value enterprise transactions
(19, 4, '2023-01-26 11:00:00', 50000.00, 'INR', 'net_banking', 'success', 'services', 1, NULL),
(20, 4, '2023-03-15 14:30:00', 35000.00, 'INR', 'net_banking', 'success', 'electronics', 0, NULL),
(21, 4, '2023-05-20 10:45:00', 40000.00, 'INR', 'net_banking', 'success', 'services', 0, NULL),

(22, 6, '2023-02-15 09:30:00', 45000.00, 'INR', 'credit_card', 'success', 'electronics', 1, NULL),
(23, 6, '2023-04-22 13:20:00', 28000.00, 'INR', 'credit_card', 'success', 'services', 0, NULL),
(24, 6, '2023-07-10 15:40:00', 25000.00, 'INR', 'upi', 'success', 'fashion', 0, NULL),

-- Anomaly: Sudden spike in transaction amount
(25, 9, '2023-06-13 10:00:00', 3000.00, 'INR', 'upi', 'success', 'groceries', 0, NULL),
(26, 9, '2023-06-14 11:30:00', 4500.00, 'INR', 'credit_card', 'success', 'fashion', 0, NULL),
(27, 9, '2023-06-15 09:45:00', 95000.00, 'INR', 'credit_card', 'success', 'electronics', 0, NULL), -- ANOMALY: 20x spike
(28, 9, '2023-06-16 14:20:00', 3800.00, 'INR', 'upi', 'success', 'groceries', 0, NULL),

-- Basic tier transactions
(29, 11, '2023-07-11 10:20:00', 1500.00, 'USD', 'credit_card', 'success', 'fashion', 1, NULL),
(30, 11, '2023-08-22 14:35:00', 2200.00, 'USD', 'credit_card', 'success', 'electronics', 0, NULL),
(31, 11, '2023-10-15 09:50:00', 1800.00, 'USD', 'debit_card', 'success', 'groceries', 0, NULL),
(32, 11, '2024-01-20 11:30:00', 3500.00, 'USD', 'credit_card', 'success', 'electronics', 0, NULL),
(33, 11, '2024-04-18 15:45:00', 3000.00, 'USD', 'credit_card', 'success', 'fashion', 0, NULL),

(34, 12, '2023-08-16 09:15:00', 950.00, 'USD', 'debit_card', 'success', 'groceries', 1, NULL),
(35, 12, '2023-09-28 13:40:00', 1800.00, 'USD', 'credit_card', 'success', 'fashion', 0, NULL),
(36, 12, '2023-11-10 10:25:00', 2500.00, 'USD', 'credit_card', 'success', 'electronics', 0, NULL),
(37, 12, '2024-02-14 14:50:00', 1200.00, 'USD', 'debit_card', 'failed', 'groceries', 0, 'card_expired'),
(38, 12, '2024-02-14 15:10:00', 1200.00, 'USD', 'credit_card', 'success', 'groceries', 0, NULL),

-- Free tier transactions (smaller amounts)
(39, 21, '2024-02-16 10:30:00', 250.00, 'INR', 'upi', 'success', 'groceries', 1, NULL),
(40, 21, '2024-03-20 14:20:00', 180.00, 'INR', 'wallet', 'success', 'groceries', 0, NULL),
(41, 21, '2024-05-15 09:40:00', 420.00, 'INR', 'upi', 'success', 'fashion', 0, NULL),
(42, 21, '2024-07-22 11:55:00', 350.00, 'INR', 'upi', 'success', 'groceries', 0, NULL),

(43, 22, '2024-03-21 13:10:00', 190.00, 'INR', 'wallet', 'success', 'groceries', 1, NULL),
(44, 22, '2024-04-18 10:45:00', 280.00, 'INR', 'upi', 'success', 'fashion', 0, NULL),
(45, 22, '2024-06-10 15:30:00', 330.00, 'INR', 'wallet', 'failed', 'groceries', 0, 'insufficient_balance'),

-- Recent transactions (2025) - showing current activity
(46, 1, '2025-01-15 10:20:00', 7500.00, 'INR', 'credit_card', 'success', 'electronics', 0, NULL),
(47, 1, '2025-03-22 14:40:00', 4200.00, 'INR', 'upi', 'success', 'fashion', 0, NULL),
(48, 1, '2025-06-18 09:30:00', 9800.00, 'INR', 'credit_card', 'success', 'electronics', 0, NULL),
(49, 1, '2025-09-10 11:50:00', 6500.00, 'INR', 'credit_card', 'success', 'services', 0, NULL),
(50, 1, '2025-11-05 15:20:00', 11000.00, 'INR', 'credit_card', 'success', 'electronics', 0, NULL);

-- Additional transactions showing payment failures in sequence (fraud detection pattern)
INSERT INTO transactions (transaction_id, user_id, transaction_date, amount, currency, payment_method, transaction_status, product_category, is_first_purchase, failure_reason) VALUES
(51, 15, '2025-10-10 10:00:00', 2500.00, 'USD', 'credit_card', 'failed', 'electronics', 0, 'cvv_mismatch'),
(52, 15, '2025-10-10 10:05:00', 2500.00, 'USD', 'credit_card', 'failed', 'electronics', 0, 'cvv_mismatch'),
(53, 15, '2025-10-10 10:10:00', 2500.00, 'USD', 'credit_card', 'failed', 'electronics', 0, 'card_blocked'), -- Blocked after 3 attempts
(54, 15, '2025-10-11 09:30:00', 2500.00, 'USD', 'debit_card', 'success', 'electronics', 0, NULL);

-- Bulk placeholder for remaining ~4950 transactions
-- Distribution: 85% success, 10% failed, 5% pending/cancelled
-- Payment methods: 40% credit_card, 30% UPI, 15% debit_card, 10% net_banking, 5% wallet
-- Categories: 35% electronics, 25% fashion, 20% groceries, 15% services, 5% others

-- =====================================================
-- SEED SUPPORT TICKETS TABLE (800+ records)
-- =====================================================

INSERT INTO support_tickets (ticket_id, user_id, created_date, resolved_date, ticket_category, priority, status, resolution_time_hours, satisfaction_rating, agent_id) VALUES
-- Resolved tickets with varying resolution times
(1, 1, '2023-02-10 09:30:00', '2023-02-10 11:45:00', 'technical', 'high', 'resolved', 2.25, 5, 101),
(2, 2, '2023-03-15 14:20:00', '2023-03-16 10:30:00', 'billing', 'medium', 'resolved', 20.17, 4, 102),
(3, 3, '2023-03-11 11:00:00', '2023-03-11 11:30:00', 'refund', 'high', 'resolved', 0.5, 5, 103),
(4, 5, '2023-04-20 10:15:00', '2023-04-22 16:45:00', 'technical', 'low', 'resolved', 54.5, 3, 101),
(5, 7, '2023-06-25 15:30:00', '2023-06-25 17:20:00', 'account', 'medium', 'resolved', 1.83, 4, 104),

-- Open/In-progress tickets (showing current workload)
(6, 4, '2025-11-20 10:00:00', NULL, 'technical', 'critical', 'in_progress', NULL, NULL, 101),
(7, 6, '2025-11-21 14:30:00', NULL, 'billing', 'high', 'open', NULL, NULL, NULL),
(8, 9, '2025-11-22 09:15:00', NULL, 'refund', 'medium', 'in_progress', NULL, NULL, 102),
(9, 11, '2025-11-23 08:45:00', NULL, 'general', 'low', 'open', NULL, NULL, NULL),

-- Escalated tickets (high priority issues)
(10, 10, '2025-11-15 11:20:00', NULL, 'billing', 'critical', 'escalated', NULL, NULL, 105),
(11, 36, '2025-11-18 13:00:00', '2025-11-19 09:30:00', 'technical', 'critical', 'resolved', 20.5, 5, 105),

-- Tickets with low satisfaction (areas for improvement)
(12, 8, '2023-08-10 10:30:00', '2023-08-15 14:20:00', 'billing', 'medium', 'resolved', 123.83, 1, 102),
(13, 16, '2023-09-05 09:45:00', '2023-09-12 11:30:00', 'technical', 'high', 'resolved', 169.75, 2, 101),
(14, 23, '2024-05-20 14:15:00', '2024-05-28 16:40:00', 'refund', 'medium', 'resolved', 194.42, 1, 103),

-- Quick resolution tickets (benchmark for excellence)
(15, 21, '2024-07-10 10:00:00', '2024-07-10 10:25:00', 'general', 'low', 'resolved', 0.42, 5, 104),
(16, 22, '2024-08-15 11:30:00', '2024-07-15 12:10:00', 'account', 'medium', 'resolved', 0.67, 5, 102),
(17, 25, '2024-09-20 09:15:00', '2024-09-20 10:00:00', 'general', 'low', 'resolved', 0.75, 4, 103),

-- Refund category tickets (correlate with refunds table)
(18, 11, '2023-12-10 10:30:00', '2023-12-11 14:20:00', 'refund', 'high', 'resolved', 27.83, 4, 103),
(19, 12, '2024-02-14 15:30:00', '2024-02-15 09:45:00', 'refund', 'medium', 'resolved', 18.25, 5, 103),
(20, 15, '2025-10-11 10:00:00', '2025-10-12 11:30:00', 'billing', 'high', 'resolved', 25.5, 4, 102);

-- Bulk placeholder for remaining ~780 tickets
-- Category distribution: 30% technical, 25% billing, 20% refund, 15% account, 10% general
-- Priority: 10% critical, 25% high, 40% medium, 25% low
-- Status: 70% resolved, 15% in_progress, 10% open, 5% escalated
-- Average resolution time: 24-48 hours (medium), <4 hours (low), 48-72 hours (high)

-- =====================================================
-- SEED REFUNDS TABLE (150+ records)
-- =====================================================

INSERT INTO refunds (refund_id, transaction_id, user_id, refund_date, refund_amount, refund_reason, refund_status, processing_time_days) VALUES
-- Processed refunds
(1, 14, 3, '2023-03-13 14:30:00', 15000.00, 'transaction_failed', 'processed', 2),
(2, 17, 5, '2023-04-12 10:45:00', 8500.00, 'transaction_failed', 'processed', 2),
(3, 18, 7, '2023-06-17 11:20:00', 5200.00, 'transaction_failed', 'processed', 2),
(4, 37, 12, '2024-02-16 09:30:00', 1200.00, 'product_defect', 'processed', 3),
(5, 45, 22, '2024-06-12 14:15:00', 330.00, 'not_satisfied', 'processed', 4),

-- Requested refunds (pending processing)
(6, 50, 1, '2025-11-10 16:20:00', 11000.00, 'wrong_item', 'requested', NULL),
(7, 54, 15, '2025-11-15 10:30:00', 2500.00, 'cancelled_order', 'approved', 3),

-- Rejected refunds (showing edge cases)
(8, 29, 11, '2023-08-10 11:00:00', 1500.00, 'changed_mind', 'rejected', 1),
(9, 39, 21, '2024-03-01 10:15:00', 250.00, 'no_longer_needed', 'rejected', 1),

-- High-value refunds (enterprise customers)
(10, 19, 4, '2023-02-05 09:30:00', 50000.00, 'service_not_delivered', 'processed', 5),
(11, 22, 6, '2023-02-20 14:45:00', 45000.00, 'product_defect', 'processed', 4),

-- Bulk refunds (pattern: product recall scenario)
(12, 30, 11, '2023-11-01 10:00:00', 2200.00, 'product_recall', 'processed', 2),
(13, 35, 12, '2023-11-01 10:05:00', 1800.00, 'product_recall', 'processed', 2),
(14, 42, 21, '2024-08-15 10:10:00', 350.00, 'product_recall', 'processed', 2);

-- Bulk placeholder for remaining ~136 refunds
-- Refund rate: ~3% of successful transactions (realistic e-commerce rate)
-- Reasons: 40% product_defect, 25% not_satisfied, 15% wrong_item, 10% cancelled_order, 10% others
-- Status: 80% processed, 10% approved, 7% requested, 3% rejected
-- Processing time: 2-5 days average

-- =====================================================
-- DATA SEEDING COMPLETE
-- =====================================================
-- Total records inserted:
-- - Users: 40 (representative sample, script would generate 1000)
-- - Transactions: 54 (representative sample, script would generate 5000+)
-- - Support Tickets: 20 (representative sample, script would generate 800+)
-- - Refunds: 14 (representative sample, script would generate 150+)
--
-- Key patterns demonstrated:
-- - User lifecycle: signup -> transactions -> possible issues -> refunds/tickets
-- - Transaction anomalies: spikes, repeated failures, fraud patterns
-- - Support ticket resolution times and satisfaction metrics
-- - Refund processing workflows
-- - Realistic data distributions across tiers and behaviors
-- =====================================================
