#!/usr/bin/env python3
"""
CCTeam 構造化ログシステム
エラーログの充実化とJSON形式での構造化ログ出力
"""

import json
import datetime
import traceback
import sys
import os
from pathlib import Path
from typing import Dict, Any, Optional, List
from enum import Enum
import inspect

class LogLevel(Enum):
    """ログレベル定義"""
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"

class StructuredLogger:
    """構造化ログを出力するロガー"""
    
    def __init__(self, agent_name: str, log_dir: str = "logs"):
        self.agent_name = agent_name
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(exist_ok=True)
        
        # 通常ログファイル
        self.log_file = self.log_dir / f"{agent_name}.log"
        # 構造化ログファイル（JSON）
        self.structured_log_file = self.log_dir / f"{agent_name}_structured.jsonl"
        # エラー専用ログ
        self.error_log_file = self.log_dir / "errors_all.jsonl"
        
    def _get_caller_info(self) -> Dict[str, Any]:
        """呼び出し元の情報を取得"""
        frame = inspect.currentframe()
        if frame and frame.f_back and frame.f_back.f_back:
            caller_frame = frame.f_back.f_back
            return {
                "file": os.path.basename(caller_frame.f_code.co_filename),
                "function": caller_frame.f_code.co_name,
                "line": caller_frame.f_lineno
            }
        return {}
    
    def _create_log_entry(self, level: LogLevel, message: str, 
                         context: Optional[Dict[str, Any]] = None,
                         error: Optional[Exception] = None) -> Dict[str, Any]:
        """構造化ログエントリを作成"""
        entry = {
            "timestamp": datetime.datetime.now().isoformat(),
            "level": level.value,
            "agent": self.agent_name,
            "message": message,
            "caller": self._get_caller_info()
        }
        
        # コンテキスト情報を追加
        if context:
            entry["context"] = context
        
        # エラー情報を追加
        if error:
            entry["error"] = {
                "type": type(error).__name__,
                "message": str(error),
                "traceback": traceback.format_exc().splitlines()
            }
            
            # エラー固有の属性を抽出
            if hasattr(error, "__dict__"):
                entry["error"]["attributes"] = {
                    k: str(v) for k, v in error.__dict__.items()
                    if not k.startswith("_")
                }
        
        return entry
    
    def _write_to_file(self, file_path: Path, entry: Dict[str, Any]):
        """ファイルにログエントリを書き込み"""
        with open(file_path, 'a', encoding='utf-8') as f:
            json.dump(entry, f, ensure_ascii=False)
            f.write('\n')
    
    def _write_plain_log(self, level: LogLevel, message: str):
        """プレーンテキストログを書き込み"""
        timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_line = f"[{timestamp}] [{level.value}] {message}\n"
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_line)
        
        # コンソールにも出力
        if level in [LogLevel.ERROR, LogLevel.CRITICAL]:
            print(f"\033[0;31m{log_line.strip()}\033[0m", file=sys.stderr)
        elif level == LogLevel.WARNING:
            print(f"\033[1;33m{log_line.strip()}\033[0m")
        else:
            print(log_line.strip())
    
    def debug(self, message: str, context: Optional[Dict[str, Any]] = None):
        """デバッグログ"""
        entry = self._create_log_entry(LogLevel.DEBUG, message, context)
        self._write_to_file(self.structured_log_file, entry)
        self._write_plain_log(LogLevel.DEBUG, message)
    
    def info(self, message: str, context: Optional[Dict[str, Any]] = None):
        """情報ログ"""
        entry = self._create_log_entry(LogLevel.INFO, message, context)
        self._write_to_file(self.structured_log_file, entry)
        self._write_plain_log(LogLevel.INFO, message)
    
    def warning(self, message: str, context: Optional[Dict[str, Any]] = None):
        """警告ログ"""
        entry = self._create_log_entry(LogLevel.WARNING, message, context)
        self._write_to_file(self.structured_log_file, entry)
        self._write_plain_log(LogLevel.WARNING, message)
    
    def error(self, message: str, error: Optional[Exception] = None, 
              context: Optional[Dict[str, Any]] = None):
        """エラーログ"""
        entry = self._create_log_entry(LogLevel.ERROR, message, context, error)
        self._write_to_file(self.structured_log_file, entry)
        self._write_to_file(self.error_log_file, entry)  # エラー専用ログにも記録
        self._write_plain_log(LogLevel.ERROR, message)
        
        # エラーループ検出システムに通知
        if error:
            self._check_error_loop(message, error)
    
    def critical(self, message: str, error: Optional[Exception] = None,
                 context: Optional[Dict[str, Any]] = None):
        """重大エラーログ"""
        entry = self._create_log_entry(LogLevel.CRITICAL, message, context, error)
        self._write_to_file(self.structured_log_file, entry)
        self._write_to_file(self.error_log_file, entry)
        self._write_plain_log(LogLevel.CRITICAL, message)
    
    def _check_error_loop(self, message: str, error: Exception):
        """エラーループ検出システムと連携"""
        try:
            error_msg = f"{type(error).__name__}: {str(error)}"
            os.system(f'python3 scripts/error_loop_detector.py check '
                     f'--agent {self.agent_name} '
                     f'--error "{error_msg}"')
        except:
            pass  # エラーループ検出の失敗は無視
    
    def log_task_start(self, task_name: str, task_details: Optional[Dict[str, Any]] = None):
        """タスク開始ログ"""
        context = {"task_name": task_name, "status": "started"}
        if task_details:
            context.update(task_details)
        self.info(f"タスク開始: {task_name}", context)
    
    def log_task_complete(self, task_name: str, result: Optional[Dict[str, Any]] = None):
        """タスク完了ログ"""
        context = {"task_name": task_name, "status": "completed"}
        if result:
            context["result"] = result
        self.info(f"タスク完了: {task_name}", context)
    
    def log_api_call(self, api_name: str, params: Dict[str, Any], 
                     response: Optional[Dict[str, Any]] = None,
                     error: Optional[Exception] = None):
        """API呼び出しログ"""
        context = {
            "api": api_name,
            "params": params
        }
        
        if response:
            context["response"] = response
            self.info(f"API呼び出し成功: {api_name}", context)
        elif error:
            self.error(f"API呼び出し失敗: {api_name}", error, context)
    
    def log_communication(self, from_agent: str, to_agent: str, 
                         message: str, success: bool = True):
        """エージェント間通信ログ"""
        context = {
            "from": from_agent,
            "to": to_agent,
            "message": message[:200],  # 長いメッセージは切り詰め
            "success": success
        }
        
        if success:
            self.info(f"通信: {from_agent} → {to_agent}", context)
        else:
            self.error(f"通信失敗: {from_agent} → {to_agent}", context=context)


