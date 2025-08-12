# 🚀 HƯỚNG DẪN KHẮC PHỤC LỖI VPS - SPA VIP

## 📋 Tóm Tắt Vấn Đề

**Lỗi gặp phải:** `session not created: probably user data directory is already in use`

**Nguyên nhân:** Chrome WebDriver không thể khởi tạo session trên môi trường VPS Linux do:
- Thiếu cấu hình headless phù hợp
- Chrome user data directory bị conflict
- Thiếu các thư viện hệ thống cần thiết
- Memory/resource constraints trên VPS

## ✅ Giải Pháp Đã Triển Khai

### 1. **Cập Nhật Chrome Configuration (Đã Hoàn Thành)**

Đã cập nhật tất cả 5 crawler files với VPS-optimized Chrome options:

**Files đã fix:**
- `crawl/crawlers/cafef_general_crawler.py`
- `crawl/crawlers/fireant_crawler.py` 
- `crawl/crawlers/cafef_keyword_crawler.py`
- `crawl/crawlers/chungta_crawler.py`
- `crawl/crawl_stock/crawl_stock_price_history.py`

**Chrome options đã thêm:**
```python
options.add_argument("--no-sandbox")              # Bypass sandbox restrictions
options.add_argument("--disable-dev-shm-usage")   # Overcome limited resource problems
options.add_argument("--disable-features=VizDisplayCompositor")  # Disable compositor
options.add_argument("--memory-pressure-off")     # Reduce memory pressure
options.add_argument("--max_old_space_size=4096") # Increase V8 memory limit
```

### 2. **Troubleshooting Scripts (Mới Tạo)**

**`deployment/vps_troubleshoot.sh`** - Script tự động khắc phục:
- Cài đặt Chrome & ChromeDriver
- Dọn dẹp user data directories
- Cài đặt required libraries
- Tối ưu hóa system memory
- Tạo monitoring scripts

**`deployment/test_vps_crawlers.py`** - Suite test toàn diện:
- Test Chrome basic functionality
- Test individual crawlers
- Monitor memory usage
- Database connection test

## 🛠️ HƯỚNG DẪN TRIỂN KHAI

### Bước 1: Upload Files Lên VPS

```bash
# Trên máy local, upload toàn bộ project
scp -r SPA_vip/ user@your-vps-ip:/home/user/

# Hoặc clone từ git nếu đã push
git clone your-repo-url
cd SPA_vip
```

### Bước 2: Chạy Troubleshooting Script

```bash
# SSH vào VPS
ssh user@your-vps-ip

# Di chuyển vào project directory
cd /home/user/SPA_vip

# Make scripts executable
chmod +x deployment/vps_troubleshoot.sh
chmod +x deployment/test_vps_crawlers.py

# Chạy troubleshooting script (quan trọng!)
sudo ./deployment/vps_troubleshoot.sh
```

**Script này sẽ:**
- ✅ Cài đặt Chrome & ChromeDriver
- ✅ Dọn dẹp conflicting directories
- ✅ Cài đặt required system libraries
- ✅ Tối ưu hóa memory settings
- ✅ Tạo monitoring & cleanup scripts

### Bước 3: Test Crawlers

```bash
# Cài đặt Python dependencies
pip install -r requirements.txt

# Update paths trong test script
nano deployment/test_vps_crawlers.py
# Thay đổi dòng: sys.path.append('/path/to/spa_vip') 
# Thành path thực tế: sys.path.append('/home/user/SPA_vip')

# Chạy test suite
python3 deployment/test_vps_crawlers.py
```

### Bước 4: Test Crawling

```bash
# Test crawler riêng lẻ
cd crawl
python3 main_crawl.py --test-mode

# Hoặc test crawler cụ thể
python3 -c "
from crawlers.fireant_crawler import FireAntCrawler
crawler = FireAntCrawler()
driver = crawler.setup_driver()
driver.get('https://fireant.vn')
print('SUCCESS: ', driver.title)
driver.quit()
"
```

### Bước 5: Production Run

```bash
# Sử dụng optimized startup script
./deployment/start_spa_crawl.sh

# Hoặc chạy manual với monitoring
python3 main.py --crawl-only 2>&1 | tee logs/production_run.log
```

## 🔧 TROUBLESHOOTING

