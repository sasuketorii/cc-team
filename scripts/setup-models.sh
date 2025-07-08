#!/bin/bash
# AI モデル自動設定スクリプト - Claude Opus と Gemini 2.0 Flash を自動選択

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🤖 CCTeam AI Model Configuration${NC}"
echo "=================================="

# Claude設定ファイルのパス
CLAUDE_CONFIG="$HOME/.claude.json"
CLAUDE_LOCAL_CONFIG="$HOME/CC-Team/CCTeam/.claude/settings.local.json"

# Gemini設定ファイルのパス
GEMINI_CONFIG="$HOME/.gemini/config.json"

# 関数: Claudeの設定
configure_claude() {
    echo -e "\n${YELLOW}📝 Configuring Claude Code...${NC}"
    
    # .claude/settings.local.json を作成
    mkdir -p "$(dirname "$CLAUDE_LOCAL_CONFIG")"
    
    cat > "$CLAUDE_LOCAL_CONFIG" << 'EOF'
{
  "defaultModel": "claude-opus-4-20250514",
  "models": {
    "preferred": [
      "claude-opus-4-20250514"
    ],
    "blocked": [
      "claude-3-haiku-20240307"
    ]
  },
  "features": {
    "alwaysUseOpus": true,
  "authentication": "account",
  "plan": "MAX",
    "autoSelectBestModel": false
  },
  "experimental": {
    "forceOpusForComplexTasks": true
  }
}
EOF
    
    # グローバル設定も更新（既存の設定を保持しながら）
    if [ -f "$CLAUDE_CONFIG" ]; then
        # 既存設定をバックアップ
        cp "$CLAUDE_CONFIG" "$CLAUDE_CONFIG.backup"
        
        # jqを使って設定を更新
        if command -v jq &> /dev/null; then
            jq '.defaultModel = "claude-opus-4-20250514" | 
                .preferredModels = ["claude-opus-4-20250514"] |
                .modelSelection = "manual" |
                .alwaysUseHighestModel = true' "$CLAUDE_CONFIG.backup" > "$CLAUDE_CONFIG"
        else
            # jqがない場合は直接書き込み
            cat > "$CLAUDE_CONFIG" << 'EOF'
{
  "defaultModel": "claude-opus-4-20250514",
  "preferredModels": ["claude-opus-4-20250514"],
  "modelSelection": "manual",
  "alwaysUseHighestModel": true,
  "authentication": "account-based",
  "plan": "MAX"
}
EOF
        fi
    fi
    
    echo -e "${GREEN}✓ Claude configured to use Opus model${NC}"
}

# 関数: Geminiの設定
configure_gemini() {
    echo -e "\n${YELLOW}📝 Configuring Gemini CLI...${NC}"
    
    # Gemini設定ディレクトリ作成
    mkdir -p "$(dirname "$GEMINI_CONFIG")"
    
    # Gemini CLI設定ファイル作成
    cat > "$GEMINI_CONFIG" << 'EOF'
{
  "model": "gemini-2.0-flash-exp",
  "temperature": 0.7,
  "maxTokens": 8192,
  "topP": 0.95,
  "topK": 40,
  "settings": {
    "defaultModel": "gemini-2.0-flash-exp",
    "fallbackModel": "gemini-1.5-pro",
    "autoRetry": true,
    "retryCount": 3
  }
}
EOF
    
    # 環境変数設定スクリプト
    cat > "$HOME/.gemini-env" << 'EOF'
# Gemini CLI Environment Variables
export GEMINI_MODEL="gemini-2.0-flash-exp"
export GEMINI_API_KEY="${GEMINI_API_KEY:-}"
export GEMINI_TEMPERATURE="0.7"
export GEMINI_MAX_TOKENS="8192"

# Gemini CLI alias with model preset
alias gemini='gemini --model gemini-2.0-flash-exp'
alias gemini-pro='gemini --model gemini-1.5-pro'
alias gemini-flash='gemini --model gemini-2.0-flash-exp'
EOF
    
    echo -e "${GREEN}✓ Gemini configured to use 2.0 Flash model${NC}"
}

