Clean up CCTeam logs and memory with options:

Usage: ${ARGUMENTS}

Options:
- logs [days]: Clean logs older than N days (default: 7)
- memory-reset: Reset SQLite memory database
- memory-compact: Vacuum and optimize database
- memory-archive: Archive old memories before cleanup
- all: Clean everything with confirmation

Examples:
- /ccteam-clean logs 30 (remove logs older than 30 days)
- /ccteam-clean memory-compact (optimize DB)
- /ccteam-clean all (full cleanup)

Safety features:
1. Always create backup before deletion
2. Show size before/after
3. Require confirmation for destructive actions