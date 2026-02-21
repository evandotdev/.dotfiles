# Engineering Standards & Research

- **Research:** When asked to perform research, always place the output (Markdown files, etc.) in `~/personal/research`.
- **Code Search:** When looking for code examples, API usage, library documentation, or debugging help from the web, prefer the `get-code-context-exa` skill (if available) or similar technical search over general web search.
- **Codebase Exploration:** Prefer using Serena's semantic tools (if configured) or the `codebase_investigator` for deep understanding.

# Code Style

- Avoid comments unless the "why" isn't obvious from the code.
- Prefer early returns over deep nesting.
- Functions should do one thing.
- Don't abstract until you see a pattern 2-3 times.
- Avoid using magic numbers; use meaningful variable names.
- Split methods that do multiple things (Single Responsibility Principle).

# Layered Architecture (Web Backends)

## Controller
- Input validation, HTTP formatting, status codes.
- Throws HTTP exceptions.
- **NO** business logic, retries, or database access.
- Validation of query parameters belongs here.

## Service
- Business logic, orchestration, retry strategies.
- Database operations.
- Decides what to do with results.

## API Client
- One method = one HTTP request.
- Transform responses (e.g., snake_case to camelCase).
- Throws on HTTP errors.
- **NO** retries, fallbacks, or business decisions.
- API clients are stateless; the caller handles failures.

# Database & API
- **Database:** Use UUID7 as database keys (time-ordered) for better performance. Avoid table-level operations that cannot be rolled back.
- **API Calls:** Always add retry logic with consistent formatting (using a single function/decorator if possible) for reliability.

# Environment Variables
- Update `.env.example` files with new variables.
- Always use example values in `.env.example`; avoid real values.
- Update example files if names or defaults change.

# Git Workflow
- Check if working in a bare git repository.
- If in a bare repository, use `~/.local/bin/wtc` for worktree creation.
- Before creating a worktree, pull latest changes:
  ```bash
  git fetch origin main:main # or master:master
  ```

# Specialized Research Roles
When performing the following tasks, adhere to these specific guidelines:

## Business Research
Analyze market size (TAM/SAM/SOM), competitors (direct/indirect), domain availability, and distribution channels (Product Hunt, Indie Hackers, etc.). Use platforms like G2, Crunchbase, and Product Hunt for traction signals.

## Relocation Research
Evaluate city/country viability for senior SWEs (Singaporean/Chinese context). Analyze salary (levels.fyi, Glassdoor), cost of living, immigration pathways (PR timeline), safety, and lifestyle (dating, community).

## Thought Analysis
Extract high-value insights from `thoughts/` directory. Filter out noise, capture decisions, trade-offs, and technical specs. Focus on what is actionable now.
