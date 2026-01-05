# TypeScript Backend Best Practices

1. Strong Typing Everywhere

- Define explicit types for all functions, parameters, return values, and objects
- Use utility types (Partial, Omit, Pick, Readonly) to avoid duplication
- Never use the "any" type - it defeats TypeScript's purpose
- Enable strict: true in tsconfig.json

2. Clear Layer Organization

Two approaches:

- Technical layers (controllers → services → models): Good for small/mid projects
- Business modules (feature-based folders): Better for large codebases, each module contains its own controllers/services/models

3. Runtime Input Validation

- TypeScript only validates at compile-time, not runtime, we can use `typia`
- API requests can send null, undefined, or wrong types despite TypeScript types
- Use validation libraries: Zod, Joi, Class Validator, or Typebox
- Validate all external inputs to prevent crashes and security issues

4. Centralized Exception Handling

Avoid these mistakes:

- Missing exception handling middleware (causes cluttered controllers)
- Unnecessary try-catch with re-throws (let errors propagate naturally)
- Generic exception classes (create custom exceptions per error type)
