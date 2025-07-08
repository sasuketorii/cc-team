module.exports = {
  displayName: 'frontend',
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/src/frontend'],
  testMatch: [
    '**/__tests__/**/*.+(ts|tsx|js|jsx)',
    '**/?(*.)+(spec|test).+(ts|tsx|js|jsx)'
  ],
  transform: {
    '^.+\\.(ts|tsx)$': ['ts-jest', {
      tsconfig: {
        jsx: 'react'
      }
    }],
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
    '\\.(jpg|jpeg|png|gif|svg)$': '<rootDir>/tests/mocks/fileMock.js',
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.frontend.ts'],
  collectCoverageFrom: [
    'src/frontend/**/*.{js,jsx,ts,tsx}',
    '!src/frontend/**/*.d.ts',
    '!src/frontend/**/*.stories.{js,jsx,ts,tsx}',
    '!src/frontend/**/__tests__/**',
    '!src/frontend/index.tsx',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  testTimeout: 10000,
  globals: {
    'ts-jest': {
      isolatedModules: true
    }
  }
};