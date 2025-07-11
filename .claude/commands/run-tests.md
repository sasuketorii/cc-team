Execute test suite with detailed reporting:
1. Run unit tests with coverage report
2. Execute integration tests
3. Perform system health checks
4. Generate test summary
5. Archive results to .claude/shared/metrics/
6. Report any failing tests with details

Test scope: ${ARGUMENTS}

Available test commands:
- npm test (all tests)
- ./tests/quick_health_check.sh
- ./tests/system_health_check.sh
- ./tests/integration_test.sh