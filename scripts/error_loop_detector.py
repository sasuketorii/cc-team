#!/usr/bin/env python3
"""
CCTeam エラーループ検出システム
同じエラーが繰り返される場合に自動的にエージェントを停止
"""

import json
import datetime
import sys
import os
from pathlib import Path
from typing import Dict, List
import hashlib
import time

class ErrorLoopDetector:
    """エラーループを検出し、暴走を防止するシステム"""
    
    def __init__(self, threshold: int = 3, time_window: int = 300):
        """
        Args:
            threshold: 同じエラーが何回続いたらループと判定するか
            time_window: エラーをカウントする時間枠（秒）
        """
        self.threshold = threshold
        self.time_window = time_window
        self.error_history: Dict[str, List[float]] = {}
        self.error_file = Path("logs/error_loops.json")
        self.load_history()
    
    def load_history(self):
        """過去のエラー履歴を読み込む"""
        if self.error_file.exists():
            try:
                with open(self.error_file, 'r') as f:
                    data = json.load(f)
                    # タイムスタンプを float に変換
                    self.error_history = {
                        k: [float(ts) for ts in v] 
                        for k, v in data.items()
                    }
            except:
                self.error_history = {}
    
    def save_history(self):
        """エラー履歴を保存"""
        self.error_file.parent.mkdir(exist_ok=True)
        with open(self.error_file, 'w') as f:
            json.dump(self.error_history, f, indent=2)
    
    def check_error(self, agent: str, error_msg: str) -> bool:
        """
        エラーをチェックし、ループが検出されたらTrue を返す
        
        Args:
            agent: エージェント名
            error_msg: エラーメッセージ
            
        Returns:
            bool: エラーループが検出された場合True
        """
        # エラーメッセージのハッシュを生成（正規化）
        normalized_error = self._normalize_error(error_msg)
        error_hash = hashlib.md5(normalized_error.encode()).hexdigest()[:16]
        key = f"{agent}:{error_hash}"
        
        current_time = time.time()
        
        # 時間枠外の古いエラーを削除
        if key in self.error_history:
            self.error_history[key] = [
                ts for ts in self.error_history[key] 
                if current_time - ts <= self.time_window
            ]
        else:
            self.error_history[key] = []
        
        # 新しいエラーを追加
        self.error_history[key].append(current_time)
        
        # エラー回数をチェック
        error_count = len(self.error_history[key])
        
        if error_count >= self.threshold:
            self._handle_error_loop(agent, error_msg, error_count)
            self.save_history()
            return True
        
        self.save_history()
        return False
    
    def _normalize_error(self, error_msg: str) -> str:
        """エラーメッセージを正規化（タイムスタンプなどを除去）"""
        # 一般的なパターンを除去
        import re
        
        # タイムスタンプパターンを除去
        normalized = re.sub(r'\d{4}-\d{2}-\d{2}T?\d{2}:\d{2}:\d{2}', '', error_msg)
        normalized = re.sub(r'\d+ms', '', normalized)
        normalized = re.sub(r'line \d+', 'line X', normalized)
        normalized = re.sub(r'column \d+', 'column X', normalized)
        
        # 空白を正規化
        normalized = ' '.join(normalized.split())
        
        return normalized.lower()
    
    def _handle_error_loop(self, agent: str, error_msg: str, count: int):
        """エラーループが検出された時の処理"""
        timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        # エラーログに記録
        with open('logs/error_loops_detected.log', 'a') as f:
            f.write(f"\n[{timestamp}] ERROR LOOP DETECTED\n")
            f.write(f"Agent: {agent}\n")
            f.write(f"Count: {count} times in {self.time_window} seconds\n")
            f.write(f"Error: {error_msg[:200]}...\n")
            f.write("-" * 80 + "\n")
        
        # エージェントに停止指示を送信
        self._send_stop_command(agent)
        
        # システムログに記録
        with open('logs/system.log', 'a') as f:
            f.write(f"[{timestamp}] ⚠️ Error loop detected for {agent}. Agent stopped.\n")
    
    def _send_stop_command(self, agent: str):
        """エージェントに建設的な問題解決指示を送信"""
        stop_message = (
            "🚨 エラーループが検出されました（同じエラーが3回以上発生）。\n\n"
            "⛔ コード修正は一旦禁止します。代わりに以下を実行してください：\n\n"
            "1️⃣ **状況整理**\n"
            "   - 現在発生しているエラーの内容を箇条書きで整理\n"
            "   - これまで試した修正方法をリストアップ\n"
            "   - なぜ修正が効かないのか仮説を立てる\n\n"
            "2️⃣ **類似エラーの調査**\n"
            "   - エラーメッセージで検索して類似事例を探す\n"
            "   - Stack Overflow、GitHub Issues、公式ドキュメントを確認\n"
            "   - 別の解決アプローチを3つ以上見つける\n\n"
            "3️⃣ **ドキュメント確認**\n"
            "   - 使用しているライブラリ/フレームワークの公式ドキュメントを再確認\n"
            "   - APIの仕様や制限事項を確認\n"
            "   - バージョン互換性の問題がないか確認\n\n"
            "4️⃣ **不明点の明確化**\n"
            "   - 理解できていない部分を質問形式でリストアップ\n"
            "   - BOSSまたは他のWorkerに質問する内容を準備\n"
            "   - 問題の本質が何か、改めて定義し直す\n\n"
            "📝 上記を完了したら、調査結果をBOSSに報告してください。\n"
            "❌ 調査が完了するまで、コードの修正は行わないでください。"
        )
        
        # agent-send.sh を使用してメッセージを送信
        os.system(f'./scripts/agent-send.sh {agent} "{stop_message}"')
    
    def get_status(self) -> Dict:
        """現在のエラー監視状況を取得"""
        current_time = time.time()
        status = {
            "active_monitors": {},
            "total_errors": 0
        }
        
        for key, timestamps in self.error_history.items():
            # アクティブなエラーのみカウント
            active_errors = [
                ts for ts in timestamps 
                if current_time - ts <= self.time_window
            ]
            
            if active_errors:
                agent, error_hash = key.split(':', 1)
                if agent not in status["active_monitors"]:
                    status["active_monitors"][agent] = {}
                
                status["active_monitors"][agent][error_hash] = {
                    "count": len(active_errors),
                    "first_seen": datetime.datetime.fromtimestamp(min(active_errors)).isoformat(),
                    "last_seen": datetime.datetime.fromtimestamp(max(active_errors)).isoformat(),
                    "threshold_reached": len(active_errors) >= self.threshold
                }
                
                status["total_errors"] += len(active_errors)
        
        return status


