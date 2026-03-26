# Testing Patterns

> Test structure, fixtures, and best practices

## Test Framework

**Framework**: [Jest, pytest, cargo test, etc.]

**Run command**: `[npm test, pytest, cargo test, etc.]`

## Test Structure

### File Naming

- Unit tests: `[*.test.ts, test_*.py, *_test.rs, etc.]`
- Integration tests: `[*.integration.test.ts, etc.]`
- E2E tests: `[*.e2e.spec.ts, etc.]`

### Directory Structure

```
tests/
├── unit/
├── integration/
└── e2e/
```

## Test Patterns

### Unit Tests

**Purpose**: Test individual functions/classes in isolation

**Example structure**:
```[language]
describe('ComponentName', () => {
  it('should do X when Y', () => {
    // Arrange
    // Act
    // Assert
  })
})
```

### Integration Tests

**Purpose**: Test multiple components working together

### E2E Tests

**Purpose**: Test complete user workflows

## Fixtures and Setup

**Setup**: `beforeEach()`, `setUp()`, `#[fixture]`

**Teardown**: `afterEach()`, `tearDown()`

## Mocking

**Mock functions**: [jest.fn(), unittest.mock, etc.]

**Mock modules**: [How modules are mocked]

## Coverage

**Target**: [e.g., 80% line coverage]

**Command**: `[npm test -- --coverage, pytest --cov, etc.]`

## Best Practices

- [Practice 1]
- [Practice 2]
- [Practice 3]

## References

- [Testing guide URL]
- [Framework docs]
