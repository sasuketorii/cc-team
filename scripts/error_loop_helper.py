#!/usr/bin/env python3
"""
エラーループ検出時に役立つドキュメントやリソースを自動提供するヘルパー
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Optional

class ErrorLoopHelper:
    """エラーループ時の支援情報を提供"""
    
    def __init__(self):
        self.error_patterns = {
            # JavaScript/TypeScript エラー
            r"Cannot find module": {
                "type": "module_not_found",
                "docs": [
                    "https://nodejs.org/api/modules.html",
                    "https://www.npmjs.com/package/{module_name}"
                ],
                "tips": [
                    "npm install {module_name} を実行してください",
                    "package.jsonに依存関係が正しく記載されているか確認",
                    "node_modulesディレクトリを削除してnpm installを再実行"
                ]
            },
            r"SyntaxError.*Unexpected token": {
                "type": "syntax_error",
                "docs": [
                    "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Errors/Unexpected_token"
                ],
                "tips": [
                    "括弧、ブラケット、クォートの対応を確認",
                    "セミコロンの有無を確認",
                    "ESLintなどのリンターを使用して構文チェック"
                ]
            },
            
            # Python エラー
            r"ModuleNotFoundError": {
                "type": "python_module_error",
                "docs": [
                    "https://docs.python.org/3/tutorial/modules.html",
                    "https://pypi.org/project/{module_name}/"
                ],
                "tips": [
                    "pip install {module_name} を実行",
                    "仮想環境が有効化されているか確認",
                    "PYTHONPATHが正しく設定されているか確認"
                ]
            },
            r"IndentationError": {
                "type": "python_indent",
                "docs": [
                    "https://docs.python.org/3/reference/lexical_analysis.html#indentation"
                ],
                "tips": [
                    "タブとスペースを混在させない",
                    "通常は4スペースでインデント",
                    "エディタの表示設定で空白文字を可視化"
                ]
            },
            
            # Git エラー
            r"fatal:.*not a git repository": {
                "type": "git_not_initialized",
                "docs": [
                    "https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository"
                ],
                "tips": [
                    "git init でリポジトリを初期化",
                    "正しいディレクトリにいるか確認",
                    ".gitディレクトリが存在するか確認"
                ]
            },
            r"CONFLICT.*Merge conflict": {
                "type": "merge_conflict",
                "docs": [
                    "https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts"
                ],
                "tips": [
                    "競合マーカー（<<<<<<<, =======, >>>>>>>）を探す",
                    "各変更を理解してから解決",
                    "git status で競合ファイルを確認"
                ]
            },
            
            # Docker エラー
            r"Cannot connect to the Docker daemon": {
                "type": "docker_daemon",
                "docs": [
                    "https://docs.docker.com/config/daemon/"
                ],
                "tips": [
                    "Docker Desktopが起動しているか確認",
                    "sudo権限が必要な場合がある",
                    "docker ps でデーモンの状態を確認"
                ]
            },
            
            # 一般的なエラー
            r"Permission denied": {
                "type": "permission_error",
                "docs": [
                    "https://www.linux.com/training-tutorials/understanding-linux-file-permissions/"
                ],
                "tips": [
                    "ファイルの権限を確認: ls -la",
                    "必要に応じて chmod で権限を変更",
                    "sudo が必要な操作か確認"
                ]
            },
            r"ENOSPC.*no space left": {
                "type": "disk_space",
                "docs": [
                    "https://unix.stackexchange.com/questions/125429/tracking-down-where-disk-space-has-gone"
                ],
                "tips": [
                    "df -h でディスク使用状況を確認",
                    "不要なファイルを削除",
                    "ログファイルのサイズを確認"
                ]
            }
        }
    
    def analyze_error(self, error_message: str) -> Optional[Dict]:
        """エラーメッセージを分析して関連情報を返す"""
        for pattern, info in self.error_patterns.items():
            if re.search(pattern, error_message, re.IGNORECASE):
                # モジュール名などの動的な値を抽出
                match = re.search(pattern, error_message, re.IGNORECASE)
                context = self._extract_context(error_message, info['type'])
                
                # ドキュメントURLとTipsに動的な値を挿入
                docs = [doc.format(**context) for doc in info['docs']]
                tips = [tip.format(**context) for tip in info['tips']]
                
                return {
                    "error_type": info['type'],
                    "documentation": docs,
                    "tips": tips,
                    "context": context
                }
        
        return None
    
    def _extract_context(self, error_message: str, error_type: str) -> Dict[str, str]:
        """エラーメッセージから文脈情報を抽出"""
        context = {}
        
        # モジュール名の抽出
        if error_type in ["module_not_found", "python_module_error"]:
            module_match = re.search(r"['\"]([^'\"]+)['\"]", error_message)
            if module_match:
                context["module_name"] = module_match.group(1)
        
        # ファイル名の抽出
        file_match = re.search(r"(?:in|at|file) ['\"]?([^\s'\"]+\.[a-z]+)", error_message, re.IGNORECASE)
        if file_match:
            context["file_name"] = file_match.group(1)
        
        # 行番号の抽出
        line_match = re.search(r"line (\d+)", error_message, re.IGNORECASE)
        if line_match:
            context["line_number"] = line_match.group(1)
        
        return context
    
    def generate_help_message(self, error_message: str) -> str:
        """エラーに対する包括的なヘルプメッセージを生成"""
        analysis = self.analyze_error(error_message)
        
        if not analysis:
            return self._generate_generic_help()
        
        help_message = f"""
📚 **エラータイプ**: {analysis['error_type']}

📖 **参考ドキュメント**:
{chr(10).join(f"- {doc}" for doc in analysis['documentation'])}

💡 **解決のヒント**:
{chr(10).join(f"{i+1}. {tip}" for i, tip in enumerate(analysis['tips']))}

🔍 **追加の調査方法**:
1. エラーメッセージ全文でGoogle検索
2. Stack Overflowで類似の問題を検索
3. 公式ドキュメントで該当する章を確認
4. GitHub Issuesで同じエラーを検索

⚠️ **重要**: 上記の情報を確認してから修正を試みてください。
"""
        
        if analysis.get('context'):
            help_message += f"\n📌 **検出された情報**: {json.dumps(analysis['context'], indent=2)}"
        
        return help_message
    
    def _generate_generic_help(self) -> str:
        """一般的なヘルプメッセージを生成"""
        return """
📚 **一般的なデバッグ手順**:

1. **エラーメッセージを完全に読む**
   - エラーの種類を特定
   - ファイル名と行番号を確認
   - スタックトレースを追跡

2. **基本的な確認事項**
   - 構文エラーがないか確認
   - 必要な依存関係がインストールされているか
   - 環境変数が正しく設定されているか
   - ファイルの権限が適切か

3. **情報収集**
   - エラーメッセージでWeb検索
   - 公式ドキュメントを確認
   - Stack Overflowで類似事例を探す
   - GitHub Issuesを確認

4. **段階的なアプローチ**
   - 最小限の再現コードを作成
   - 一つずつ要素を追加して問題を特定
   - ログやデバッグ出力を活用

🔗 **汎用リソース**:
- https://stackoverflow.com
- https://github.com
- https://devdocs.io
"""


def main():
    """CLI インターフェース"""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python error_loop_helper.py <error_message>")
        sys.exit(1)
    
    error_message = " ".join(sys.argv[1:])
    helper = ErrorLoopHelper()
    
    help_message = helper.generate_help_message(error_message)
    print(help_message)


if __name__ == "__main__":
    main()