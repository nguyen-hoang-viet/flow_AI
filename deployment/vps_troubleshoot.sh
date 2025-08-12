#!/bin/bash

# ====================================================================
# VPS TROUBLESHOOTING SCRIPT FOR SPA VIP
# Khắc phục lỗi Chrome session not created trên VPS
# ====================================================================

set -e

echo "🔧 SPA VIP VPS TROUBLESHOOTING"
echo "==============================="
echo "Khắc phục lỗi: session not created: probably user data directory is already in use"
echo ""

# =============== KIỂM TRA HỆ THỐNG ===============

echo "📊 Checking system information..."
echo "OS: $(lsb_release -d | cut -f2)"
echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "CPU: $(nproc) cores"
echo "Architecture: $(uname -m)"
echo ""

# =============== KIỂM TRA CHROME ===============

echo "🌐 Checking Chrome installation..."

# Kiểm tra Chrome có cài đặt không
if command -v google-chrome &> /dev/null; then
    CHROME_VERSION=$(google-chrome --version)
    echo "✅ Chrome installed: $CHROME_VERSION"
else
    echo "❌ Chrome not found. Installing..."
    
    # Cài đặt Chrome
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable
    
    echo "✅ Chrome installed successfully"
fi

# =============== KIỂM TRA CHROMEDRIVER ===============

echo "🚗 Checking ChromeDriver..."

if command -v chromedriver &> /dev/null; then
    CHROMEDRIVER_VERSION=$(chromedriver --version)
    echo "✅ ChromeDriver found: $CHROMEDRIVER_VERSION"
else
    echo "❌ ChromeDriver not found. Installing..."
    
    # Lấy phiên bản Chrome
    CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+')
    MAJOR_VERSION=${CHROME_VERSION%%.*}
    
    # Tải ChromeDriver phù hợp
    CHROMEDRIVER_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${MAJOR_VERSION})
    wget -O chromedriver.zip https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip
    unzip chromedriver.zip
    sudo mv chromedriver /usr/local/bin/
    sudo chmod +x /usr/local/bin/chromedriver
    rm chromedriver.zip
    
    echo "✅ ChromeDriver installed successfully"
fi

# =============== DỌN DẸP CHROME DATA ===============

echo "🧹 Cleaning Chrome user data directories..."

# Dọn dẹp thư mục Chrome user data cũ
sudo pkill -f chrome || true
sudo pkill -f chromedriver || true
sleep 2

# Xóa các thư mục Chrome data cũ
sudo rm -rf /tmp/.com.google.Chrome* || true
sudo rm -rf /tmp/.org.chromium.Chromium* || true
sudo rm -rf ~/.config/google-chrome || true
sudo rm -rf ~/.cache/google-chrome || true
sudo rm -rf /tmp/chrome_* || true

echo "✅ Chrome data directories cleaned"

# =============== TẠO THƯ MỤC MỚI ===============

echo "📁 Creating new Chrome directories..."

# Tạo thư mục Chrome data mới với quyền phù hợp
mkdir -p ~/.config/google-chrome
mkdir -p ~/.cache/google-chrome
chmod -R 755 ~/.config/google-chrome
chmod -R 755 ~/.cache/google-chrome

echo "✅ New Chrome directories created"

# =============== KIỂM TRA VÀ CÀI ĐẶT THƯ VIỆN ===============

echo "📦 Checking required libraries..."

# Kiểm tra và cài đặt các thư viện cần thiết
REQUIRED_LIBS=(
    "fonts-liberation"
    "libasound2"
    "libatk-bridge2.0-0"
    "libdrm2"
    "libgtk-3-0"
    "libnspr4"
    "libnss3"
    "libxcomposite1"
    "libxdamage1"
    "libxrandr2"
    "xdg-utils"
    "libxss1"
    "libgconf-2-4"
)

for lib in "${REQUIRED_LIBS[@]}"; do
    if dpkg -l | grep -q "^ii  $lib "; then
        echo "✅ $lib is installed"
    else
        echo "⚠️ Installing $lib..."
        sudo apt install -y "$lib"
    fi
done

# =============== TỐI ƯU HÓA SYSTEM ===============

echo "⚡ Optimizing system for Chrome..."

# Tăng shared memory limit
echo "kernel.shmmax = 268435456" | sudo tee -a /etc/sysctl.conf
echo "kernel.shmall = 268435456" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Tạo thư mục /dev/shm nếu không tồn tại
sudo mkdir -p /dev/shm
sudo chmod 1777 /dev/shm

echo "✅ System optimized"

# =============== TEST CHROME ===============

echo "🧪 Testing Chrome..."

# Test Chrome headless
cat > test_chrome.py << 'EOF'
#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import sys

