#!/bin/bash
# CCTeam 起動スクリプト - v4へのリダイレクト

# v4を使用
exec "$(dirname "${BASH_SOURCE[0]}")/launch-ccteam-v4.sh" "$@"