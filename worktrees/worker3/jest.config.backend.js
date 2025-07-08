module.exports = {
  displayName: 'backend',
  testEnvironment: 'node',
  roots: ['<rootDir>/src/backend'],
  testMatch: [
    '**/__tests__/**/*.+(ts|js)',
    '**/?(*.)+(spec|test).+(ts|js)'
  ],
  transform: {
    '^.+\\.(ts)$': 'ts-jest',
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.backend.ts'],
  collectCoverageFrom: [
    'src/backend/**/*.{js,ts}',
    '!src/backend/**/*.d.ts',
    '!src/backend/**/__tests__/**',
    '!src/backend/index.ts',
    '!src/backend/server.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  testTimeout: 30000,
  maxWorkers: '50%',
};