def test_chrome():
    options = Options()
    # VPS-optimized Chrome options
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-features=VizDisplayCompositor")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-plugins")
    options.add_argument("--disable-images")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--user-agent=Mozilla/5.0 (Linux; x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    options.add_argument("--memory-pressure-off")
    options.add_argument("--max_old_space_size=4096")
    
    try:
        driver = webdriver.Chrome(options=options)
        driver.get("https://www.google.com")
        title = driver.title
        driver.quit()
        
        if "Google" in title:
            print("✅ Chrome test successful!")
            return True
        else:
            print("❌ Chrome test failed - unexpected page title")
            return False
            
    except Exception as e:
        print(f"❌ Chrome test failed: {e}")
        return False

if __name__ == "__main__":
    success = test_chrome()
    sys.exit(0 if success else 1)
EOF

chmod +x test_chrome.py

# Chạy test
if python3 test_chrome.py; then
    echo "🎉 Chrome test passed!"
else
    echo "❌ Chrome test failed. Trying alternative solutions..."
    
    # Thử cài đặt chromium thay thế
    echo "📦 Installing Chromium as alternative..."
    sudo apt install -y chromium-browser chromium-chromedriver
    
    # Update symlink
    sudo ln -sf /usr/bin/chromium-browser /usr/bin/google-chrome || true
    sudo ln -sf /usr/bin/chromedriver /usr/local/bin/chromedriver || true
fi

# Cleanup test file
rm -f test_chrome.py

# =============== TẠO SCRIPT MONITOR ===============

echo "📊 Creating Chrome monitoring script..."

cat > monitor_chrome.sh << 'EOF'
#!/bin/bash
# Monitor Chrome processes and clean up if stuck

echo "🔍 Chrome Process Monitor"
echo "========================"

# Kill stuck Chrome processes
CHROME_PROCESSES=$(ps aux | grep -E "(chrome|chromedriver)" | grep -v grep | wc -l)
if [ $CHROME_PROCESSES -gt 0 ]; then
    echo "⚠️ Found $CHROME_PROCESSES Chrome processes running"
    echo "Killing stuck processes..."
    sudo pkill -f chrome
    sudo pkill -f chromedriver
    sleep 2
fi

# Clean up temp files
echo "🧹 Cleaning up temporary files..."
sudo rm -rf /tmp/.com.google.Chrome* 2>/dev/null || true
sudo rm -rf /tmp/.org.chromium.Chromium* 2>/dev/null || true
sudo rm -rf /tmp/chrome_* 2>/dev/null || true

# Check memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
echo "💾 Memory usage: ${MEMORY_USAGE}%"

if (( $(echo "$MEMORY_USAGE > 85" | bc -l) )); then
    echo "⚠️ High memory usage detected!"
    echo "Consider reducing batch sizes in your application"
fi

echo "✅ Chrome monitoring completed"
EOF

chmod +x monitor_chrome.sh

# =============== TẠO STARTUP SCRIPT ===============

echo "🚀 Creating optimized startup script..."

cat > start_spa_crawl.sh << 'EOF'
#!/bin/bash
# Optimized startup script for SPA VIP crawling on VPS

echo "🚀 Starting SPA VIP Crawling (VPS Optimized)"
echo "============================================"

# Clean up before start
./monitor_chrome.sh

# Set environment variables for Chrome
export DISPLAY=:99
export CHROME_BIN=/usr/bin/google-chrome
export CHROMEDRIVER_PATH=/usr/local/bin/chromedriver

# Run crawling with memory monitoring
echo "📊 Starting crawl with memory monitoring..."

# Monitor memory during execution
(
    while true; do
        MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        if (( $(echo "$MEMORY_USAGE > 90" | bc -l) )); then
            echo "🚨 CRITICAL: Memory usage ${MEMORY_USAGE}% - killing Chrome processes"
            pkill -f chrome
            pkill -f chromedriver
            sleep 5
        fi
        sleep 30
    done
) &

MONITOR_PID=$!

# Run your crawling command here
# Example:
# cd /path/to/spa_vip && python main.py --crawl-only

# Kill monitor when done
kill $MONITOR_PID 2>/dev/null || true

echo "✅ Crawling completed successfully"
EOF

chmod +x start_spa_crawl.sh

# =============== TẠO SYSTEMD SERVICE ===============

echo "⚙️ Creating systemd service..."

sudo tee /etc/systemd/system/spa-chrome-cleanup.service > /dev/null << EOF
[Unit]
Description=SPA Chrome Cleanup Service
After=network.target

[Service]
Type=oneshot
User=$USER
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/monitor_chrome.sh

[Install]
WantedBy=multi-user.target
EOF

# Tạo timer để chạy cleanup định kỳ
sudo tee /etc/systemd/system/spa-chrome-cleanup.timer > /dev/null << EOF
[Unit]
Description=Run SPA Chrome Cleanup every 30 minutes
Requires=spa-chrome-cleanup.service

[Timer]
OnCalendar=*:0/30
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable spa-chrome-cleanup.timer
sudo systemctl start spa-chrome-cleanup.timer

echo "✅ Systemd service created and enabled"

# =============== FINAL CHECK ===============

echo ""
echo "🔧 TROUBLESHOOTING COMPLETED!"
echo "============================="
echo ""
echo "✅ Actions completed:"
echo "  - Chrome and ChromeDriver installed/updated"
echo "  - User data directories cleaned"
echo "  - Required libraries installed"
echo "  - System optimized for Chrome"
echo "  - Monitoring scripts created"
echo "  - Cleanup service enabled"
echo ""
echo "🚀 Next steps:"
echo "  1. Test your crawler: python main.py --crawl-only"
echo "  2. Monitor with: ./monitor_chrome.sh"
echo "  3. Use optimized startup: ./start_spa_crawl.sh"
echo ""
echo "🆘 If problems persist:"
echo "  - Check logs: journalctl -u spa-chrome-cleanup"
echo "  - Monitor memory: free -h"
echo "  - Kill stuck processes: sudo pkill -f chrome"
echo "  - Reduce batch sizes in crawler configuration"
echo ""
echo "💡 Tips for VPS optimization:"
echo "  - Run crawlers sequentially, not in parallel"
echo "  - Use smaller batch sizes (5-10 instead of 50)"
echo "  - Monitor memory usage during execution"
echo "  - Restart VPS weekly to clear memory leaks"
