# News Summarization Pipeline - Integrated with Crawl System

This system automatically summarizes news articles stored in Supabase using a fine-tuned ViT5 model. It's fully integrated with the crawl system to process articles from all news tables.

## 🔗 Integration with Crawl System

This summarization pipeline is now **fully integrated** with the crawl folder:
- Uses the same Supabase database and configuration
- Processes articles from all news tables: `FPT_News`, `GAS_News`, `IMP_News`, `VCB_News`, `General_News`
- Shares database credentials and table structures

## 📊 Supported Tables

The system automatically processes articles from:
- **FPT_News**: FPT stock news 
- **GAS_News**: GAS stock news
- **IMP_News**: IMP stock news  
- **VCB_News**: VCB stock news
- **General_News**: General financial news

## Features

- ✅ Optimized for both CPU and GPU environments
- ✅ Batch processing capability
- ✅ Table-specific processing
- ✅ Continuous operation mode
- ✅ Performance monitoring
- ✅ Integration with crawl database
- ✅ Automatic duplicate detection

## Setup

### 1. Prerequisites
Make sure you have the crawl system set up first, as this depends on it.

### 2. Install dependencies
```bash
cd summarization
pip install -r requirements.txt
```

### 3. Model Setup
Place your trained ViT5 model in the `vit5_summarization_finetuned` folder:
```
vit5_summarization_finetuned/
├── config.json
├── model.safetensors
├── tokenizer_config.json
├── spiece.model
└── ...
```

### 4. Test Connection
```bash
python test_connection.py
```

## Usage

### Process All Articles
```bash
python main.py
```

### Process Specific Table
```bash
# Process only FPT news
python main.py --table FPT_News

# Process only general news  
python main.py --table General_News
```

### Show Statistics Only
```bash
python main.py --stats
```

## Command Line Options

- `--table <TABLE_NAME>`: Process specific table only
  - Choices: `General_News`, `FPT_News`, `GAS_News`, `IMP_News`, `VCB_News`
- `--stats`: Show table statistics only
- No arguments: Process all tables

## Configuration

The system uses configuration from the crawl folder by default. You can override settings in `.env`:

```env
# Model path
MODEL_PATH=./vit5_summarization_finetuned

# Hardware (auto-detected if not specified)  
DEVICE=auto
BATCH_SIZE=auto

# Text processing
MAX_INPUT_LENGTH=1024
MAX_TARGET_LENGTH=256
```

## Example Workflow

1. **Crawl news** (from crawl folder):
   ```bash
   cd ../crawl
   python main_crawl.py
   ```

2. **Summarize articles** (from summarization folder):
   ```bash
   cd ../summarization
   python main.py
   ```

3. **Check specific table**:
   ```bash
   python main.py --table FPT_News
   ```

## Database Schema

The system works with the following table structure:
```sql
-- Each news table has these columns:
CREATE TABLE <STOCK>_News (
    id bigint PRIMARY KEY,
    title text,
    content text, 
    date date,
    link text UNIQUE,
    ai_summary text,  -- This gets populated by summarization
    sentiment text
);
```

## Monitoring

The system provides detailed logging:
- Table statistics on startup
- Progress bars for batch processing  
- Success/failure rates
- Performance metrics

## Error Handling

- Automatic fallback from batch to sequential processing
- GPU memory management
- Database connection retries
- Graceful handling of malformed articles

## Performance

- **GPU**: ~5-10 articles per batch
- **CPU**: ~2-3 articles per batch  
- **Memory**: Optimized for both high and low memory environments
- **Speed**: Processes ~100-500 articles per hour (depending on hardware)

## Troubleshooting

### Import Errors
If you get import errors, make sure you're running from the correct directory and the crawl folder is properly set up.

### Model Not Found
Ensure your ViT5 model is in the correct folder with all required files.

### Database Connection Issues
Run `python test_connection.py` to diagnose database connection problems.

### Out of Memory
Reduce `BATCH_SIZE` in the config or use CPU mode.

## Integration Benefits

✅ **Unified Database**: Single source of truth for all news data  
✅ **Consistent Schema**: Same table structure across crawl and summarization  
✅ **No Data Duplication**: Direct integration prevents data sync issues  
✅ **Shared Configuration**: Same database credentials and settings  
✅ **End-to-End Pipeline**: Seamless flow from crawling to summarization