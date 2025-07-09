#!/usr/bin/env python3
"""
CCTeam Memory Manager - SuperClaudeライクな記憶メモリシステム
対話履歴、プロジェクトコンテキスト、学習内容を永続化
"""

import json
import sqlite3
import datetime
import os
import sys
from pathlib import Path
from typing import Dict, List, Any, Optional
import hashlib
import argparse

class CCTeamMemoryManager:
    """
    記憶メモリシステムのコア実装
    SQLiteを使用して対話履歴とコンテキストを管理
    """
    
    def __init__(self, db_path: str = "memory/ccteam_memory.db"):
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(exist_ok=True)
        self._init_database()
    
    def _init_database(self):
        """メモリデータベースの初期化"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 対話履歴テーブル
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS conversations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                agent_name TEXT NOT NULL,
                message_type TEXT NOT NULL,
                content TEXT NOT NULL,
                context_hash TEXT,
                metadata JSON
            )
        """)
        
        # プロジェクトコンテキストテーブル
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS project_contexts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_name TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                context_type TEXT NOT NULL,
                content JSON NOT NULL,
                importance_score REAL DEFAULT 0.5
            )
        """)
        
        # 学習パターンテーブル
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS learned_patterns (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pattern_type TEXT NOT NULL,
                pattern_data JSON NOT NULL,
                success_rate REAL,
                usage_count INTEGER DEFAULT 0,
                last_used DATETIME
            )
        """)
        
        # インデックス作成
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_session ON conversations(session_id)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_timestamp ON conversations(timestamp)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_agent ON conversations(agent_name)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_project ON project_contexts(project_name)")
        
        conn.commit()
        conn.close()
    
    def save_conversation(self, agent: str, message: str, message_type: str = "user", metadata: Optional[Dict] = None):
        """対話履歴の保存"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        session_id = self._get_current_session_id()
        context_hash = hashlib.md5(message.encode()).hexdigest()
        
        cursor.execute("""
            INSERT INTO conversations (session_id, agent_name, message_type, content, context_hash, metadata)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (session_id, agent, message_type, message, context_hash, json.dumps(metadata) if metadata else None))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Saved: [{agent}] {message[:50]}...")
    
    def get_context_window(self, agent: str = None, limit: int = 50) -> List[Dict[str, Any]]:
        """最近のコンテキストを取得"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        query = """
            SELECT agent_name, message_type, content, timestamp, metadata
            FROM conversations
            WHERE 1=1
        """
        params = []
        
        if agent:
            query += " AND agent_name = ?"
            params.append(agent)
        
        query += " ORDER BY timestamp DESC LIMIT ?"
        params.append(limit)
        
        cursor.execute(query, params)
        results = cursor.fetchall()
        
        conn.close()
        
        conversations = []
        for row in results:
            conv = {
                "agent": row[0],
                "type": row[1],
                "content": row[2],
                "timestamp": row[3],
                "metadata": json.loads(row[4]) if row[4] else None
            }
            conversations.append(conv)
        
        return conversations[::-1]  # 時系列順に戻す
    
    def save_project_context(self, project_name: str, context_type: str, content: Dict[str, Any], importance: float = 0.5):
        """プロジェクトコンテキストの保存"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO project_contexts (project_name, context_type, content, importance_score)
            VALUES (?, ?, ?, ?)
        """, (project_name, context_type, json.dumps(content, ensure_ascii=False), importance))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Project context saved: {project_name}/{context_type}")
    
    def learn_pattern(self, pattern_type: str, pattern_data: Dict[str, Any], success: bool):
        """成功/失敗パターンの学習"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # パターンキーの生成
        pattern_key = self._generate_pattern_key(pattern_data)
        pattern_data['key'] = pattern_key
        
        # 既存パターンの確認
        cursor.execute("""
            SELECT id, success_rate, usage_count
            FROM learned_patterns
            WHERE pattern_type = ? AND json_extract(pattern_data, '$.key') = ?
        """, (pattern_type, pattern_key))
        
        existing = cursor.fetchone()
        
        if existing:
            # 既存パターンの更新
            pattern_id, current_rate, usage_count = existing
            new_rate = (current_rate * usage_count + (1.0 if success else 0.0)) / (usage_count + 1)
            
            cursor.execute("""
                UPDATE learned_patterns
                SET success_rate = ?, usage_count = usage_count + 1, last_used = CURRENT_TIMESTAMP
                WHERE id = ?
            """, (new_rate, pattern_id))
        else:
            # 新規パターンの登録
            cursor.execute("""
                INSERT INTO learned_patterns (pattern_type, pattern_data, success_rate, usage_count, last_used)
                VALUES (?, ?, ?, 1, CURRENT_TIMESTAMP)
            """, (pattern_type, json.dumps(pattern_data), 1.0 if success else 0.0))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Pattern learned: {pattern_type} (success={success})")
    
    def get_relevant_memories(self, query: str, limit: int = 10) -> List[Dict[str, Any]]:
        """関連する記憶の検索"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # キーワードベースの簡易検索
        keywords = query.lower().split()
        results = []
        
        for keyword in keywords[:3]:  # 最初の3キーワードのみ
            cursor.execute("""
                SELECT content, timestamp, agent_name, message_type
                FROM conversations
                WHERE LOWER(content) LIKE ?
                ORDER BY timestamp DESC
                LIMIT ?
            """, (f"%{keyword}%", limit))
            
            for row in cursor.fetchall():
                results.append({
                    "content": row[0],
                    "timestamp": row[1],
                    "agent": row[2],
                    "type": row[3],
                    "relevance": "keyword_match"
                })
        
        # プロジェクトコンテキストからも検索
        for keyword in keywords[:2]:
            cursor.execute("""
                SELECT content, timestamp, context_type
                FROM project_contexts
                WHERE LOWER(content) LIKE ?
                ORDER BY importance_score DESC
                LIMIT ?
            """, (f"%{keyword}%", limit // 2))
            
            for row in cursor.fetchall():
                results.append({
                    "content": json.loads(row[0]),
                    "timestamp": row[1],
                    "type": f"project_{row[2]}",
                    "relevance": "context_match"
                })
        
        conn.close()
        
        # 重複を除去
        seen = set()
        unique_results = []
        for result in results:
            content_str = str(result['content'])[:100]
            content_hash = hashlib.md5(content_str.encode()).hexdigest()
            if content_hash not in seen:
                seen.add(content_hash)
                unique_results.append(result)
        
        return unique_results[:limit]
    
    def export_memory_snapshot(self, output_path: str = None):
        """メモリのスナップショットをエクスポート"""
        if not output_path:
            output_path = f"memory_snapshot_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        conn = sqlite3.connect(self.db_path)
        
        snapshot = {
            "timestamp": datetime.datetime.now().isoformat(),
            "statistics": self._get_statistics(),
            "conversations": [],
            "project_contexts": [],
            "learned_patterns": []
        }
        
        # 対話履歴
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM conversations ORDER BY timestamp DESC LIMIT 1000")
        columns = [col[0] for col in cursor.description]
        snapshot["conversations"] = [
            dict(zip(columns, row)) for row in cursor.fetchall()
        ]
        
        # プロジェクトコンテキスト
        cursor.execute("SELECT * FROM project_contexts ORDER BY timestamp DESC")
        columns = [col[0] for col in cursor.description]
        snapshot["project_contexts"] = [
            dict(zip(columns, row)) for row in cursor.fetchall()
        ]
        
        # 学習パターン
        cursor.execute("SELECT * FROM learned_patterns ORDER BY success_rate DESC")
        columns = [col[0] for col in cursor.description]
        snapshot["learned_patterns"] = [
            dict(zip(columns, row)) for row in cursor.fetchall()
        ]
        
        conn.close()
        
        # JSON保存
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(snapshot, f, ensure_ascii=False, indent=2)
        
        print(f"✅ Memory snapshot exported to: {output_path}")
        return output_path
    
    def _get_statistics(self) -> Dict[str, Any]:
        """メモリ統計情報の取得"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        stats = {}
        
        # 対話数
        cursor.execute("SELECT COUNT(*) FROM conversations")
        stats["total_conversations"] = cursor.fetchone()[0]
        
        # エージェント別統計
        cursor.execute("""
            SELECT agent_name, COUNT(*) as count
            FROM conversations
            GROUP BY agent_name
        """)
        stats["agent_stats"] = dict(cursor.fetchall())
        
        # パターン統計
        cursor.execute("SELECT COUNT(*) FROM learned_patterns")
        stats["total_patterns"] = cursor.fetchone()[0]
        
        cursor.execute("SELECT AVG(success_rate) FROM learned_patterns")
        stats["avg_success_rate"] = cursor.fetchone()[0] or 0
        
        conn.close()
        
        return stats
    
    def _get_current_session_id(self) -> str:
        """現在のセッションIDを取得"""
        # tmuxセッションIDまたはタイムスタンプベース
        return datetime.datetime.now().strftime("%Y%m%d_%H%M")
    
    def _generate_pattern_key(self, pattern_data: Dict[str, Any]) -> str:
        """パターンデータからユニークキーを生成"""
        key_elements = []
        for k in sorted(pattern_data.keys()):
            if k in ['command', 'error_type', 'solution_type', 'action']:
                key_elements.append(f"{k}:{pattern_data[k]}")
        
        return hashlib.md5("|".join(key_elements).encode()).hexdigest()[:16]
    
    def display_recent_memories(self, limit: int = 20):
        """最近の記憶を表示"""
        memories = self.get_context_window(limit=limit)
        
        print(f"\n📚 Recent Memories (Last {limit} entries)")
        print("=" * 80)
        
        for mem in memories:
            timestamp = datetime.datetime.fromisoformat(mem['timestamp']).strftime("%m/%d %H:%M")
            agent = mem['agent']
            content = mem['content'][:100] + "..." if len(mem['content']) > 100 else mem['content']
            
            print(f"[{timestamp}] {agent}: {content}")
        
        print("\n📊 Statistics:")
        stats = self._get_statistics()
        print(f"  Total conversations: {stats['total_conversations']}")
        print(f"  Agent breakdown: {stats['agent_stats']}")
        print(f"  Learned patterns: {stats['total_patterns']}")
        print(f"  Success rate: {stats['avg_success_rate']:.1%}")


