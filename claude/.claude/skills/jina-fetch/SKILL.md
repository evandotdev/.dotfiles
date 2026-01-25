---
name: jina-fetch
description: Fetch content from blocked websites using Jina Reader. Use when WebFetch returns 403, blocked, or access denied errors.
allowed-tools: Bash, WebFetch, WebSearch
---

# Jina Fetch

When WebFetch fails with 403/blocked errors, use Jina Reader to bypass restrictions.

## Usage

Prepend `r.jina.ai/` to any URL:

```bash
curl -s "https://r.jina.ai/https://example.com/blocked-page"
```

## Examples

**Blocked article:**
```bash
curl -s "https://r.jina.ai/https://medium.com/some-article"
```

**Reddit content:**
```bash
curl -s "https://r.jina.ai/https://www.reddit.com/r/programming/comments/abc123/title/"
```

**News site:**
```bash
curl -s "https://r.jina.ai/https://news-site.com/article"
```

## How It Works

Jina Reader (`r.jina.ai`) fetches the page and returns clean, readable markdown content. It handles:
- JavaScript-rendered pages
- Paywalls (sometimes)
- Bot detection blocks
- Rate limiting

## Notes

- Returns markdown-formatted content
- May take longer than direct fetch
- Some sites may still block Jina