# 関数: エージェント指示書の更新
update_agent_instructions() {
    echo -e "\n${YELLOW}📝 Updating agent instructions...${NC}"
    
    # BOSSエージェントにモデル指定を追加
    cat >> instructions/boss-models.md << 'EOF'

## AI モデル使用ガイドライン

### Claude Code (Opus 4)
- 複雑な問題解決
- アーキテクチャ設計
- コードレビュー
- 戦略的判断

### Gemini CLI (2.0 Flash)
- 高速な情報検索
- ドキュメント生成
- 簡単なコード生成
- API仕様調査

### 使い分け例
```bash
# 複雑な問題はClaude Opus 4
claude-code "この複雑なバグの原因を分析して修正方法を提案して"

# 素早い調査はGemini
gemini "React 19の新機能をリストアップして"
gemini "このエラーメッセージの一般的な原因は？"
```
EOF
    
    echo -e "${GREEN}✓ Agent instructions updated${NC}"
}

# 関数: 起動スクリプトの更新
update_launch_script() {
    echo -e "\n${YELLOW}📝 Updating launch script...${NC}"
    
    # launch-ccteam.sh にモデル設定を追加
    sed -i.bak '1a\
\
# AI モデル自動設定\
export CLAUDE_MODEL="claude-opus-4-20250514"\
export GEMINI_MODEL="gemini-2.0-flash-exp"\
source ~/.gemini-env 2>/dev/null || true\
' scripts/launch-ccteam.sh
    
    echo -e "${GREEN}✓ Launch script updated${NC}"
}

# 関数: 検証
verify_configuration() {
    echo -e "\n${BLUE}🔍 Verifying configuration...${NC}"
    
    # Claude設定確認
    if [ -f "$CLAUDE_LOCAL_CONFIG" ]; then
        echo -e "${GREEN}✓ Claude local config exists${NC}"
        echo "  Model: $(jq -r '.defaultModel' "$CLAUDE_LOCAL_CONFIG" 2>/dev/null || echo "claude-opus-4-20250514")"
    else
        echo -e "${RED}✗ Claude config not found${NC}"
    fi
    
    # Gemini設定確認
    if [ -f "$GEMINI_CONFIG" ]; then
        echo -e "${GREEN}✓ Gemini config exists${NC}"
        echo "  Model: $(jq -r '.model' "$GEMINI_CONFIG" 2>/dev/null || echo "gemini-2.0-flash-exp")"
    else
        echo -e "${RED}✗ Gemini config not found${NC}"
    fi
    
    # 環境変数確認
    if [ -f "$HOME/.gemini-env" ]; then
        echo -e "${GREEN}✓ Gemini environment configured${NC}"
    fi
}

# 関数: APIキー設定ヘルパー
setup_api_keys() {
    echo -e "\n${YELLOW}🔑 API Key Setup${NC}"
    
    # Claude - MAXプラン使用
    echo -e "${GREEN}✓ Claude: Using MAX plan account authentication${NC}"
    echo "  No API key required - using account login"
    
    # Gemini APIキー
    if [ -z "$GEMINI_API_KEY" ]; then
        echo -e "${YELLOW}Gemini API key not found in environment${NC}"
        echo "Add to your shell config:"
        echo "export GEMINI_API_KEY='your-api-key-here'"
        echo "Get your free API key at: https://makersuite.google.com/app/apikey"
    else
        echo -e "${GREEN}✓ Gemini API key found${NC}"
    fi
}

# メイン処理
main() {
    case "$1" in
        "claude")
            configure_claude
            ;;
        "gemini")
            configure_gemini
            ;;
        "verify")
            verify_configuration
            ;;
        "keys")
            setup_api_keys
            ;;
        *)
            # デフォルト: 全て設定
            configure_claude
            configure_gemini
            update_agent_instructions
            update_launch_script
            verify_configuration
            
            echo -e "\n${BLUE}📋 Next Steps:${NC}"
            echo "1. Claude: Already configured (using MAX plan account)"
            echo ""
            echo "2. Gemini: Set your API key (if not already set):"
            echo "   export GEMINI_API_KEY='your-gemini-key'"
            echo "   Get free API key: https://makersuite.google.com/app/apikey"
            echo ""
            echo "3. Add to your shell config (.bashrc/.zshrc):"
            echo "   source ~/.gemini-env"
            echo ""
            echo "4. Restart your terminal or run:"
            echo "   source ~/.bashrc  # or ~/.zshrc"
            echo ""
            echo -e "${GREEN}✅ Model configuration complete!${NC}"
            echo "Claude will use: Opus 4 (claude-opus-4-20250514)"
            echo "Gemini will use: 2.0 Flash (gemini-2.0-flash-exp)"
            ;;
    esac
}

# 実行
main "$@"