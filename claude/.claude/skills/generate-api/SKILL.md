---
description: Generate a new API endpoint following project conventions
allowed-tools: Read, Write, Glob, Grep
model: sonnet
argument-hint: [endpoint-description]
---

Generate a new API endpoint for: $ARGUMENTS

## URL Conventions

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

## Data Model Conventions

### Naming
- Request DTOs: suffix with `Request` (e.g., `CreateTranscriptRequest`)
- Response DTOs: suffix with `Response` (e.g., `TranscriptResponse`)

### ApiResponse<T>

All API responses use this wrapper:

```typescript
interface ApiResponse<T = null> {
  success: boolean;
  data: T | null;
  error: {
    message: string;
    code?: string;
  } | null;
}
```

**Rules:**
- All three fields (success, data, error) are always required
- When `success: true` → data has value, error is null
- When `success: false` → data is null, error has value

### PaginatedResponse<T>

For paginated endpoints:

```typescript
interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    pageNo: number;       // current page (1-indexed)
    limit: number;        // items per page
    total: number;        // total item count
    totalPages: number;   // Math.ceil(total / limit)
    hasNextPage: boolean; // pageNo < totalPages
  };
}
```

### Pagination Query Parameters

```typescript
interface PaginationQuery {
  pageNo?: number;   // defaults to 1
  limit?: number;    // defaults to 20, max 100
}
```

| Param  | Default | Min | Max |
|--------|---------|-----|-----|
| pageNo | 1       | 1   | —   |
| limit  | 20      | 1   | 100 |

### Combined Response Shape

Paginated endpoints return `ApiResponse<PaginatedResponse<T>>`:

**Success:**
```json
{
  "success": true,
  "data": {
    "data": [...items],
    "pagination": {
      "pageNo": 2,
      "limit": 10,
      "total": 25,
      "totalPages": 3,
      "hasNextPage": true
    }
  },
  "error": null
}
```

**Error:**
```json
{
  "success": false,
  "data": null,
  "error": {
    "message": "Invalid page number",
    "code": "INVALID_PAGINATION"
  }
}
```

## Output

Generate:
1. Route handler with proper HTTP method
2. Request/Response models following conventions above
3. Service method signature
4. Example curl command for testing
