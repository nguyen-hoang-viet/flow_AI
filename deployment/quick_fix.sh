#!/bin/bash

# ====================================================================
# SPA VIP QUICK FIX - Chrome Session Error
# Khắc phục nhanh lỗi: session not created
# ====================================================================

echo "🚑 SPA VIP QUICK FIX"
echo "==================="
echo "Fixing Chrome session creation error..."
echo ""

# Kill all Chrome processes
echo "🔪 Killing existing Chrome processes..."
sudo pkill -f chrome 2>/dev/null || true
sudo pkill -f chromedriver 2>/dev/null || true
sleep 3

# Clean up Chrome directories
echo "🧹 Cleaning Chrome directories..."
sudo rm -rf /tmp/.com.google.Chrome* 2>/dev/null || true
sudo rm -rf /tmp/.org.chromium.Chromium* 2>/dev/null || true
sudo rm -rf /tmp/chrome_* 2>/dev/null || true
sudo rm -rf ~/.config/google-chrome/SingletonLock 2>/dev/null || true

# Create fresh directories
echo "📁 Creating fresh Chrome directories..."
mkdir -p ~/.config/google-chrome
mkdir -p ~/.cache/google-chrome

# Quick Chrome test
echo "🧪 Testing Chrome..."
cat > /tmp/quick_chrome_test.py << 'EOF'
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

options = Options()
options.add_argument("--headless")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--disable-gpu")

try:
    driver = webdriver.Chrome(options=options)
    driver.get("https://www.google.com")
    print("✅ Chrome test successful!")
    driver.quit()
except Exception as e:
    print(f"❌ Chrome test failed: {e}")
EOF

python3 /tmp/quick_chrome_test.py
rm /tmp/quick_chrome_test.py

echo ""
echo "🎉 QUICK FIX COMPLETED!"
echo "Try running your crawler now:"
echo "  python3 main.py --crawl-only"
echo ""
