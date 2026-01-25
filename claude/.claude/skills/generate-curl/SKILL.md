---
description: Generate curl commands formatted for Bruno import
allowed-tools: Read
model: haiku
argument-hint: [api-endpoint-or-file]
---

Generate a curl request for: $ARGUMENTS

Format for Bruno collection import with these rules:

1. **Path parameters**: Use `:param` format (not `{param}`)
   - `{item_id}` becomes `:item_id`
   - `{user_id}` becomes `:user_id`

2. **Include headers**:
   - `Content-Type: application/json` for POST/PUT/PATCH
   - `Authorization: Bearer :token` if auth required

3. **Format**:
```curl
curl --location --request METHOD 'http://localhost:PORT/path/:param' \
  --header 'Content-Type: application/json' \
  --data '{
  "field": "value"
}'
```

## Example

Input endpoint: `PATCH /api/v1/menu/{item_id}/sold-out`

Output:
```curl
curl --location --request PATCH 'http://localhost:3000/api/v1/menu/:item_id/sold-out' \
  --header 'Content-Type: application/json' \
  --data '{
  "isSoldOut": true
}'
```
