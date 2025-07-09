#!/bin/bash

# ログフォーマット統一化スクリプト
# 既存のログファイルを構造化ログ形式に変換

set -euo pipefail

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== CCTeam ログフォーマット統一化 ===${NC}"
echo ""

# 作業ディレクトリ
cd "$(dirname "$0")/.."

# バックアップディレクトリ作成
BACKUP_DIR="logs/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "既存ログのバックアップを作成中..."
cp -r logs/*.log "$BACKUP_DIR/" 2>/dev/null || true

# 構造化ログ用のPythonスクリプト
cat > /tmp/convert_logs.py << 'EOF'
#!/usr/bin/env python3
import re
import json
import sys
from datetime import datetime
from pathlib import Path

def parse_log_line(line, agent_name):
    """ログ行をパースして構造化データに変換"""
    # 一般的なログフォーマット: [timestamp] [level] message
    pattern = r'\[([^\]]+)\]\s*\[?(\w+)?\]?\s*(.*)'
    match = re.match(pattern, line.strip())
    
    if not match:
        return None
    
    timestamp_str, level, message = match.groups()
    
    # タイムスタンプの解析
    try:
        # 複数のフォーマットを試す
        for fmt in ['%Y-%m-%d %H:%M:%S', '%Y/%m/%d %H:%M:%S', '%d/%m/%Y %H:%M:%S']:
            try:
                timestamp = datetime.strptime(timestamp_str, fmt)
                break
            except:
                continue
        else:
            timestamp = datetime.now()
    except:
        timestamp = datetime.now()
    
    # ログレベルの正規化
    if not level:
        if any(word in message.lower() for word in ['error', 'exception', 'failed']):
            level = 'ERROR'
        elif any(word in message.lower() for word in ['warning', 'warn']):
            level = 'WARNING'
        else:
            level = 'INFO'
    else:
        level = level.upper()
    
    return {
        "timestamp": timestamp.isoformat(),
        "level": level,
        "agent": agent_name,
        "message": message.strip(),
        "legacy": True  # 変換されたログであることを示すフラグ
    }

def convert_log_file(input_file, output_file, agent_name):
    """ログファイルを構造化形式に変換"""
    entries = []
    
    try:
        with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if line.strip():
                    entry = parse_log_line(line, agent_name)
                    if entry:
                        entries.append(entry)
    except Exception as e:
        print(f"Error reading {input_file}: {e}")
        return 0
    
    # 構造化ログファイルに書き込み
    written = 0
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            for entry in entries:
                json.dump(entry, f, ensure_ascii=False)
                f.write('\n')
                written += 1
    except Exception as e:
        print(f"Error writing {output_file}: {e}")
    
    return written

def main():
    logs_dir = Path("logs")
    
    # 変換対象のログファイル
    log_files = {
        "boss.log": "boss",
        "worker1.log": "worker1",
        "worker2.log": "worker2",
        "worker3.log": "worker3",
        "system.log": "system",
        "communication.log": "communication"
    }
    
    total_converted = 0
    
    for log_file, agent_name in log_files.items():
        input_path = logs_dir / log_file
        output_path = logs_dir / f"{agent_name}_structured.jsonl"
        
        if input_path.exists():
            print(f"Converting {log_file}...", end=" ")
            count = convert_log_file(input_path, output_path, agent_name)
            print(f"{count} entries")
            total_converted += count
    
    print(f"\nTotal entries converted: {total_converted}")
    
    # エラーログの抽出
    print("\nExtracting error logs...")
    error_count = extract_errors(logs_dir)
    print(f"Extracted {error_count} error entries")

def extract_errors(logs_dir):
    """すべての構造化ログからエラーを抽出"""
    errors = []
    
    for jsonl_file in logs_dir.glob("*_structured.jsonl"):
        with open(jsonl_file, 'r', encoding='utf-8') as f:
            for line in f:
                try:
                    entry = json.loads(line)
                    if entry.get("level") in ["ERROR", "CRITICAL"]:
                        errors.append(entry)
                except:
                    continue
    
    # エラーを時系列でソート
    errors.sort(key=lambda x: x.get("timestamp", ""))
    
    # エラー専用ファイルに書き込み
    with open(logs_dir / "errors_all.jsonl", 'w', encoding='utf-8') as f:
        for error in errors:
            json.dump(error, f, ensure_ascii=False)
            f.write('\n')
    
    return len(errors)

if __name__ == "__main__":
    main()
EOF

# Pythonスクリプトを実行
python3 /tmp/convert_logs.py

# クリーンアップ
rm -f /tmp/convert_logs.py

echo ""
echo -e "${GREEN}✅ ログフォーマットの統一化が完了しました${NC}"
echo ""
echo "変換されたファイル:"
ls -la logs/*_structured.jsonl 2>/dev/null || echo "  （構造化ログなし）"
echo ""
echo -e "${YELLOW}バックアップ: $BACKUP_DIR${NC}"

# ログ分析レポートの生成
echo ""
echo "ログ分析レポートを生成中..."
python3 scripts/structured_logger.py analyze --hours 24 > reports/log_analysis_$(date +%Y%m%d).txt

echo -e "${GREEN}完了！${NC}"