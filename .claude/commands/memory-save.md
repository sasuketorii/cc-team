Save current conversation or insight to CCTeam memory database:

Usage: /memory-save ${ARGUMENTS}

What to save:
- Current conversation context
- Important decisions made
- Learned patterns
- Project insights

The command will:
1. Extract key information from current context
2. Save to SQLite database (memory/ccteam_memory.db)
3. Tag with timestamp and agent info
4. Make searchable for future sessions

Example:
- /memory-save "Completed color integration using common-utils.sh"
- /memory-save "User prefers Opus for architecture, Sonnet for implementation"