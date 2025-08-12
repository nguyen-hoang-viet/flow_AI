#!/usr/bin/env python3
"""
Simple Chrome Wrapper for SPA VIP
"""

from selenium import webdriver
from selenium.webdriver.chrome.options import Options

def setup_chrome_driver():
    """Setup Chrome driver với options tối ưu"""
    options = Options()
    
    # Basic options that work on most systems
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-plugins")
    
    # Try using webdriver-manager first
    try:
        from webdriver_manager.chrome import ChromeDriverManager
        from selenium.webdriver.chrome.service import Service
        
        service = Service(ChromeDriverManager().install())
        return webdriver.Chrome(service=service, options=options)
    except ImportError:
        # Fallback to system ChromeDriver
        return webdriver.Chrome(options=options)

# Test function
if __name__ == "__main__":
    try:
        print("🧪 Testing simple Chrome wrapper...")
        driver = setup_chrome_driver()
        driver.get("https://www.google.com")
        print(f"✅ Success! Title: {driver.title}")
        driver.quit()
    except Exception as e:
        print(f"❌ Test failed: {e}")
