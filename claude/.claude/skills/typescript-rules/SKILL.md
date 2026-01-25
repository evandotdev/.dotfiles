---
description: TypeScript backend conventions and best practices. Use when writing TypeScript APIs, services, or controllers.
allowed-tools: Read
model: haiku
---

# TypeScript Backend Standards

## 1. Strong Typing

- Define explicit types for all functions, parameters, return values
- Use utility types: `Partial`, `Omit`, `Pick`, `Readonly`
- Never use `any` - it defeats TypeScript's purpose
- Enable `strict: true` in tsconfig.json

```typescript
// Good
function getUser(id: string): Promise<User | null> { }

// Bad
function getUser(id): Promise<any> { }
```

## 2. Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Request DTO | `*Request` | `CreateUserRequest` |
| Response DTO | `*Response` | `UserResponse` |
| API Client | `*ApiService` | `StripeApiService` |
| Service | `*Service` | `UserService` |
| Controller | `*Controller` | `UserController` |

## 3. Layer Organization

**Option A: Technical Layers** (small/mid projects)
```
src/
├── controllers/
├── services/
└── models/
```

**Option B: Business Modules** (large codebases)
```
src/
├── users/
│   ├── users.controller.ts
│   ├── users.service.ts
│   └── users.model.ts
├── orders/
│   └── ...
```

## 4. Runtime Validation

TypeScript only validates at compile-time. API requests can send wrong types.

**Use validation libraries:**
- typia (recommended - generates runtime validators from types)
- Zod
- Joi
- Class Validator
- Typebox

```typescript
import typia from "typia";

interface CreateUserRequest {
  email: string;
  name: string;
}

// Validates at runtime
const validated = typia.assert<CreateUserRequest>(req.body);
```

## 5. Exception Handling

**Do:**
- Create custom exception classes per error type
- Use centralized exception handling middleware
- Let errors propagate naturally

**Don't:**
- Wrap everything in try-catch with re-throws
- Use generic `Error` for everything
- Catch and ignore errors

```typescript
// Good - custom exceptions
class UserNotFoundError extends Error {
  constructor(id: string) {
    super(`User ${id} not found`);
  }
}

// Bad - generic errors
throw new Error("Something went wrong");
```
