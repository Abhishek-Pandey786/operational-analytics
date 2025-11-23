# Project Setup Guide

## Quick Start (3 Steps)

### 1. Install Dependencies

```powershell
cd "d:\Documents\Test Cases\operational-analytics-dashboard"
pip install -r python/requirements.txt
```

### 2. Run SQL Pipeline

```powershell
python python/run_queries.py
```

This will:

- Create `data/analytics.db` SQLite database
- Initialize tables and seed sample data
- Execute all KPI and anomaly queries
- Export 15 CSV files to `data/processed/`

### 3. Generate Excel Dashboard

```powershell
python python/export_to_excel.py
```

This will:

- Create styled Excel workbook: `data/analytics_dashboard.xlsx`
- 16 sheets with professional formatting
- Ready for analysis and Power BI import

---

## Verification

Check that everything worked:

```powershell
# Verify database created
Test-Path "data/analytics.db"  # Should return True

# Check CSV exports
Get-ChildItem "data/processed/*.csv" | Measure-Object | Select-Object Count  # Should show ~15 files

# Check Excel file
Test-Path "data/analytics_dashboard.xlsx"  # Should return True
```

---

## Power BI Setup (Optional)

1. Open **Power BI Desktop**
2. **Get Data** → **Text/CSV**
3. Browse to `data/processed/` and import all CSV files
4. Follow detailed instructions in `dashboard/powerbi_instructions.md`

---

## Troubleshooting

### Issue: "No module named 'pandas'"

**Solution**: Install dependencies

```powershell
pip install pandas numpy openpyxl
```

### Issue: "Database locked"

**Solution**: Close any SQLite browser/viewer applications

### Issue: Excel file not styled properly

**Solution**: Ensure openpyxl is installed

```powershell
pip install openpyxl
```

---

## Next Steps

✅ **Explore Data**: Open `data/analytics_dashboard.xlsx`  
✅ **Review SQL**: Check `sql/kpi_queries.sql` for query patterns  
✅ **Build Dashboard**: Import CSVs into Power BI  
✅ **Customize**: Modify queries for your use case

See `README.md` for full documentation.
