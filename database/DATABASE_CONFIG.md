# Database Configuration Guide

## 📋 Cách thay đổi Supabase Database cho từng thành viên

### 🎯 Mục đích
Mỗi thành viên nhóm có thể sử dụng database Supabase riêng của mình mà không cần thay đổi code.

### 🔧 Cách thực hiện

**⚠️ LUU Ý**: Chỉ có 1 file .env duy nhất:
- `.env` (gốc) - File cấu hình cho toàn bộ hệ thống ✅

#### **Bước 1: Tạo file .env ở thư mục gốc**
```bash
# Tạo file .env từ template (ở thư mục gốc SPA_vip/)
copy .env.example .env
```

#### **Bước 2: Cập nhật thông tin database**
Mở file `.env` (ở thư mục gốc) và thay đổi:

```env
# Thay đổi thành thông tin Supabase của bạn
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_KEY=your_supabase_anon_key_here
```

#### **Bước 3: Test kết nối**
```bash
python database/test_connection.py
```

### 📂 Cấu trúc Database cần thiết

Đảm bảo database Supabase của bạn có các bảng sau:

#### **News Tables:**
- `General_News`
- `FPT_News`
- `GAS_News`
- `IMP_News`
- `VCB_News`

#### **Stock Tables:**
- `FPT_Stock`
- `GAS_Stock`
- `IMP_Stock`
- `VCB_Stock`

### 🗂️ Schema cho News Tables:
```sql
CREATE TABLE <STOCK>_News (
    id bigint PRIMARY KEY,
    title text NOT NULL,
    content text NOT NULL,
    date date NOT NULL,
    link text UNIQUE NOT NULL,
    ai_summary text,
    sentiment text
);
```

### 🗂️ Schema cho Stock Tables:
```sql
CREATE TABLE <STOCK>_Stock (
    id bigint PRIMARY KEY,
    date date NOT NULL,
    open numeric,
    high numeric,
    low numeric,
    close numeric,
    volume bigint,
    positive integer DEFAULT 0,
    negative integer DEFAULT 0,
    neutral integer DEFAULT 0,
    predicted_price numeric
);
```

### ⚙️ Cách hoạt động

1. **Mặc định**: Hệ thống sử dụng database trong `database/config.py`
2. **Với .env**: File `.env` ở thư mục gốc sẽ override các giá trị mặc định  
3. **Priority**: `.env` (gốc) > `config.py`

### 📂 Cấu trúc file:

```
SPA_vip/
├── .env          ← File duy nhất (cho toàn bộ hệ thống) ✅
├── .env.example  ← Template
└── database/
    └── config.py ← Default values
```

### ✅ **Ưu điểm của cấu hình tập trung:**
- ✅ 1 file duy nhất, không gây nhầm lẫn
- ✅ Áp dụng cho toàn bộ hệ thống
- ✅ Theo chuẩn Python project structure
- ✅ Dễ quản lý và bảo trì

### 🔒 Bảo mật

- ❌ **KHÔNG** commit file `.env` lên Git
- ✅ File `.env` đã được thêm vào `.gitignore`
- ✅ Mỗi thành viên có thể có database riêng
- ✅ Không ảnh hưởng đến thành viên khác

### 🆘 Troubleshooting

#### **Lỗi "Table doesn't exist"**
```bash
# Kiểm tra tên bảng trong Supabase của bạn
# Phải đúng format: FPT_News, GAS_News, etc.
```

#### **Lỗi "Invalid API key"**
```bash
# Kiểm tra SUPABASE_KEY trong file .env (thư mục gốc)
# Phải là anon/public key, không phải service_role key
```

#### **Lỗi "Project not found"**  
```bash
# Kiểm tra SUPABASE_URL trong file .env (thư mục gốc)
# Format: https://project-id.supabase.co
```

#### **Vẫn dùng database cũ?**
```bash
# Đảm bảo file .env ở thư mục gốc (SPA_vip/.env)
ls .env          # Phải có file này
ls .env.example  # Phải có template này

# File database/.env đã được xóa để tránh nhầm lẫn
```

### 📞 Hỗ trợ

Nếu gặp vấn đề, kiểm tra:
1. File `.env` có đúng format không
2. Database có đầy đủ bảng không  
3. API key có quyền đọc/ghi không
4. Chạy `python database/test_connection.py` để test
