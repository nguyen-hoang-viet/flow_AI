# 📁 CẤU TRÚC DỰ ÁN CRAWL NEWS

## 🎯 **ĐỀ XUẤT CẤU TRÚC THƯ MỤC**

```
crawl_news/
├── 📁 crawlers/           # Chứa tất cả các file crawler
│   ├── fireant_crawler.py
│   ├── cafef_crawler.py
│   ├── chungta_crawler.py
│   └── __init__.py
│
├── 📁 config/             # Chứa các file cấu hình
│   ├── database_config.py
│   ├── crawler_config.py  # Cấu hình chung cho crawler
│   └── settings.py        # Cài đặt global
│
├── 📁 utils/              # Các tiện ích và helper functions
│   ├── date_parser.py     # Xử lý ngày tháng
│   ├── web_driver.py      # Setup Selenium driver
│   └── validators.py      # Validate dữ liệu
│
├── 📁 logs/               # Thư mục chứa log files
│   └── .gitkeep
│
├── main_crawl_news.py     # File chính điều khiển
├── requirements.txt       # Dependencies
└── README.md             # Hướng dẫn sử dụng
```

## 🏷️ **CÁC CÁCH ĐẶT TÊN ĐỀ XUẤT**

### **Option 1: Theo chức năng (Recommended)**
```
📁 crawlers/
   ├── fireant_news_crawler.py
   ├── cafef_news_crawler.py  
   ├── chungta_news_crawler.py
   └── base_crawler.py        # Base class chung

📁 config/
   ├── database_manager.py    # Quản lý database
   ├── crawler_settings.py    # Cài đặt crawler
   └── site_configs.py        # Config từng trang web
```

### **Option 2: Theo domain**
```
📁 crawlers/
   ├── fireant/
   │   ├── stock_crawler.py
   │   └── general_crawler.py
   ├── cafef/
   │   ├── keyword_crawler.py
   │   └── general_crawler.py
   └── chungta/
       └── news_crawler.py

📁 config/
   └── db_config.py
```

### **Option 3: Compact (Đơn giản)**
```
📁 src/
   ├── crawlers.py           # Tất cả crawler trong 1 file
   ├── config.py            # Tất cả config trong 1 file
   └── utils.py             # Utilities

📁 data/                    # Output data
📁 logs/                    # Log files
```

## 🚀 **HƯỚNG DẪN MIGRATE**

### **Bước 1: Di chuyển files crawler**
```bash
# Di chuyển các file crawler vào thư mục crawlers/
mv crawl_fireant.py crawlers/fireant_crawler.py
mv crawl_cafef_rieng.py crawlers/cafef_keyword_crawler.py
mv crawl_cafef_chung.py crawlers/cafef_general_crawler.py
mv crawl_chungta.py crawlers/chungta_crawler.py
```

### **Bước 2: Di chuyển config**
```bash
# Di chuyển database config
mv database_config.py config/database_manager.py
```

### **Bước 3: Cập nhật imports trong main_crawl_news.py**
```python
# Thay đổi from:
from crawl_fireant import crawl_fireant, crawl_fireant_general

# Thành:
from crawlers.fireant_crawler import crawl_fireant, crawl_fireant_general
from config.database_manager import get_database_manager
```

## 📋 **LỢI ÍCH CỦA VIỆC TỔ CHỨC**

### ✅ **Ưu điểm:**
- **Dễ tìm kiếm**: Biết ngay file nào ở đâu
- **Dễ bảo trì**: Tách biệt rõ ràng các chức năng
- **Dễ mở rộng**: Thêm crawler mới dễ dàng
- **Professional**: Cấu trúc chuẩn của dự án Python

### 🎯 **Tên file đề xuất cụ thể:**
```
📁 crawlers/
   ├── fireant_stock_crawler.py    # Crawler cổ phiếu FireAnt
   ├── fireant_general_crawler.py  # Crawler tin tức chung FireAnt
   ├── cafef_keyword_crawler.py    # Crawler từ khóa CafeF
   ├── cafef_general_crawler.py    # Crawler chung CafeF
   ├── chungta_crawler.py          # Crawler ChungTa
   └── __init__.py                 # Package init

📁 config/
   ├── database_config.py          # Cấu hình database
   ├── crawler_constants.py        # Các hằng số crawler
   └── site_urls.py                # URLs các trang web

📁 utils/
   ├── selenium_helper.py          # Helper cho Selenium
   ├── date_parser.py              # Parse ngày tháng
   └── text_cleaner.py             # Làm sạch text
```

## 🔥 **RECOMMENDATION**

**Tôi khuyên dùng Option 1** vì:
- ✅ Rõ ràng, dễ hiểu
- ✅ Dễ maintain và debug
- ✅ Chuẩn Python project structure
- ✅ Scalable cho tương lai

Bạn muốn tôi implement cấu trúc nào?
