-- =====================================================
-- Operational Analytics Dashboard - Table Schema
-- =====================================================
-- Purpose: Create normalized database schema for business analytics
-- Tables: users, transactions, support_tickets, refunds
-- Date: 2025-11-23
-- =====================================================

-- Drop tables if they exist (for clean recreation)
DROP TABLE IF EXISTS refunds;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS users;

-- =====================================================
-- USERS TABLE
-- =====================================================
-- Stores customer/user information
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    country VARCHAR(100) NOT NULL,
    signup_date DATE NOT NULL,
    subscription_tier VARCHAR(50) NOT NULL, -- 'free', 'basic', 'premium', 'enterprise'
    is_active BOOLEAN DEFAULT 1,
    last_login_date DATETIME,
    total_spent DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster queries on signup_date and subscription_tier
CREATE INDEX idx_users_signup ON users(signup_date);
CREATE INDEX idx_users_tier ON users(subscription_tier);
CREATE INDEX idx_users_active ON users(is_active);

-- =====================================================
-- TRANSACTIONS TABLE
-- =====================================================
-- Stores all financial transactions (purchases, payments)
CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    transaction_date DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    payment_method VARCHAR(50) NOT NULL, -- 'credit_card', 'debit_card', 'upi', 'net_banking', 'wallet'
    transaction_status VARCHAR(50) NOT NULL, -- 'success', 'failed', 'pending', 'cancelled'
    product_category VARCHAR(100), -- 'electronics', 'fashion', 'groceries', 'services', etc.
    is_first_purchase BOOLEAN DEFAULT 0,
    failure_reason VARCHAR(255), -- populated if status = 'failed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Indexes for analytical queries
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_status ON transactions(transaction_status);
CREATE INDEX idx_transactions_amount ON transactions(amount);

-- =====================================================
-- SUPPORT TICKETS TABLE
-- =====================================================
-- Stores customer support requests and their resolution
CREATE TABLE support_tickets (
    ticket_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    created_date DATETIME NOT NULL,
    resolved_date DATETIME,
    ticket_category VARCHAR(100) NOT NULL, -- 'billing', 'technical', 'refund', 'account', 'general'
    priority VARCHAR(20) NOT NULL, -- 'low', 'medium', 'high', 'critical'
    status VARCHAR(50) NOT NULL, -- 'open', 'in_progress', 'resolved', 'closed', 'escalated'
    resolution_time_hours DECIMAL(10, 2), -- calculated when resolved
    satisfaction_rating INTEGER, -- 1-5 scale, NULL if not provided
    agent_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Indexes for support analytics
CREATE INDEX idx_tickets_user ON support_tickets(user_id);
CREATE INDEX idx_tickets_created ON support_tickets(created_date);
CREATE INDEX idx_tickets_status ON support_tickets(status);
CREATE INDEX idx_tickets_category ON support_tickets(ticket_category);

-- =====================================================
-- REFUNDS TABLE
-- =====================================================
-- Stores refund requests and their processing
CREATE TABLE refunds (
    refund_id INTEGER PRIMARY KEY,
    transaction_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    refund_date DATETIME NOT NULL,
    refund_amount DECIMAL(10, 2) NOT NULL,
    refund_reason VARCHAR(255) NOT NULL, -- 'product_defect', 'wrong_item', 'not_satisfied', 'cancelled_order', etc.
    refund_status VARCHAR(50) NOT NULL, -- 'requested', 'approved', 'rejected', 'processed'
    processing_time_days INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Indexes for refund analytics
CREATE INDEX idx_refunds_transaction ON refunds(transaction_id);
CREATE INDEX idx_refunds_user ON refunds(user_id);
CREATE INDEX idx_refunds_date ON refunds(refund_date);
CREATE INDEX idx_refunds_status ON refunds(refund_status);

-- =====================================================
-- SUMMARY
-- =====================================================
-- Total tables created: 4
-- Total indexes created: 16
-- Relationships: Fully normalized with foreign key constraints
-- Ready for: Seed data insertion and analytical queries
-- =====================================================
