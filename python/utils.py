"""
Operational Analytics Dashboard - Utilities
==============================================
Purpose: Helper functions for data cleaning and analysis
Author: Copilot
Date: 2025-11-23
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta


class DataCleaner:
    """Utilities for data cleaning and validation"""
    
    @staticmethod
    def remove_duplicates(df, subset=None):
        """
        Remove duplicate rows from DataFrame
        
        Args:
            df (DataFrame): Input data
            subset (list): Columns to consider for duplicates
        
        Returns:
            DataFrame: Cleaned data
        """
        initial_rows = len(df)
        df_clean = df.drop_duplicates(subset=subset, keep='first')
        removed = initial_rows - len(df_clean)
        
        if removed > 0:
            print(f"✓ Removed {removed} duplicate rows")
        
        return df_clean
    
    @staticmethod
    def handle_missing_values(df, strategy='drop', fill_value=None):
        """
        Handle missing values in DataFrame
        
        Args:
            df (DataFrame): Input data
            strategy (str): 'drop', 'fill', 'forward_fill', 'backward_fill'
            fill_value: Value to use for filling (if strategy='fill')
        
        Returns:
            DataFrame: Cleaned data
        """
        missing_count = df.isnull().sum().sum()
        
        if missing_count == 0:
            return df
        
        if strategy == 'drop':
            df_clean = df.dropna()
        elif strategy == 'fill':
            df_clean = df.fillna(fill_value)
        elif strategy == 'forward_fill':
            df_clean = df.fillna(method='ffill')
        elif strategy == 'backward_fill':
            df_clean = df.fillna(method='bfill')
        else:
            df_clean = df
        
        print(f"✓ Handled {missing_count} missing values using '{strategy}' strategy")
        return df_clean
    
    @staticmethod
    def standardize_dates(df, date_columns):
        """
        Convert date columns to datetime format
        
        Args:
            df (DataFrame): Input data
            date_columns (list): Column names containing dates
        
        Returns:
            DataFrame: Data with standardized dates
        """
        for col in date_columns:
            if col in df.columns:
                df[col] = pd.to_datetime(df[col], errors='coerce')
                print(f"✓ Standardized date column: {col}")
        
        return df
    
    @staticmethod
    def remove_outliers(df, column, method='iqr', threshold=1.5):
        """
        Remove statistical outliers from numeric column
        
        Args:
            df (DataFrame): Input data
            column (str): Column name
            method (str): 'iqr' or 'zscore'
            threshold (float): IQR multiplier or z-score threshold
        
        Returns:
            DataFrame: Data with outliers removed
        """
        if column not in df.columns:
            return df
        
        initial_rows = len(df)
        
        if method == 'iqr':
            Q1 = df[column].quantile(0.25)
            Q3 = df[column].quantile(0.75)
            IQR = Q3 - Q1
            lower_bound = Q1 - threshold * IQR
            upper_bound = Q3 + threshold * IQR
            df_clean = df[(df[column] >= lower_bound) & (df[column] <= upper_bound)]
        
        elif method == 'zscore':
            z_scores = np.abs((df[column] - df[column].mean()) / df[column].std())
            df_clean = df[z_scores < threshold]
        
        else:
            return df
        
        removed = initial_rows - len(df_clean)
        print(f"✓ Removed {removed} outliers from '{column}' using {method} method")
        
        return df_clean


class KPICalculator:
    """Calculate business KPIs from raw data"""
    
    @staticmethod
    def calculate_churn_rate(df, user_col, date_col, active_col, period_days=90):
        """
        Calculate customer churn rate
        
        Args:
            df (DataFrame): User data
            user_col (str): User ID column
            date_col (str): Last activity date column
            active_col (str): Active status column
            period_days (int): Days of inactivity to consider churned
        
        Returns:
            float: Churn rate percentage
        """
        cutoff_date = datetime.now() - timedelta(days=period_days)
        df[date_col] = pd.to_datetime(df[date_col])
        
        total_users = len(df)
        churned_users = len(df[(df[date_col] < cutoff_date) | (df[active_col] == 0)])
        
        churn_rate = (churned_users / total_users * 100) if total_users > 0 else 0
        
        return round(churn_rate, 2)
    
    @staticmethod
    def calculate_clv(df, user_col, revenue_col, date_col=None):
        """
        Calculate Customer Lifetime Value
        
        Args:
            df (DataFrame): Transaction data
            user_col (str): User ID column
            revenue_col (str): Revenue column
            date_col (str): Optional date column for tenure calculation
        
        Returns:
            DataFrame: CLV per user
        """
        clv = df.groupby(user_col).agg({
            revenue_col: ['sum', 'mean', 'count']
        }).reset_index()
        
        clv.columns = [user_col, 'total_revenue', 'avg_order_value', 'transaction_count']
        clv['clv'] = clv['total_revenue']
        
        return clv
    
    @staticmethod
    def calculate_retention_rate(df, cohort_col, period_col, user_col):
        """
        Calculate cohort retention rates
        
        Args:
            df (DataFrame): User activity data
            cohort_col (str): Cohort identifier column
            period_col (str): Time period column
            user_col (str): User ID column
        
        Returns:
            DataFrame: Retention matrix
        """
        cohort_sizes = df.groupby(cohort_col)[user_col].nunique().reset_index()
        cohort_sizes.columns = [cohort_col, 'cohort_size']
        
        retention = df.groupby([cohort_col, period_col])[user_col].nunique().reset_index()
        retention = retention.merge(cohort_sizes, on=cohort_col)
        retention['retention_rate'] = (retention[user_col] / retention['cohort_size'] * 100).round(2)
        
        return retention


class AnomalyDetector:
    """Detect anomalies and unusual patterns in data"""
    
    @staticmethod
    def detect_spikes(df, value_col, threshold=3):
        """
        Detect statistical spikes using z-score
        
        Args:
            df (DataFrame): Input data
            value_col (str): Column to analyze
            threshold (float): Z-score threshold
        
        Returns:
            DataFrame: Rows with anomalies flagged
        """
        mean = df[value_col].mean()
        std = df[value_col].std()
        
        df['z_score'] = ((df[value_col] - mean) / std).abs()
        df['is_anomaly'] = df['z_score'] > threshold
        df['anomaly_severity'] = pd.cut(
            df['z_score'],
            bins=[0, 1.5, 2, 3, float('inf')],
            labels=['Normal', 'Medium', 'High', 'Critical']
        )
        
        anomaly_count = df['is_anomaly'].sum()
        print(f"✓ Detected {anomaly_count} anomalies in '{value_col}'")
        
        return df
    
    @staticmethod
    def detect_consecutive_events(df, event_col, user_col, date_col, event_value, min_consecutive=2):
        """
        Detect consecutive occurrences of specific events
        
        Args:
            df (DataFrame): Input data
            event_col (str): Column containing event types
            user_col (str): User ID column
            date_col (str): Date column for ordering
            event_value: Value to look for (e.g., 'failed')
            min_consecutive (int): Minimum consecutive occurrences
        
        Returns:
            DataFrame: Users with consecutive events
        """
        df = df.sort_values([user_col, date_col])
        df['is_event'] = (df[event_col] == event_value).astype(int)
        
        # Calculate consecutive count
        df['consecutive'] = df.groupby([user_col, (df['is_event'] != df['is_event'].shift()).cumsum()])['is_event'].cumsum()
        
        flagged = df[df['consecutive'] >= min_consecutive]
        
        print(f"✓ Found {len(flagged)} records with {min_consecutive}+ consecutive {event_value} events")
        
        return flagged
    
    @staticmethod
    def detect_sudden_changes(df, value_col, date_col, change_threshold=50):
        """
        Detect sudden percentage changes in values
        
        Args:
            df (DataFrame): Input data
            value_col (str): Column to analyze
            date_col (str): Date column for ordering
            change_threshold (float): Percentage change threshold
        
        Returns:
            DataFrame: Rows with sudden changes flagged
        """
        df = df.sort_values(date_col)
        df['prev_value'] = df[value_col].shift(1)
        df['pct_change'] = ((df[value_col] - df['prev_value']) / df['prev_value'] * 100).abs()
        df['is_sudden_change'] = df['pct_change'] > change_threshold
        
        change_count = df['is_sudden_change'].sum()
        print(f"✓ Detected {change_count} sudden changes (>{change_threshold}%)")
        
        return df


class ReportGenerator:
    """Generate summary reports and statistics"""
    
    @staticmethod
    def generate_summary_stats(df, numeric_cols=None):
        """
        Generate comprehensive summary statistics
        
        Args:
            df (DataFrame): Input data
            numeric_cols (list): Specific columns to analyze (None = all numeric)
        
        Returns:
            DataFrame: Summary statistics
        """
        if numeric_cols is None:
            numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        summary = df[numeric_cols].describe().T
        summary['missing'] = df[numeric_cols].isnull().sum()
        summary['missing_pct'] = (summary['missing'] / len(df) * 100).round(2)
        
        return summary
    
    @staticmethod
    def generate_categorical_summary(df, categorical_cols=None):
        """
        Generate summary for categorical columns
        
        Args:
            df (DataFrame): Input data
            categorical_cols (list): Specific columns to analyze
        
        Returns:
            dict: Summary for each categorical column
        """
        if categorical_cols is None:
            categorical_cols = df.select_dtypes(include=['object']).columns.tolist()
        
        summaries = {}
        for col in categorical_cols:
            summaries[col] = {
                'unique_values': df[col].nunique(),
                'most_common': df[col].mode()[0] if len(df[col].mode()) > 0 else None,
                'value_counts': df[col].value_counts().to_dict()
            }
        
        return summaries
    
    @staticmethod
    def generate_correlation_matrix(df, numeric_cols=None):
        """
        Generate correlation matrix for numeric columns
        
        Args:
            df (DataFrame): Input data
            numeric_cols (list): Specific columns to analyze
        
        Returns:
            DataFrame: Correlation matrix
        """
        if numeric_cols is None:
            numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        correlation = df[numeric_cols].corr().round(2)
        
        return correlation


# Convenience functions for quick access
def clean_data(df, remove_dupes=True, handle_missing='drop'):
    """Quick data cleaning pipeline"""
    cleaner = DataCleaner()
    
    if remove_dupes:
        df = cleaner.remove_duplicates(df)
    
    df = cleaner.handle_missing_values(df, strategy=handle_missing)
    
    return df


def detect_anomalies(df, value_column, threshold=3):
    """Quick anomaly detection"""
    detector = AnomalyDetector()
    return detector.detect_spikes(df, value_column, threshold)


def calculate_metrics(df, metric_type='clv', **kwargs):
    """Quick KPI calculation"""
    calculator = KPICalculator()
    
    if metric_type == 'clv':
        return calculator.calculate_clv(df, **kwargs)
    elif metric_type == 'churn':
        return calculator.calculate_churn_rate(df, **kwargs)
    elif metric_type == 'retention':
        return calculator.calculate_retention_rate(df, **kwargs)
    else:
        raise ValueError(f"Unknown metric type: {metric_type}")


if __name__ == "__main__":
    print("Operational Analytics Dashboard - Utilities Module")
    print("Import this module to use data cleaning and analysis functions")
    print("\nAvailable classes:")
    print("  - DataCleaner: Data cleaning and preprocessing")
    print("  - KPICalculator: Business metric calculations")
    print("  - AnomalyDetector: Anomaly detection algorithms")
    print("  - ReportGenerator: Summary statistics and reports")
