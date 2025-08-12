#!/usr/bin/env python3
"""
VPS Crawler Testing Suite
Kiểm tra và validate các crawler đã được fix trên VPS
"""

import sys
import os
import time
import psutil
import logging
from datetime import datetime

# Add project paths
sys.path.append('/path/to/spa_vip')  # Thay đổi path này theo VPS của bạn
sys.path.append('/path/to/spa_vip/crawl')
sys.path.append('/path/to/spa_vip/database')

def setup_logging():
    """Setup logging cho test"""
    log_filename = f"crawler_test_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_filename),
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(__name__)

def check_memory_usage():
    """Kiểm tra memory usage"""
    memory = psutil.virtual_memory()
    return {
        'total': memory.total / (1024**3),  # GB
        'available': memory.available / (1024**3),  # GB
        'percent': memory.percent,
        'used': memory.used / (1024**3)  # GB
    }

def test_chrome_basic():
    """Test Chrome cơ bản"""
    logger.info("🧪 Testing Chrome basic functionality...")
    
    try:
        from selenium import webdriver
        from selenium.webdriver.chrome.options import Options
        
        options = Options()
        # Sử dụng cùng config đã fix trong các crawler
        options.add_argument("--headless")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")
        options.add_argument("--disable-features=VizDisplayCompositor")
        options.add_argument("--disable-extensions")
        options.add_argument("--disable-plugins")
        options.add_argument("--disable-images")
        options.add_argument("--window-size=1920,1080")
        options.add_argument("--user-agent=Mozilla/5.0 (Linux; x86_64) AppleWebKit/537.36")
        options.add_argument("--memory-pressure-off")
        options.add_argument("--max_old_space_size=4096")
        
        driver = webdriver.Chrome(options=options)
        driver.set_page_load_timeout(30)
        
        # Test simple page load
        driver.get("https://www.google.com")
        title = driver.title
        
        driver.quit()
        
        if "Google" in title:
            logger.info("✅ Chrome basic test PASSED")
            return True
        else:
            logger.error(f"❌ Chrome basic test FAILED - unexpected title: {title}")
            return False
            
    except Exception as e:
        logger.error(f"❌ Chrome basic test FAILED: {e}")
        return False

def test_individual_crawler(crawler_module, crawler_name):
    """Test một crawler cụ thể"""
    logger.info(f"🧪 Testing {crawler_name}...")
    
    try:
        # Import crawler
        if crawler_name == "FireAnt":
            from crawlers.fireant_crawler import FireAntCrawler
            crawler = FireAntCrawler()
        elif crawler_name == "CafeF General":
            from crawlers.cafef_general_crawler import CafeFGeneralCrawler
            crawler = CafeFGeneralCrawler()
        elif crawler_name == "CafeF Keyword":
            from crawlers.cafef_keyword_crawler import CafeFKeywordCrawler
            crawler = CafeFKeywordCrawler()
        elif crawler_name == "ChungTa":
            from crawlers.chungta_crawler import ChungTaCrawler
            crawler = ChungTaCrawler()
        elif crawler_name == "Stock Price":
            from crawl_stock.crawl_stock_price_history import StockPriceCrawler
            crawler = StockPriceCrawler()
        else:
            logger.error(f"❌ Unknown crawler: {crawler_name}")
            return False
        
        # Test setup_driver function
        memory_before = check_memory_usage()
        logger.info(f"Memory before test: {memory_before['percent']:.1f}%")
        
        driver = None
        try:
            # Kiểm tra xem crawler có method setup_driver không
            if hasattr(crawler, 'setup_driver'):
                driver = crawler.setup_driver()
                logger.info(f"✅ {crawler_name} setup_driver() successful")
                
                # Test basic navigation
                driver.get("https://www.google.com")
                logger.info(f"✅ {crawler_name} navigation test successful")
                
            else:
                logger.warning(f"⚠️ {crawler_name} doesn't have setup_driver method")
                return True  # Không phải lỗi, chỉ là crawler không có method này
                
        finally:
            if driver:
                driver.quit()
                time.sleep(2)  # Wait for cleanup
        
        memory_after = check_memory_usage()
        logger.info(f"Memory after test: {memory_after['percent']:.1f}%")
        
        # Kiểm tra memory leak
        memory_diff = memory_after['percent'] - memory_before['percent']
        if memory_diff > 5:  # Tăng hơn 5%
            logger.warning(f"⚠️ {crawler_name} may have memory leak: +{memory_diff:.1f}%")
        
        logger.info(f"✅ {crawler_name} test PASSED")
        return True
        
    except Exception as e:
        logger.error(f"❌ {crawler_name} test FAILED: {e}")
        return False

