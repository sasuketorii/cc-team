// CCTeam Jest設定
module.exports = {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'scripts/**/*.js',
    '!scripts/**/test-*.js',
    '!scripts/**/*.test.js'
  ],
  testMatch: [
    '**/tests/**/*.test.js',
    '**/tests/**/*.spec.js'
  ],
  coverageReporters: ['text', 'html', 'json'],
  coverageThreshold: {
    global: {
      branches: 50,
      functions: 50,
      lines: 50,
      statements: 50
    }
  },
  testPathIgnorePatterns: [
    '/node_modules/',
    '/logs/',
    '/worktrees/',
    '/coverage/'
  ],
  moduleFileExtensions: ['js', 'json'],
  verbose: true
};