def main():
    """CLI インターフェース"""
    parser = argparse.ArgumentParser(description='CCTeam Memory Manager')
    parser.add_argument('command', choices=['save', 'load', 'search', 'export', 'stats', 'project'],
                        help='Command to execute')
    parser.add_argument('--agent', default='USER', help='Agent name')
    parser.add_argument('--message', help='Message to save')
    parser.add_argument('--query', help='Search query')
    parser.add_argument('--limit', type=int, default=20, help='Number of results')
    parser.add_argument('--project', default='CCTeam', help='Project name')
    parser.add_argument('--context-type', help='Context type for project')
    
    args = parser.parse_args()
    
    memory = CCTeamMemoryManager()
    
    if args.command == 'save':
        if args.message:
            memory.save_conversation(args.agent, args.message)
        else:
            # インタラクティブモード
            agent = input("Agent name [USER]: ").strip() or "USER"
            message = input("Message: ").strip()
            if message:
                memory.save_conversation(agent, message)
    
    elif args.command == 'load':
        memory.display_recent_memories(limit=args.limit)
    
    elif args.command == 'search':
        if args.query:
            query = args.query
        else:
            query = input("Search query: ").strip()
        
        if query:
            results = memory.get_relevant_memories(query, limit=args.limit)
            print(f"\n🔍 Search results for '{query}':")
            print("=" * 80)
            
            for i, result in enumerate(results, 1):
                print(f"\n{i}. [{result['timestamp']}] {result.get('agent', 'N/A')} ({result['relevance']})")
                if isinstance(result['content'], dict):
                    print(f"   {json.dumps(result['content'], ensure_ascii=False, indent=2)[:200]}...")
                else:
                    print(f"   {result['content'][:200]}...")
    
    elif args.command == 'export':
        output_path = memory.export_memory_snapshot()
        print(f"Memory exported to: {output_path}")
    
    elif args.command == 'stats':
        stats = memory._get_statistics()
        print("\n📊 Memory Statistics")
        print("=" * 50)
        print(f"Total conversations: {stats['total_conversations']}")
        print(f"Learned patterns: {stats['total_patterns']}")
        print(f"Average success rate: {stats['avg_success_rate']:.1%}")
        print("\nAgent Activity:")
        for agent, count in stats['agent_stats'].items():
            print(f"  {agent}: {count} messages")
    
    elif args.command == 'project':
        if args.context_type and args.message:
            content = {"message": args.message, "timestamp": datetime.datetime.now().isoformat()}
            memory.save_project_context(args.project, args.context_type, content)
        else:
            print("Project context requires --context-type and --message")


if __name__ == "__main__":
    main()