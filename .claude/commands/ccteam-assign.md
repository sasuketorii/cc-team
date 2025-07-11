Intelligently assign tasks based on complexity:
1. Analyze task requirements and complexity
2. Determine if Opus-level architectural decision is needed
3. Assign to appropriate model/role:
   - Opus: Architecture, API design, security review
   - Sonnet: Implementation, testing, documentation
4. Create task file in .claude/shared/queue/pending/
5. Update agent instructions if needed
6. Report assignment decision

Task description: ${ARGUMENTS}