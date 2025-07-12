#!/bin/bash

# CCTeam Main Launch Script
# 統一された起動スクリプト - v4アーキテクチャを使用

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# メインのv4スクリプトに委譲
exec "$SCRIPT_DIR/launch-ccteam-v4.sh" "$@"