class LogAnalyzer:
    """構造化ログを分析するツール"""
    
    def __init__(self, log_dir: str = "logs"):
        self.log_dir = Path(log_dir)
    
    def analyze_errors(self, time_range: Optional[int] = None) -> Dict[str, Any]:
        """エラーログを分析"""
        error_file = self.log_dir / "errors_all.jsonl"
        if not error_file.exists():
            return {"total": 0, "by_type": {}, "by_agent": {}}
        
        errors = []
        with open(error_file, 'r', encoding='utf-8') as f:
            for line in f:
                try:
                    entry = json.loads(line)
                    errors.append(entry)
                except:
                    continue
        
        # 時間範囲でフィルタ
        if time_range:
            cutoff = datetime.datetime.now() - datetime.timedelta(seconds=time_range)
            errors = [e for e in errors 
                     if datetime.datetime.fromisoformat(e["timestamp"]) > cutoff]
        
        # 分析
        by_type = {}
        by_agent = {}
        
        for error in errors:
            # エラータイプ別
            if "error" in error and "type" in error["error"]:
                error_type = error["error"]["type"]
                by_type[error_type] = by_type.get(error_type, 0) + 1
            
            # エージェント別
            agent = error.get("agent", "unknown")
            by_agent[agent] = by_agent.get(agent, 0) + 1
        
        return {
            "total": len(errors),
            "by_type": by_type,
            "by_agent": by_agent,
            "recent": errors[-10:] if errors else []
        }
    
    def get_agent_activity(self, agent_name: str, 
                          time_range: Optional[int] = None) -> Dict[str, Any]:
        """特定エージェントのアクティビティを取得"""
        log_file = self.log_dir / f"{agent_name}_structured.jsonl"
        if not log_file.exists():
            return {"total": 0, "by_level": {}}
        
        entries = []
        with open(log_file, 'r', encoding='utf-8') as f:
            for line in f:
                try:
                    entry = json.loads(line)
                    entries.append(entry)
                except:
                    continue
        
        # 時間範囲でフィルタ
        if time_range:
            cutoff = datetime.datetime.now() - datetime.timedelta(seconds=time_range)
            entries = [e for e in entries 
                      if datetime.datetime.fromisoformat(e["timestamp"]) > cutoff]
        
        # レベル別集計
        by_level = {}
        for entry in entries:
            level = entry.get("level", "UNKNOWN")
            by_level[level] = by_level.get(level, 0) + 1
        
        return {
            "total": len(entries),
            "by_level": by_level,
            "recent": entries[-10:] if entries else []
        }


def main():
    """CLIインターフェース"""
    import argparse
    
    parser = argparse.ArgumentParser(description='CCTeam Structured Logger')
    parser.add_argument('command', choices=['test', 'analyze', 'agent'],
                        help='Command to execute')
    parser.add_argument('--agent', help='Agent name')
    parser.add_argument('--hours', type=int, help='Time range in hours')
    
    args = parser.parse_args()
    
    if args.command == 'test':
        # テストログ出力
        logger = StructuredLogger("test")
        
        logger.info("テストログシステム起動")
        logger.debug("デバッグ情報", {"key": "value"})
        logger.warning("警告メッセージ", {"threshold": 80, "current": 85})
        
        try:
            1 / 0
        except Exception as e:
            logger.error("ゼロ除算エラー", e, {"operation": "division"})
        
        logger.log_task_start("test_task", {"param1": "value1"})
        logger.log_task_complete("test_task", {"result": "success"})
        
        print("テストログを出力しました")
    
    elif args.command == 'analyze':
        # エラー分析
        analyzer = LogAnalyzer()
        time_range = args.hours * 3600 if args.hours else None
        
        result = analyzer.analyze_errors(time_range)
        print(f"\n🔍 エラー分析結果")
        print(f"総エラー数: {result['total']}")
        print(f"\nエラータイプ別:")
        for error_type, count in result['by_type'].items():
            print(f"  {error_type}: {count}")
        print(f"\nエージェント別:")
        for agent, count in result['by_agent'].items():
            print(f"  {agent}: {count}")
    
    elif args.command == 'agent':
        # エージェント活動分析
        if not args.agent:
            print("エラー: --agent を指定してください")
            sys.exit(1)
        
        analyzer = LogAnalyzer()
        time_range = args.hours * 3600 if args.hours else None
        
        result = analyzer.get_agent_activity(args.agent, time_range)
        print(f"\n📊 {args.agent} の活動")
        print(f"総ログ数: {result['total']}")
        print(f"\nレベル別:")
        for level, count in result['by_level'].items():
            print(f"  {level}: {count}")


if __name__ == "__main__":
    main()