# Database Module

Centralized database management for SPA VIP system.

## Structure

```
database/
├── __init__.py                 # Package initialization
├── config.py                   # Database configuration
├── supabase_manager.py         # Main database manager
├── schemas.py                  # Data schemas and validation
├── test_connection.py          # Connection testing
├── requirements.txt            # Dependencies
├── .env                        # Environment variables
└── README.md                   # This file
```

## Features

✅ **Centralized Configuration**: Single source of truth for all database settings  
✅ **Schema Validation**: Proper data validation before insertion  
✅ **Error Handling**: Comprehensive error handling and logging  
✅ **Connection Management**: Automatic connection management  
✅ **Statistics**: Built-in statistics and monitoring  
✅ **Type Safety**: Type hints and dataclass schemas  

## Usage

### Basic Usage

```python
from database import SupabaseManager, DatabaseConfig

# Initialize database manager
db_manager = SupabaseManager()

# Test connection
if db_manager.test_connection():
    print("✅ Database connected")

# Get statistics
stats = db_manager.get_table_stats()
print(f"Total articles: {sum(s['total'] for s in stats.values())}")
```

### Insert Article

```python
# Article data
article_data = {
    "title": "Sample News Title",
    "content": "Sample news content...",
    "link": "https://example.com/news/1",
    "date": "2025-08-03"
}

# Insert to FPT_News table
success = db_manager.insert_article("FPT_News", article_data)
if success:
    print("✅ Article inserted")
```

### Fetch Unsummarized Articles

```python
# Get articles that need AI summary
articles = db_manager.fetch_unsummarized_articles(
    table_name="FPT_News",  # or None for all tables
    limit=100
)

print(f"Found {len(articles)} articles to summarize")
```

### Update Summary

```python
# Update article with AI summary
success = db_manager.update_article_summary(
    article_id="123",
    summary="AI generated summary...",
    table_name="FPT_News"
)
```

## Configuration

### Environment Variables

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_key
LOG_LEVEL=INFO
```

### Database Tables

**News Tables:**
- `General_News`: General financial news
- `FPT_News`: FPT stock news
- `GAS_News`: GAS stock news  
- `IMP_News`: IMP stock news
- `VCB_News`: VCB stock news

**Stock Tables:**
- `FPT_Stock`: FPT stock prices
- `GAS_Stock`: GAS stock prices
- `IMP_Stock`: IMP stock prices
- `VCB_Stock`: VCB stock prices

## Schema

### News Schema

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

### Stock Schema

```sql
CREATE TABLE <STOCK>_Stock (
    id bigint PRIMARY KEY,
    date date NOT NULL,
    open decimal,
    high decimal,
    low decimal,
    close decimal NOT NULL,
    volume bigint,
    change_percent decimal,
    change_value decimal
);
```

## Testing

```bash
# Test database connection
python database/test_connection.py
```

## Integration

This database module is used by:
- **Crawl System**: For storing crawled articles and stock data
- **Summarization System**: For fetching articles and updating summaries
- **Main Pipeline**: For coordination and monitoring

## Error Handling

The module includes comprehensive error handling:
- Connection failures
- Data validation errors
- Duplicate detection
- Transaction rollbacks
- Detailed logging

## Performance

- Optimized queries with proper indexing
- Batch operations support
- Connection pooling via Supabase
- Efficient statistics calculation
