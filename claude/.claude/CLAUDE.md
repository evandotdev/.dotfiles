# Research
- When asked to perform research, always place the output of your research (e.g. Markdown files, etc.) in `~/personal/research`

# Code Style

- Avoid comments unless the "why" isn't obvious from the code
- Prefer early returns over deep nesting
- Functions should do one thing
- Don't abstract until you see a pattern 2-3 times
- Avoid using magic numbers, try to create variables with meaningful names.
- Split methods that do multiple things, try to follow single responsibility principle without creating too much overhead

# Layered Architecture (Web Backends)

## Controller

- Input validation, HTTP formatting, status codes
- Throws HTTP exceptions
- NO business logic, retries, or database access
- Validation of query parameters belong here 

## Service

- Business logic, orchestration, retry strategies
- Database operations
- Decides what to do with results

## API Client

- One method = one HTTP request
- Transform responses (e.g. when calling a python backend and reading that data in typescript/javascript snake_case → camelCase depending )
- Throws on HTTP errors
- NO retries, fallbacks, or business decisions
- API clients are stateless - caller handles failures

# Misc

- Remember to update any .env.example files with new environment variables that you have added.
- Remember always to use example values inside of .env.example, avoid using real values.
- Remember to update any environment variable example files whenever an environment variable's name changes, default value changes, or as needed.


# Database
- Try to use UUID7 as database keys, instead of UUID4 as UUID7 are time-ordered so it has better performance on sorting.
- Avoid using table level operations as they're extremely aggressive and can't be rolled back.

# External/Internal API Calls
- When making API calls to internal or external services, always add retry logic with consistent formatting and a single function or decorator if possible to standardize retry logic. This is to ensure reliability of the calls.

# Code Search Online

When looking for code examples, API usage, library documentation, SDK patterns, or debugging help from the web, prefer the `get-code-context-exa` skill over WebSearch/WebFetch:

```
/get-code-context-exa
```

Use `web-search-researcher` for non-code research (articles, comparisons, general information) or when Exa results are insufficient.

# Git
- Check if you are working in a bare git repository.
  - If you are in a bare git repository, whenever working on a new feature, bugfix, enhancement, etc. use the commands from `~/.local/bin`
  - `~/.local/bin/wtc` -> worktree creation helper, read the script carefully to understand it.
- Before creating a worktree, always pull the latest changes from main or master using either of the following. NOTE: remember to check worktrees using `git worktree list` to remove any worktree that references the main or master branch before doing so.

```
# for main
git fetch origin main:main
# for master
git fetch origin master:master
```
