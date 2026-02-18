---
description: Generate daily standup updates from git commits
allowed-tools: Bash
model: haiku
argument-hint: [date (optional, e.g. "yesterday", "2024-01-15")]
---

Run `daily-commits` and summarize by repository.

Format the response exactly like this:

```
done:

repository_name:

- commit summary 1
- commit summary 2

another_repo:

- commit summary 1
```

## Example Output

```
done:

dojo-messaging:

- fix pypi version lagging behind - removed auto-publish on main branch push
- update logging - changed error levels to trace, added URL context to server errors

dojo:

- fix redis-om indexing issues - switched between HashModel/JsonModel with proper index=True
- cleanup unused imports in validator - removed bittensor subtensor/wallet references
- update miner documentation - added Redis host/port configuration examples
```

Keep summaries concise - one line per commit, lowercase, focus on what changed.
