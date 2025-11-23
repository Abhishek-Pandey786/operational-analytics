"""
Operational Analytics Dashboard - Query Runner
==============================================
Purpose: Execute SQL queries and export results to CSV/Excel
Author: Copilot
Date: 2025-11-23
"""

import sqlite3
import os
import sys
import pandas as pd
from datetime import datetime
from pathlib import Path

# Configuration
DB_PATH = os.path.join(os.path.dirname(__file__), '..', 'data', 'analytics.db')
SQL_DIR = os.path.join(os.path.dirname(__file__), '..', 'sql')
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'data', 'processed')

class QueryRunner:
    """Execute SQL scripts and manage database operations"""
    
    def __init__(self, db_path=DB_PATH):
        """Initialize database connection"""
        self.db_path = db_path
        self.connection = None
        self.ensure_directories()
    
    def ensure_directories(self):
        """Create necessary directories if they don't exist"""
        Path(os.path.dirname(self.db_path)).mkdir(parents=True, exist_ok=True)
        Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
    
    def connect(self):
        """Establish database connection"""
        try:
            self.connection = sqlite3.connect(self.db_path)
            print(f"✓ Connected to database: {self.db_path}")
            return self.connection
        except sqlite3.Error as e:
            print(f"✗ Database connection error: {e}")
            sys.exit(1)
    
    def disconnect(self):
        """Close database connection"""
        if self.connection:
            self.connection.close()
            print("✓ Database connection closed")
    
    def execute_sql_file(self, sql_file_path, fetch_results=False):
        """
        Execute SQL from file
        
        Args:
            sql_file_path (str): Path to SQL file
            fetch_results (bool): Whether to return query results
        
        Returns:
            DataFrame or None: Query results if fetch_results=True
        """
        try:
            with open(sql_file_path, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            if not self.connection:
                self.connect()
            
            cursor = self.connection.cursor()
            
            # For schema/seed files, execute as script
            if 'create_tables' in sql_file_path or 'seed_data' in sql_file_path:
                cursor.executescript(sql_content)
                self.connection.commit()
                print(f"✓ Executed: {os.path.basename(sql_file_path)}")
                return None
            
            # For query files with multiple queries, split by semicolon
            if fetch_results:
                # Execute only the first query or specific query
                queries = [q.strip() for q in sql_content.split(';') if q.strip()]
                
                results = []
                for idx, query in enumerate(queries):
                    # Skip comments and empty queries
                    query_lines = [line for line in query.split('\n') if line.strip() and not line.strip().startswith('--')]
                    clean_query = '\n'.join(query_lines).strip()
                    
                    if clean_query and len(clean_query) > 50:  # Meaningful query
                        try:
                            df = pd.read_sql_query(clean_query, self.connection)
                            if len(df) > 0:
                                results.append({
                                    'query_number': idx + 1,
                                    'dataframe': df,
                                    'rows': len(df)
                                })
                                print(f"  ✓ Query {idx + 1}: {len(df)} rows")
                            else:
                                print(f"  ⚠ Query {idx + 1}: 0 rows (skipped)")
                        except Exception as e:
                            print(f"  ✗ Query {idx + 1} failed: {str(e)[:150]}")
                
                return results
            
        except FileNotFoundError:
            print(f"✗ SQL file not found: {sql_file_path}")
            return None
        except sqlite3.Error as e:
            print(f"✗ SQL execution error: {e}")
            return None
        except Exception as e:
            print(f"✗ Unexpected error: {e}")
            return None
    
    def initialize_database(self):
        """Create tables and populate with seed data"""
        print("\n" + "="*60)
        print("DATABASE INITIALIZATION")
        print("="*60)
        
        # Create tables
        schema_file = os.path.join(SQL_DIR, 'create_tables.sql')
        if os.path.exists(schema_file):
            self.execute_sql_file(schema_file)
        else:
            print(f"✗ Schema file not found: {schema_file}")
            return False
        
        # Seed data
        seed_file = os.path.join(SQL_DIR, 'seed_data.sql')
        if os.path.exists(seed_file):
            self.execute_sql_file(seed_file)
        else:
            print(f"✗ Seed file not found: {seed_file}")
            return False
        
        print("✓ Database initialized successfully")
        return True
    
    def run_kpi_queries(self):
        """Execute KPI queries and export to CSV"""
        print("\n" + "="*60)
        print("EXECUTING KPI QUERIES")
        print("="*60)
        
        kpi_file = os.path.join(SQL_DIR, 'kpi_queries.sql')
        if not os.path.exists(kpi_file):
            print(f"✗ KPI queries file not found: {kpi_file}")
            return []
        
        results = self.execute_sql_file(kpi_file, fetch_results=True)
        
        print(f"Debug: Results type: {type(results)}, Length: {len(results) if results else 0}")
        
        if results:
            # Export each query result to CSV
            kpi_names = [
                'daily_active_users',
                'user_churn_rate',
                'refund_rate_analysis',
                'ticket_resolution_time',
                'customer_lifetime_value',
                'transaction_success_rate',
                'cohort_retention',
                'top_users_ranking'
            ]
            
            exported_files = []
            for idx, result in enumerate(results):
                if result['rows'] > 0:
                    kpi_name = kpi_names[idx] if idx < len(kpi_names) else f'kpi_{idx+1}'
                    output_file = os.path.join(OUTPUT_DIR, f'{kpi_name}.csv')
                    result['dataframe'].to_csv(output_file, index=False)
                    exported_files.append(output_file)
                    print(f"✓ Exported: {kpi_name}.csv ({result['rows']} rows)")
            
            return exported_files
        
        return []
    
    def run_anomaly_detection(self):
        """Execute anomaly detection queries and export to CSV"""
        print("\n" + "="*60)
        print("EXECUTING ANOMALY DETECTION")
        print("="*60)
        
        anomaly_file = os.path.join(SQL_DIR, 'anomaly_detection.sql')
        if not os.path.exists(anomaly_file):
            print(f"✗ Anomaly detection file not found: {anomaly_file}")
            return []
        
        results = self.execute_sql_file(anomaly_file, fetch_results=True)
        
        if results:
            anomaly_names = [
                'transaction_amount_spikes',
                'consecutive_payment_failures',
                'refund_rate_spikes',
                'dormant_user_reactivation',
                'ticket_resolution_outliers',
                'unusual_login_patterns',
                'payment_method_switching'
            ]
            
            exported_files = []
            for idx, result in enumerate(results):
                if result['rows'] > 0:
                    anomaly_name = anomaly_names[idx] if idx < len(anomaly_names) else f'anomaly_{idx+1}'
                    output_file = os.path.join(OUTPUT_DIR, f'anomaly_{anomaly_name}.csv')
                    result['dataframe'].to_csv(output_file, index=False)
                    exported_files.append(output_file)
                    print(f"✓ Exported: anomaly_{anomaly_name}.csv ({result['rows']} rows)")
            
            return exported_files
        
        return []
    
    def get_database_stats(self):
        """Get summary statistics about the database"""
        print("\n" + "="*60)
        print("DATABASE STATISTICS")
        print("="*60)
        
        if not self.connection:
            self.connect()
        
        tables = ['users', 'transactions', 'support_tickets', 'refunds']
        stats = {}
        
        for table in tables:
            try:
                query = f"SELECT COUNT(*) as count FROM {table}"
                result = pd.read_sql_query(query, self.connection)
                count = result['count'][0]
                stats[table] = count
                print(f"  {table:20s}: {count:,} records")
            except sqlite3.Error as e:
                print(f"✗ Error querying {table}: {e}")
        
        return stats


def main():
    """Main execution flow"""
    print("\n" + "="*70)
    print(" "*15 + "OPERATIONAL ANALYTICS DASHBOARD")
    print(" "*20 + "SQL Query Automation")
    print("="*70)
    print(f"Execution Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    runner = QueryRunner()
    
    try:
        # Step 1: Initialize database
        if not os.path.exists(runner.db_path):
            print("\n→ Database not found. Initializing...")
            runner.connect()
            runner.initialize_database()
        else:
            print("\n→ Database exists. Connecting...")
            runner.connect()
        
        # Step 2: Show database stats
        runner.get_database_stats()
        
        # Step 3: Run KPI queries
        kpi_files = runner.run_kpi_queries()
        
        # Step 4: Run anomaly detection
        anomaly_files = runner.run_anomaly_detection()
        
        # Step 5: Summary
        print("\n" + "="*60)
        print("EXECUTION SUMMARY")
        print("="*60)
        print(f"✓ KPI Reports Generated: {len(kpi_files)}")
        print(f"✓ Anomaly Reports Generated: {len(anomaly_files)}")
        print(f"✓ Total CSV Files: {len(kpi_files) + len(anomaly_files)}")
        print(f"✓ Output Directory: {OUTPUT_DIR}")
        
        print("\n" + "="*60)
        print("NEXT STEPS")
        print("="*60)
        print("1. Run 'python export_to_excel.py' to generate Excel dashboard")
        print("2. Import CSV files into Power BI for visualization")
        print("3. Review anomaly reports for actionable insights")
        
    except Exception as e:
        print(f"\n✗ Fatal error: {e}")
        sys.exit(1)
    finally:
        runner.disconnect()


if __name__ == "__main__":
    main()