def main():
    """CLI インターフェース"""
    import argparse
    
    parser = argparse.ArgumentParser(description='CCTeam Error Loop Detector')
    parser.add_argument('command', choices=['check', 'status', 'clear'],
                        help='Command to execute')
    parser.add_argument('--agent', help='Agent name')
    parser.add_argument('--error', help='Error message')
    parser.add_argument('--threshold', type=int, default=3,
                        help='Error threshold (default: 3)')
    
    args = parser.parse_args()
    
    detector = ErrorLoopDetector(threshold=args.threshold)
    
    if args.command == 'check':
        if not args.agent or not args.error:
            print("Error: --agent and --error are required for check command")
            sys.exit(1)
        
        is_loop = detector.check_error(args.agent, args.error)
        if is_loop:
            print(f"⚠️ ERROR LOOP DETECTED for {args.agent}")
            sys.exit(1)
        else:
            print(f"✅ No error loop detected (yet)")
    
    elif args.command == 'status':
        status = detector.get_status()
        print("\n🔍 Error Loop Detection Status")
        print("=" * 50)
        
        if not status["active_monitors"]:
            print("No active error monitoring")
        else:
            print(f"Total active errors: {status['total_errors']}")
            print("\nActive monitors:")
            
            for agent, errors in status["active_monitors"].items():
                print(f"\n{agent}:")
                for error_hash, info in errors.items():
                    status_icon = "🚨" if info["threshold_reached"] else "⚠️"
                    print(f"  {status_icon} Error {error_hash[:8]}...")
                    print(f"     Count: {info['count']}/{args.threshold}")
                    print(f"     First: {info['first_seen']}")
                    print(f"     Last: {info['last_seen']}")
    
    elif args.command == 'clear':
        detector.error_history = {}
        detector.save_history()
        print("✅ Error history cleared")


if __name__ == "__main__":
    main()