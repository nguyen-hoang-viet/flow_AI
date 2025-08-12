# 🗞️ News Crawler System

Hệ thống crawl tin tức từ nhiều trang web khác nhau và lưu vào Supabase database.

## 📁 Cấu trúc dự án

```
crawl_news/
├── 📁 crawlers/           # Chứa tất cả các crawler
│   ├── fireant_crawler.py      # Crawler FireAnt (stock + general)
│   ├── cafef_keyword_crawler.py # Crawler CafeF với từ khóa
│   ├── cafef_general_crawler.py # Crawler CafeF tổng quát
│   ├── chungta_crawler.py       # Crawler ChungTa
│   └── __init__.py
│
├── 📁 config/             # Các file cấu hình
│   ├── database_config.py       # Cấu hình Supabase database
│   └── __init__.py
│
├── 📁 utils/              # Tiện ích (chưa sử dụng)
│   └── __init__.py
│
├── 📁 logs/               # Log files
│   └── .gitkeep
│
├── main_crawl_news.py     # File chính để chạy tất cả crawler
├── requirements.txt       # Python dependencies
├── PROJECT_STRUCTURE.md   # Hướng dẫn cấu trúc dự án
└── README.md             # File này
```

## 🚀 Cách sử dụng

### Chạy tất cả crawler
```bash
python main_crawl_news.py
```

### Chạy một crawler cụ thể
```bash
python main_crawl_news.py --single fireant_fpt
python main_crawl_news.py --single cafef_keyword
python main_crawl_news.py --single chungta
```

### Xem danh sách crawler
```bash
python main_crawl_news.py --list
```

## 🛠️ Cài đặt

### 1. Cài đặt dependencies
```bash
pip install -r requirements.txt
```

### 2. Cấu hình database
Kiểm tra file `config/database_config.py` để đảm bảo thông tin Supabase đúng.

### 3. Chạy crawler
```bash
python main_crawl_news.py
```

## 📊 Các crawler có sẵn

1. **FireAnt FPT Stock** (`fireant_fpt`)
   - Crawl tin tức cổ phiếu FPT từ FireAnt
   - Lưu vào bảng `Crawl_news`

2. **FireAnt General** (`fireant_general`)
   - Crawl tin tức tổng quát từ FireAnt
   - Lưu vào bảng `General_News`

3. **CafeF Keyword** (`cafef_keyword`)
   - Crawl tin tức theo từ khóa từ CafeF
   - Tìm kiếm mặc định: "FPT"

4. **CafeF General** (`cafef_general`)
   - Crawl tin tức chung từ CafeF
   - Scroll và thu thập nhiều bài viết

5. **ChungTa News** (`chungta`)
   - Crawl tin tức từ ChungTa.vn
   - Thu thập bài viết mới nhất

## 📝 Log files

Tất cả log được lưu trong thư mục `logs/` với format:
```
logs/crawl_log_YYYYMMDD_HHMMSS.log
```

## ⚙️ Cấu hình

- **MAX_SCROLLS**: Số lần scroll tối đa (mặc định: 20)
- **Database**: Supabase PostgreSQL
- **Selenium**: Chrome WebDriver với headless mode

## 🔧 Troubleshooting

### Lỗi import module
```bash
pip install -r requirements.txt
```

### Lỗi ChromeDriver
Đảm bảo Chrome browser đã cài đặt và ChromeDriver tương thích.

### Lỗi database connection
Kiểm tra thông tin Supabase URL và API key trong `config/database_config.py`.

## 📈 Future Improvements

- [ ] Thêm crawler cho các trang tin tức khác
- [ ] Implement retry mechanism
- [ ] Thêm email notification khi crawl xong
- [ ] Dashboard để monitor crawling status
- [ ] API để trigger crawling remotely
