#!/bin/bash
# Claude Code SDK Integration for CCTeam
# MAXプランアカウント認証で自動化を実現

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🤖 Claude Code SDK Integration${NC}"
echo "================================"

# Python環境確認
check_python_env() {
    echo -e "${YELLOW}Checking Python environment...${NC}"
    
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Python 3 not found. Please install Python 3.10+${NC}"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}✓ Python $PYTHON_VERSION found${NC}"
}

# Claude Code SDK セットアップ
setup_claude_sdk() {
    echo -e "\n${YELLOW}Setting up Claude Code SDK...${NC}"
    
    # SDKインストール
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    pip install -q --upgrade pip
    pip install -q claude-code-sdk
    
    echo -e "${GREEN}✓ Claude Code SDK installed${NC}"
}

# SDK使用例スクリプト作成
create_sdk_examples() {
    echo -e "\n${YELLOW}Creating SDK usage examples...${NC}"
    
    # 基本的なSDKラッパー
    cat > scripts/claude_sdk_wrapper.py << 'EOF'
#!/usr/bin/env python3
"""
Claude Code SDK Wrapper for CCTeam
MAXプランアカウント認証を使用した自動化ツール
"""

import asyncio
import os
import sys
from claude_code import query, ClaudeCodeOptions

class ClaudeSDKWrapper:
    def __init__(self):
        # MAXプランではアカウント認証を使用
        self.options = ClaudeCodeOptions(
            max_turns=10,
            model="opus",  # 常にOpus 4を使用
            temperature=0.7
        )
    
    async def analyze_code(self, file_path: str):
        """コードの分析とレビュー"""
        with open(file_path, 'r') as f:
            code = f.read()
        
        prompt = f"""
        以下のコードを分析してください：
        1. 潜在的なバグやセキュリティ問題
        2. パフォーマンスの改善点
        3. コードの可読性向上案
        
        ファイル: {file_path}
        ```
        {code}
        ```
        """
        
        async for message in query(prompt, self.options):
            print(message)
    
    async def generate_tests(self, file_path: str):
        """テストコードの自動生成"""
        with open(file_path, 'r') as f:
            code = f.read()
        
        prompt = f"""
        以下のコードに対するテストを生成してください：
        - ユニットテスト
        - エッジケース
        - モックが必要な部分
        
        {code}
        """
        
        test_code = ""
        async for message in query(prompt, self.options):
            test_code += message
        
        # テストファイルに保存
        test_file = file_path.replace('.py', '_test.py').replace('.js', '.test.js')
        with open(test_file, 'w') as f:
            f.write(test_code)
        
        print(f"✓ Tests generated: {test_file}")
    
    async def refactor_code(self, file_path: str, instruction: str):
        """コードのリファクタリング"""
        with open(file_path, 'r') as f:
            original_code = f.read()
        
        prompt = f"""
        以下のコードをリファクタリングしてください：
        
        指示: {instruction}
        
        元のコード:
        ```
        {original_code}
        ```
        """
        
        refactored_code = ""
        async for message in query(prompt, self.options):
            refactored_code += message
        
        # バックアップ作成
        backup_file = f"{file_path}.backup"
        with open(backup_file, 'w') as f:
            f.write(original_code)
        
        # リファクタリング結果を保存
        with open(file_path, 'w') as f:
            f.write(refactored_code)
        
        print(f"✓ Refactored: {file_path}")
        print(f"  Backup: {backup_file}")

async def main():
    wrapper = ClaudeSDKWrapper()
    
    if len(sys.argv) < 2:
        print("Usage: python claude_sdk_wrapper.py <command> [args]")
        print("Commands:")
        print("  analyze <file>     - Analyze code quality")
        print("  test <file>        - Generate tests")
        print("  refactor <file>    - Refactor code")
        return
    
    command = sys.argv[1]
    
    if command == "analyze" and len(sys.argv) > 2:
        await wrapper.analyze_code(sys.argv[2])
    elif command == "test" and len(sys.argv) > 2:
        await wrapper.generate_tests(sys.argv[2])
    elif command == "refactor" and len(sys.argv) > 3:
        await wrapper.refactor_code(sys.argv[2], ' '.join(sys.argv[3:]))
    else:
        print("Invalid command or missing arguments")

if __name__ == "__main__":
    asyncio.run(main())
EOF

    chmod +x scripts/claude_sdk_wrapper.py
    echo -e "${GREEN}✓ SDK wrapper created${NC}"
}