def test_database_connection():
    """Test kết nối database"""
    logger.info("🧪 Testing database connection...")
    
    try:
        from database.supabase_manager import SupabaseManager
        
        db_manager = SupabaseManager()
        
        # Test connection
        test_query = """
        SELECT 1 as test_connection
        """
        
        result = db_manager.execute_query(test_query)
        
        if result and len(result) > 0:
            logger.info("✅ Database connection test PASSED")
            return True
        else:
            logger.error("❌ Database connection test FAILED - no result")
            return False
            
    except Exception as e:
        logger.error(f"❌ Database connection test FAILED: {e}")
        return False

def cleanup_chrome_processes():
    """Cleanup Chrome processes"""
    logger.info("🧹 Cleaning up Chrome processes...")
    
    killed_processes = 0
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            if proc.info['name'] and ('chrome' in proc.info['name'].lower() or 
                                      'chromedriver' in proc.info['name'].lower()):
                proc.kill()
                killed_processes += 1
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    
    if killed_processes > 0:
        logger.info(f"🧹 Killed {killed_processes} Chrome processes")
        time.sleep(3)  # Wait for cleanup
    
    return killed_processes

def main():
    """Main test function"""
    global logger
    logger = setup_logging()
    
    logger.info("🚀 VPS CRAWLER TESTING SUITE")
    logger.info("=" * 50)
    
    # Initial system check
    memory = check_memory_usage()
    logger.info(f"💾 System Memory: {memory['used']:.1f}GB / {memory['total']:.1f}GB ({memory['percent']:.1f}%)")
    
    if memory['percent'] > 80:
        logger.warning("⚠️ HIGH MEMORY USAGE detected before testing!")
    
    test_results = {}
    
    # Cleanup before starting
    cleanup_chrome_processes()
    
    # Test 1: Chrome basic functionality
    test_results['chrome_basic'] = test_chrome_basic()
    time.sleep(2)
    
    # Test 2: Database connection
    test_results['database'] = test_database_connection()
    time.sleep(2)
    
    # Test 3: Individual crawlers
    crawlers_to_test = [
        ("fireant_crawler", "FireAnt"),
        ("cafef_general_crawler", "CafeF General"),
        ("cafef_keyword_crawler", "CafeF Keyword"),
        ("chungta_crawler", "ChungTa"),
        ("crawl_stock_price_history", "Stock Price")
    ]
    
    for crawler_module, crawler_name in crawlers_to_test:
        cleanup_chrome_processes()  # Cleanup before each test
        
        test_results[f'crawler_{crawler_name.lower().replace(" ", "_")}'] = test_individual_crawler(
            crawler_module, crawler_name
        )
        
        time.sleep(3)  # Wait between tests
        
        # Check memory after each test
        memory = check_memory_usage()
        if memory['percent'] > 85:
            logger.warning(f"⚠️ High memory usage after {crawler_name}: {memory['percent']:.1f}%")
            cleanup_chrome_processes()
            time.sleep(5)
    
    # Final cleanup
    cleanup_chrome_processes()
    
    # Results summary
    logger.info("\n" + "🏁 TEST RESULTS SUMMARY")
    logger.info("=" * 30)
    
    passed_tests = 0
    total_tests = len(test_results)
    
    for test_name, passed in test_results.items():
        status = "✅ PASSED" if passed else "❌ FAILED"
        logger.info(f"{test_name}: {status}")
        if passed:
            passed_tests += 1
    
    logger.info(f"\nOverall: {passed_tests}/{total_tests} tests passed ({passed_tests/total_tests*100:.1f}%)")
    
    # Final memory check
    final_memory = check_memory_usage()
    logger.info(f"Final Memory Usage: {final_memory['percent']:.1f}%")
    
    if passed_tests == total_tests:
        logger.info("🎉 ALL TESTS PASSED! Your VPS is ready for crawling.")
        return 0
    else:
        logger.error("❌ Some tests failed. Please check the logs and fix issues.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
