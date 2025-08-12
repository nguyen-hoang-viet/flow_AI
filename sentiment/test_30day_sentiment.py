#!/usr/bin/env python3
"""
Test script for 30-day sentiment aggregation logic
"""

import sys
import os
from datetime import datetime, timedelta

# Add paths for imports
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)  # Go up to SPA_vip folder
sys.path.insert(0, parent_dir)

from database import SupabaseManager
from sentiment.predict_sentiment_db import process_sentiment_to_stock_30days

def test_30day_sentiment():
    """Test the 30-day sentiment processing"""
    print("🧪 Testing 30-day sentiment aggregation logic")
    
    # Initialize database
    db_manager = SupabaseManager()
    
    # Test for FPT (since it has recent sentiment data)
    stock_code = "FPT"
    
    print(f"\n🎯 Testing 30-day sentiment processing for {stock_code}")
    print("="*60)
    
    # Simulate having updated dates (to trigger 30-day logic)
    updated_dates = {'2025-08-11', '2025-08-10', '2025-08-09'}
    
    try:
        result = process_sentiment_to_stock_30days(db_manager, stock_code, updated_dates)
        print(f"\n✅ Test completed successfully!")
        print(f"📊 Updated {result} records")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        db_manager.close_connections()

if __name__ == "__main__":
    test_30day_sentiment()