### Nếu Vẫn Gặp Lỗi Chrome:

```bash
# Kill tất cả Chrome processes
sudo pkill -f chrome
sudo pkill -f chromedriver

# Dọn dẹp temp directories
sudo rm -rf /tmp/.com.google.Chrome*
sudo rm -rf /tmp/chrome_*

# Chạy monitor script
./deployment/monitor_chrome.sh

# Thử lại
python3 main.py --crawl-only
```

### Kiểm Tra Chrome Installation:

```bash
# Check Chrome version
google-chrome --version

# Check ChromeDriver version  
chromedriver --version

# Test manual Chrome
google-chrome --headless --no-sandbox --dump-dom https://www.google.com
```

### Memory Issues:

```bash
# Check memory usage
free -h

# Monitor real-time
htop

# If high memory:
# 1. Reduce batch sizes in crawler configs
# 2. Run crawlers sequentially instead of parallel
# 3. Add memory cleanup in loops
```

### Database Connection Issues:

```bash
# Test database connection
python3 -c "
from database.supabase_manager import SupabaseManager
db = SupabaseManager()
print('DB Test:', db.execute_query('SELECT 1'))
"
```

## 📊 MONITORING & MAINTENANCE

### Auto Cleanup (Đã Setup):

```bash
# Check cleanup service status
sudo systemctl status spa-chrome-cleanup.timer

# Manual cleanup
./deployment/monitor_chrome.sh
```

### Log Monitoring:

```bash
# Check application logs
tail -f logs/spa_vip_pipeline_*.log

# Check system logs
journalctl -u spa-chrome-cleanup -f

# Check memory usage patterns
watch -n 5 'free -h && ps aux | grep chrome | wc -l'
```

## ⚡ OPTIMIZATION TIPS

### 1. **Memory Optimization:**
- Chạy crawlers tuần tự thay vì song song
- Giảm batch size từ 50 xuống 10-20
- Restart VPS hàng tuần để clear memory leaks

### 2. **Performance Optimization:**
```python
# Trong crawler configs, thêm:
options.add_argument("--disable-images")
options.add_argument("--disable-javascript")  # Nếu không cần JS
options.add_argument("--page-load-strategy=eager")
```

### 3. **Error Handling:**
```python
# Thêm retry logic:
from tenacity import retry, stop_after_attempt, wait_fixed

@retry(stop=stop_after_attempt(3), wait=wait_fixed(5))
def setup_driver_with_retry(self):
    return self.setup_driver()
```

## 🚨 EMERGENCY PROCEDURES

### Nếu VPS Bị Crash:

1. **SSH reconnect:**
   ```bash
   ssh user@your-vps-ip
   ```

2. **Kill all processes:**
   ```bash
   sudo pkill -f python
   sudo pkill -f chrome
   ```

3. **Clear memory:**
   ```bash
   sudo sync && echo 3 > /proc/sys/vm/drop_caches
   ```

4. **Restart services:**
   ```bash
   sudo systemctl restart spa-chrome-cleanup.timer
   ```

### Nếu Chrome Hoàn Toàn Không Hoạt Động:

1. **Reinstall Chrome:**
   ```bash
   sudo apt remove google-chrome-stable
   ./deployment/vps_troubleshoot.sh  # Reinstall
   ```

2. **Sử dụng Firefox thay thế:**
   ```python
   from selenium import webdriver
   from selenium.webdriver.firefox.options import Options
   
   options = Options()
   options.add_argument("--headless")
   driver = webdriver.Firefox(options=options)
   ```

## 📞 SUPPORT

**Nếu vẫn gặp vấn đề:**

1. Chạy test suite: `python3 deployment/test_vps_crawlers.py`
2. Gửi logs: `logs/crawler_test_*.log`
3. System info: `lsb_release -a && free -h && google-chrome --version`

**Common Issues & Solutions:**
- **Chrome crash:** Giảm memory usage, chạy ít crawlers đồng thời
- **Session timeout:** Tăng timeout values trong crawler configs  
- **Database connection:** Check network và Supabase credentials
- **Memory leak:** Restart crawlers định kỳ, monitor memory usage

---

🎉 **Với các fix này, VPS sẽ chạy được crawlers mà không gặp lỗi Chrome session anymore!**
