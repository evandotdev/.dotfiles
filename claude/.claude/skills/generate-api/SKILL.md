---
description: Generate a new API endpoint following project conventions
allowed-tools: Read, Write, Glob, Grep
model: sonnet
argument-hint: [endpoint-description]
---

Generate a new API endpoint for: $ARGUMENTS

## Conventions

1. **AI/LLM Operations**: Prefix with `generate`
   - Example: `POST /api/v1/generate/transcript`
   - Example: `POST /api/v1/generate/summary`

2. **RESTful Methods**:
   - `POST` - Create resources
   - `GET` - Read resources
   - `PUT` - Full update
   - `PATCH` - Partial update
   - `DELETE` - Remove resources

3. **Naming**:
   - Use plural nouns for collections: `/users`, `/transcripts`
   - Use IDs for specific resources: `/users/{user_id}`
   - Nest related resources: `/users/{user_id}/transcripts`

4. **Data Models**:
   - Request DTOs: suffix with `Request` (e.g., `CreateTranscriptRequest`)
   - Response DTOs: suffix with `Response` (e.g., `TranscriptResponse`)

## Output

Generate:
1. Route handler with proper HTTP method
2. Request/Response models
3. Service method signature
4. Example curl command for testing
