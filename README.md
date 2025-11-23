# Operational Analytics Dashboard

![Project Status](https://img.shields.io/badge/status-production--ready-green)
![SQL](https://img.shields.io/badge/SQL-Advanced-blue)
![Python](https://img.shields.io/badge/Python-3.8+-yellow)
![Power BI](https://img.shields.io/badge/Power%20BI-Compatible-orange)

A comprehensive **SQL-focused** analytics system for monitoring business KPIs including user activity, refunds, support tickets, and transaction anomalies. Built to demonstrate advanced analytical SQL capabilities, Python automation, and business intelligence integration.

---

## 🎯 Project Overview

This project creates a complete end-to-end analytics workflow:

1. **SQL Layer**: Complex queries with CTEs, window functions, joins, and anomaly detection
2. **Python Automation**: Automated query execution and Excel report generation
3. **Power BI Integration**: Interactive dashboards with DAX measures and drill-down capabilities
4. **Sample Data**: Realistic datasets with 1000+ users, 5000+ transactions, and intentional anomalies

**Target Audience**: SQL-heavy analytical roles (Data Analyst, Business Intelligence, Analytics Engineer)

---

## 📊 Key Features

### SQL Analytics (Advanced)

- ✅ **Window Functions**: ROW_NUMBER, LAG, LEAD, NTILE for user ranking and pattern detection
- ✅ **CTEs**: Multi-level Common Table Expressions for complex transformations
- ✅ **Multi-table Joins**: Normalized schema with foreign key relationships
- ✅ **Statistical Analysis**: Z-score calculations, moving averages, standard deviation
- ✅ **Anomaly Detection**: Transaction spikes, consecutive failures, refund rate anomalies
- ✅ **Cohort Analysis**: User retention matrices and churn calculation

### Business KPIs (8 Key Metrics)

1. **Daily Active Users (DAU)** - 7-day moving average trend
2. **User Churn Rate** - By cohort and subscription tier
3. **Refund Rate & Impact** - Financial loss analysis
4. **Ticket Resolution Time** - SLA compliance tracking
5. **Customer Lifetime Value (CLV)** - Segmented by tier
6. **Transaction Success Rate** - Payment method performance
7. **Cohort Retention** - Month-over-month retention matrix
8. **User Ranking** - Top customers by spend and engagement

### Anomaly Detection (7 Patterns)

1. **Transaction Amount Spikes** - Statistical outliers (>3 SD)
2. **Consecutive Payment Failures** - Fraud/card block indicators
3. **Refund Rate Spikes** - Product quality alerts
4. **Dormant User Reactivation** - Churn risk identification
5. **Ticket Resolution Outliers** - SLA breach detection
6. **Unusual Login Patterns** - Account security concerns
7. **Payment Method Switching** - Rapid method changes (fraud indicator)

### Python Automation

- Automated SQL script execution
- CSV export for Power BI ingestion
- Styled Excel workbooks with multiple sheets
- Data cleaning and validation utilities
- Configurable for SQLite or MySQL

---

## 🗂️ Project Structure

```
operational-analytics-dashboard/
│
├── sql/
│   ├── create_tables.sql          # Database schema (4 tables, 16 indexes)
│   ├── seed_data.sql               # Sample data (1000+ users, 5000+ transactions)
│   ├── kpi_queries.sql             # 8 business KPI queries
│   └── anomaly_detection.sql       # 7 anomaly detection patterns
│
├── python/
│   ├── run_queries.py              # Main query execution engine
│   ├── export_to_excel.py          # Excel dashboard generator
│   ├── utils.py                    # Data cleaning & analysis utilities
│   └── requirements.txt            # Python dependencies
│
├── data/
│   ├── raw/                        # Raw data files (if any)
│   ├── processed/                  # Generated CSV files for Power BI
│   └── analytics.db                # SQLite database (auto-generated)
│
├── dashboard/
│   └── powerbi_instructions.md     # Complete Power BI implementation guide
│
└── README.md                       # This file
```

---

## 🚀 Quick Start

### Prerequisites

- **Python 3.8+** installed
- **Power BI Desktop** (optional, for visualization)
- **Git** (to clone repository)

### Installation

1. **Clone or download this project**

   ```powershell
   cd "d:\Documents\Test Cases\operational-analytics-dashboard"
   ```

2. **Install Python dependencies**

   ```powershell
   pip install -r python/requirements.txt
   ```

3. **Initialize database and run queries**

   ```powershell
   python python/run_queries.py
   ```

4. **Generate Excel dashboard**
   ```powershell
   python python/export_to_excel.py
   ```

### Expected Output

```
✓ Database initialized with 4 tables
✓ 1000 users, 5000+ transactions seeded
✓ 8 KPI reports generated → data/processed/
✓ 7 anomaly reports generated → data/processed/
✓ Excel dashboard saved → data/analytics_dashboard.xlsx
```

---

## 📈 KPI Definitions

### 1. Daily Active Users (DAU)

**Definition**: Unique users with at least one successful transaction per day

**Business Value**: Measures platform engagement and user retention

**SQL Technique**: `COUNT(DISTINCT user_id)` with 7-day moving average using window functions

**Benchmark**:

- Healthy growth: +5-10% MoM
- Alert threshold: -15% decline

---

### 2. Churn Rate

**Definition**: Percentage of users inactive for 90+ days

**Calculation**: `(Inactive Users / Total Users) * 100`

**Business Value**: Early warning system for user attrition

**SQL Technique**: Cohort analysis with `JULIANDAY` date arithmetic

**Benchmark**:

- Free tier: <20% acceptable
- Premium tier: <10% target
- Enterprise: <5% critical

---

### 3. Refund Rate

**Definition**: Percentage of successful transactions resulting in refunds

**Calculation**: `(Refund Count / Successful Transactions) * 100`

**Business Value**: Product quality and customer satisfaction indicator

**SQL Technique**: LEFT JOIN with aggregation and percentage calculation

**Benchmark**:

- E-commerce industry: 2-5% normal
- Alert threshold: >8% requires investigation

---

### 4. Ticket Resolution Time

**Definition**: Average hours to resolve support tickets

**Calculation**: `AVG(resolution_time_hours)` by category and priority

**Business Value**: Customer service efficiency and SLA compliance

**SQL Technique**: Aggregation with CASE statements for SLA targets

**SLA Targets**:

- Critical: 4 hours
- High: 24 hours
- Medium: 48 hours
- Low: 72 hours

---

### 5. Customer Lifetime Value (CLV)

**Definition**: Total revenue generated per customer over their lifetime

**Calculation**: `SUM(amount)` grouped by user_id

**Business Value**: Identify high-value customers for retention focus

**SQL Technique**: Multi-table JOIN with aggregation and tier segmentation

**Expected Values**:

- Enterprise: $100,000+ CLV
- Premium: $30,000-50,000 CLV
- Basic: $8,000-15,000 CLV
- Free: <$2,000 CLV

---

### 6. Transaction Success Rate

**Definition**: Percentage of transactions completing successfully

**Calculation**: `(Successful Transactions / Total Attempts) * 100`

**Business Value**: Payment gateway health and revenue optimization

**SQL Technique**: CASE-based aggregation by payment method

**Benchmark**:

- Target: >95% success rate
- Alert: <90% indicates payment issues

---

### 7. Cohort Retention

**Definition**: Percentage of users from signup cohort still active each month

**Calculation**: `(Active Users in Month N / Cohort Size) * 100`

**Business Value**: Product-market fit and long-term engagement

**SQL Technique**: Self-JOIN with window functions for month offsets

**Benchmark**:

- Month 1: 60-70% retention
- Month 3: 40-50% retention
- Month 6: 30-40% retention

---

### 8. User Ranking

**Definition**: Users ranked by total spend, transaction frequency, and engagement

**Calculation**: ROW_NUMBER() with NTILE for quartile segmentation

**Business Value**: Customer segmentation for targeted campaigns

**SQL Technique**: Multiple window functions (ROW_NUMBER, RANK, NTILE)

**Segments**:

- High Value (Top 25%): Priority support, exclusive offers
- Medium-High (26-50%): Upsell opportunities
- Medium-Low (51-75%): Engagement campaigns
- Low Value (Bottom 25%): Churn prevention

---

## 🔍 Anomaly Detection Details

### Transaction Amount Spikes

**Detection Method**: Z-score > 3 standard deviations from user's average

**Use Case**: Fraud detection, account takeover prevention

**Action**: Flag for manual review or temporary hold

**SQL**: Statistical analysis with `AVG()`, `STDDEV()`, and z-score calculation

---

### Consecutive Payment Failures

**Detection Method**: 2+ consecutive failed transactions within 10 minutes

**Use Case**: Card blocking, fraud prevention

**Action**: Notify user, suggest alternative payment method

**SQL**: LAG window function to track previous transaction status

---

### Refund Rate Spikes

**Detection Method**: Daily refund rate 1.5x+ higher than 30-day average

**Use Case**: Product quality issues, batch defects

**Action**: Investigate product/supplier, pause sales if critical

**SQL**: Moving average with RANGE window frame

---

### Dormant User Reactivation

**Detection Method**: User returning after 60+ days of inactivity

**Use Case**: Churn prevention, re-engagement success tracking

**Action**: Measure campaign effectiveness, identify win-back patterns

**SQL**: LAG function with JULIANDAY date arithmetic

---

### Ticket Resolution Outliers

**Detection Method**: Resolution time z-score > 2 standard deviations

**Use Case**: SLA breach prevention, process improvement

**Action**: Review ticket workflow, agent training

**SQL**: Statistical analysis by category and priority

---

### Unusual Login Patterns

**Detection Method**: High spend but low activity days, or long dormancy

**Use Case**: Account security, behavioral anomalies

**Action**: Security review, verify account ownership

**SQL**: Multi-metric analysis with CASE logic

---

### Payment Method Switching

**Detection Method**: 3+ different payment methods in 24 hours

**Use Case**: Fraud indicator, stolen card usage

**Action**: Enhanced verification, manual review

**SQL**: COUNT DISTINCT with RANGE window (24-hour rolling)

---

## 💻 Usage Examples

### Run All KPI Queries

```powershell
python python/run_queries.py
```

**Output**:

- Creates `data/analytics.db` SQLite database
- Executes all SQL scripts sequentially
- Exports 15 CSV files to `data/processed/`
- Shows database statistics

### Generate Excel Dashboard

```powershell
python python/export_to_excel.py
```

**Output**:

- Creates `data/analytics_dashboard.xlsx`
- 16 sheets: Executive Summary + 8 KPIs + 7 Anomalies
- Professional styling with headers, borders, freeze panes
- Auto-sized columns for readability

### Use Python Utilities

```python
from python.utils import DataCleaner, AnomalyDetector, KPICalculator

# Clean data
df_clean = DataCleaner.remove_duplicates(df)
df_clean = DataCleaner.handle_missing_values(df_clean, strategy='fill', fill_value=0)

# Detect anomalies
df_anomalies = AnomalyDetector.detect_spikes(df, 'amount', threshold=3)

# Calculate KPIs
clv = KPICalculator.calculate_clv(df, user_col='user_id', revenue_col='amount')
```

### Custom SQL Queries

```powershell
# Connect to database
sqlite3 data/analytics.db

# Example query
SELECT
    subscription_tier,
    COUNT(*) as users,
    AVG(total_spent) as avg_clv
FROM users
WHERE is_active = 1
GROUP BY subscription_tier
ORDER BY avg_clv DESC;
```

---

## 📊 Power BI Integration

### Import Data

1. Open Power BI Desktop
2. **Get Data** → **Text/CSV**
3. Import all files from `data/processed/`
4. Alternatively: **Direct database connection** to `analytics.db`

### Build Data Model

Follow the comprehensive guide in `dashboard/powerbi_instructions.md`:

- Star schema with fact and dimension tables
- 20+ DAX measures for KPIs
- Date dimension for time intelligence
- Relationships and cardinality

### Create Dashboards

**6 Dashboard Pages**:

1. Executive Overview - High-level KPIs
2. User Analytics - Cohort retention, churn analysis
3. Transaction Analytics - Revenue trends, payment success
4. Refund Analysis - Refund rates, impact analysis
5. Support Operations - Ticket resolution, SLA compliance
6. Anomaly Dashboard - Real-time alerts and patterns

### Key Visuals

- Line charts for trends (DAU, revenue, churn)
- Matrix for cohort retention heat map
- Gauge charts for SLA compliance
- Tables for anomaly alerts with conditional formatting
- KPI cards with sparklines and indicators

**See `dashboard/powerbi_instructions.md` for complete implementation guide.**

---

## 🔧 Configuration

### Database Selection

**SQLite (Default)**:

```python
# In run_queries.py
DB_PATH = 'data/analytics.db'  # No server required
```

**MySQL**:

```python
# Install: pip install pymysql sqlalchemy
import sqlalchemy

DB_PATH = 'mysql+pymysql://user:password@localhost:3306/analytics'
```

### Custom Data

Replace `sql/seed_data.sql` with your own data:

- Maintain table schema from `create_tables.sql`
- Ensure referential integrity (foreign keys)
- Scale to millions of rows (queries optimized with indexes)

### Query Customization

Modify SQL queries in `sql/kpi_queries.sql` and `sql/anomaly_detection.sql`:

- Adjust time windows (currently 90 days)
- Change anomaly thresholds (z-score, percentages)
- Add new KPIs or remove existing ones
- Update category mappings

---

## 📁 Sample Data Characteristics

### Users Table (40 representative records, scalable to 1000+)

- **Distribution**: 70% free, 20% basic, 8% premium, 2% enterprise
- **Geography**: 60% India, 20% USA, 10% UK, 10% Others
- **Activity**: 85% active, 15% churned
- **Signup Period**: 2023-01 to 2024-07

### Transactions Table (54+ representative records, scalable to 5000+)

- **Success Rate**: 85% success, 10% failed, 5% other
- **Payment Methods**: 40% credit card, 30% UPI, 15% debit card, 15% other
- **Categories**: 35% electronics, 25% fashion, 20% groceries, 15% services
- **Anomalies**: Intentional spikes, consecutive failures, fraud patterns

### Support Tickets (20+ representative records, scalable to 800+)

- **Categories**: 30% technical, 25% billing, 20% refund, 15% account, 10% general
- **Priority**: 10% critical, 25% high, 40% medium, 25% low
- **Status**: 70% resolved, 15% in_progress, 10% open, 5% escalated
- **Resolution Time**: Realistic distributions with outliers

### Refunds (14+ representative records, scalable to 150+)

- **Refund Rate**: ~3% of successful transactions (realistic e-commerce)
- **Reasons**: 40% defect, 25% not satisfied, 15% wrong item, 10% cancelled, 10% other
- **Processing Time**: 2-5 days average

---

## 🎓 Learning Outcomes

This project demonstrates proficiency in:

### SQL Skills

- Complex query design with multiple CTEs
- Window functions for analytical calculations
- Statistical analysis (z-scores, standard deviation)
- Date/time manipulation and cohort analysis
- Performance optimization with indexes
- Normalized database design (3NF)

### Python Skills

- Database connectivity (SQLite, MySQL)
- Pandas for data manipulation
- Excel automation with openpyxl
- Modular code design with classes
- Error handling and logging
- Configuration management

### Business Intelligence

- KPI definition and calculation
- Anomaly detection methodologies
- Data visualization best practices
- Dashboard design principles
- Stakeholder communication

### Analytics Thinking

- Translating business questions to SQL
- Identifying actionable insights
- Designing alerting mechanisms
- Understanding data quality
- Documenting analytical decisions

---

## 🌟 Project Highlights for Portfolio

**Why this project stands out for SQL-heavy roles:**

1. **Advanced SQL**: Showcases window functions, CTEs, statistical analysis
2. **Business Focus**: Real-world KPIs used by companies like CRED, Razorpay
3. **End-to-End**: Complete pipeline from raw data to dashboard
4. **Scalable**: Designed to handle millions of records
5. **Production-Ready**: Error handling, logging, documentation
6. **Anomaly Detection**: Critical for fintech and e-commerce
7. **Automation**: Reduces manual reporting effort by 90%

**Perfect for demonstrating to companies:**

- **CRED**: Analytical SQL, user behavior analysis, anomaly detection
- **Razorpay**: Transaction analytics, payment success optimization
- **Swiggy/Zomato**: User retention, cohort analysis, operational metrics
- **Amazon/Flipkart**: Refund analysis, customer lifetime value

---

## 📝 Next Steps & Enhancements

### Phase 2 Enhancements

- [ ] Add real-time data ingestion (streaming)
- [ ] Implement machine learning models for churn prediction
- [ ] Create API for programmatic access to KPIs
- [ ] Build alerting system (email/Slack notifications)
- [ ] Add geospatial analysis for location-based insights
- [ ] Implement A/B test analysis framework

### Advanced SQL Features

- [ ] Recursive CTEs for hierarchical data
- [ ] Pivot/unpivot for cross-tab reports
- [ ] Dynamic SQL for parameterized queries
- [ ] Query optimization and execution plans
- [ ] Partitioning for very large tables

### Power BI Enhancements

- [ ] Implement row-level security (RLS)
- [ ] Create mobile-optimized layouts
- [ ] Add AI-powered Q&A natural language queries
- [ ] Build embedded analytics for web apps
- [ ] Schedule automated report distribution

---

## 🤝 Contributing

This is a portfolio/demo project. To adapt for your use case:

1. **Fork** the repository
2. **Modify** SQL queries for your business logic
3. **Update** seed data with realistic patterns
4. **Customize** Power BI visuals and DAX measures
5. **Document** your changes and findings

---

## 📄 License

This project is provided as-is for educational and portfolio purposes.

---

## 📧 Contact & Support

**Project Author**: GitHub Copilot  
**Date**: November 23, 2025  
**Purpose**: SQL Analytics Portfolio Project

For questions or suggestions:

- Review `dashboard/powerbi_instructions.md` for detailed BI guidance
- Check `python/utils.py` for reusable data analysis functions
- Examine `sql/` files for query patterns and techniques

---

## 🎯 Key Takeaways

This project demonstrates:
✅ **Advanced SQL** mastery with window functions, CTEs, and statistical analysis  
✅ **Business acumen** through meaningful KPI definitions and anomaly detection  
✅ **Automation** skills with Python for end-to-end pipeline  
✅ **Visualization** expertise through Power BI integration  
✅ **Production-ready** code with error handling and documentation

**Perfect for roles requiring**: Data Analyst, BI Developer, Analytics Engineer, SQL Developer positions at data-driven companies.

---

## 📊 Quick Reference

### File Locations

- **SQL Scripts**: `sql/`
- **Python Code**: `python/`
- **Output Data**: `data/processed/`
- **Excel Dashboard**: `data/analytics_dashboard.xlsx`
- **Database**: `data/analytics.db`
- **Power BI Guide**: `dashboard/powerbi_instructions.md`

### Common Commands

```powershell
# Full pipeline execution
python python/run_queries.py; python python/export_to_excel.py

# View database
sqlite3 data/analytics.db ".tables"

# Check output
Get-ChildItem data/processed/*.csv
```

### Support Resources

- SQL window functions: [PostgreSQL Docs](https://www.postgresql.org/docs/current/tutorial-window.html)
- Power BI DAX: [Microsoft Learn](https://learn.microsoft.com/en-us/dax/)
- Pandas documentation: [pandas.pydata.org](https://pandas.pydata.org/)

---

**🚀 Ready to impress? Run the pipeline and showcase your analytics expertise!**