# バッチ処理スクリプト
create_batch_processor() {
    cat > scripts/batch_processor.py << 'EOF'
#!/usr/bin/env python3
"""
バッチ処理でプロジェクト全体を分析
"""

import asyncio
import glob
from pathlib import Path
from claude_code import query, ClaudeCodeOptions

async def batch_analyze_project():
    """プロジェクト全体の品質分析"""
    
    options = ClaudeCodeOptions(
        max_turns=1,
        model="opus"
    )
    
    # 分析対象ファイルを収集
    files = []
    for pattern in ['**/*.js', '**/*.ts', '**/*.py', '**/*.jsx', '**/*.tsx']:
        files.extend(glob.glob(pattern, recursive=True))
    
    # node_modulesなどを除外
    files = [f for f in files if 'node_modules' not in f and 'venv' not in f]
    
    results = []
    
    for file_path in files[:10]:  # 最初の10ファイルのみ（デモ用）
        print(f"Analyzing: {file_path}")
        
        with open(file_path, 'r') as f:
            code = f.read()[:1000]  # 最初の1000文字のみ
        
        prompt = f"このコードの品質を1-10で評価: {code[:200]}..."
        
        async for message in query(prompt, options):
            results.append({
                'file': file_path,
                'score': message
            })
    
    # レポート生成
    with open('reports/code-quality-report.md', 'w') as f:
        f.write("# Code Quality Report\n\n")
        for result in results:
            f.write(f"- {result['file']}: {result['score']}\n")
    
    print("✓ Batch analysis complete: reports/code-quality-report.md")

if __name__ == "__main__":
    asyncio.run(batch_analyze_project())
EOF

    chmod +x scripts/batch_processor.py
}

# CI/CD統合スクリプト
create_cicd_integration() {
    cat > scripts/claude_cicd.py << 'EOF'
#!/usr/bin/env python3
"""
CI/CDパイプラインでのClaude Code SDK活用
"""

import asyncio
import subprocess
import json
from claude_code import query, ClaudeCodeOptions

async def pre_commit_check():
    """コミット前の自動チェック"""
    
    # 変更されたファイルを取得
    result = subprocess.run(
        ['git', 'diff', '--cached', '--name-only'],
        capture_output=True,
        text=True
    )
    
    changed_files = result.stdout.strip().split('\n')
    issues = []
    
    options = ClaudeCodeOptions(max_turns=1, model="opus")
    
    for file in changed_files:
        if file.endswith(('.js', '.ts', '.py')):
            with open(file, 'r') as f:
                code = f.read()
            
            prompt = f"このコードに重大な問題がないか確認: {code[:500]}..."
            
            async for message in query(prompt, options):
                if "問題" in message or "エラー" in message:
                    issues.append(f"{file}: {message}")
    
    if issues:
        print("⚠️  Issues found:")
        for issue in issues:
            print(f"  - {issue}")
        return False
    
    print("✅ Pre-commit check passed")
    return True

async def generate_pr_description():
    """PR説明文の自動生成"""
    
    # 変更内容を取得
    result = subprocess.run(
        ['git', 'diff', 'main...HEAD'],
        capture_output=True,
        text=True
    )
    
    diff = result.stdout[:2000]  # 最初の2000文字
    
    prompt = f"""
    以下の変更に基づいてPR説明文を生成してください：
    - 変更の概要
    - 影響範囲
    - テスト方法
    
    {diff}
    """
    
    options = ClaudeCodeOptions(max_turns=1, model="opus")
    
    pr_description = ""
    async for message in query(prompt, options):
        pr_description += message
    
    with open('.github/pr_template.md', 'w') as f:
        f.write(pr_description)
    
    print("✓ PR description generated")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "pr":
        asyncio.run(generate_pr_description())
    else:
        asyncio.run(pre_commit_check())
EOF

    chmod +x scripts/claude_cicd.py
}

# Git hooks統合
setup_git_hooks() {
    echo -e "\n${YELLOW}Setting up Git hooks...${NC}"
    
    # pre-commitフックにSDKチェック追加
    cat >> .githooks/pre-commit << 'EOF'

# Claude Code SDK品質チェック
if command -v python3 &> /dev/null && [ -f scripts/claude_cicd.py ]; then
    echo "Running Claude Code SDK pre-commit check..."
    python3 scripts/claude_cicd.py
fi
EOF
    
    echo -e "${GREEN}✓ Git hooks updated${NC}"
}

# エイリアス設定
create_aliases() {
    cat >> "$HOME/.ccteam-ai-aliases" << 'EOF'

# Claude Code SDK commands
alias claude-analyze='python3 scripts/claude_sdk_wrapper.py analyze'
alias claude-test='python3 scripts/claude_sdk_wrapper.py test'
alias claude-refactor='python3 scripts/claude_sdk_wrapper.py refactor'
alias claude-batch='python3 scripts/batch_processor.py'
EOF
    
    echo -e "${GREEN}✓ SDK aliases added${NC}"
}

# メイン処理
main() {
    check_python_env
    setup_claude_sdk
    create_sdk_examples
    create_batch_processor
    create_cicd_integration
    setup_git_hooks
    create_aliases
    
    echo -e "\n${BLUE}📋 Claude Code SDK Integration Complete!${NC}"
    echo ""
    echo "Usage examples:"
    echo "  claude-analyze file.js    # Analyze code quality"
    echo "  claude-test file.py       # Generate tests"
    echo "  claude-refactor file.ts   # Refactor code"
    echo "  claude-batch              # Batch analyze project"
    echo ""
    echo "Pre-commit hook will automatically check code quality"
    echo ""
    echo -e "${GREEN}✅ Ready to use with MAX plan account authentication${NC}"
}

# 実行
main