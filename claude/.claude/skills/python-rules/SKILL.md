---
description: Python project conventions and best practices. Use when writing Python code or scaffolding a new FastAPI project.
allowed-tools: Read, Bash
model: haiku
argument-hint: [project-name]
---

# Python Project Standards

## Framework & Tools

| Purpose | Tool |
|---------|------|
| Web framework | FastAPI + uvicorn |
| Linting | ruff |
| Type checking | pyright |
| Dead code | vulture |
| SQL | sqlc (compile to type-safe Python) |
| Config | pyproject.toml (not requirements.txt) |

Reference: https://github.com/Kludex/fastapi-tips

## Project Structure

```
app/
├── __init__.py
├── main.py              # Entry point
├── model.py             # Data types, enums, Pydantic models
├── routes.py            # API route definitions
├── api/                 # Our API: middleware, auth, routes
│   └── __init__.py
├── api/external_name/   # External API clients
│   └── __init__.py
└── utils/               # Utilities as modules, not single files
    ├── __init__.py
    └── env.py           # Environment variable handling
```

## Configuration Pattern

```python
from pydantic import SecretStr
from pydantic_settings import BaseSettings

class AppSettings(BaseSettings):
    whitelist_ips_enabled: bool = False
    some_api_key: SecretStr
    database_url: str

    class Config:
        env_file = ".env"

settings = AppSettings()
```

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Request DTO | `*Request` | `CreateUserRequest` |
| Response DTO | `*Response` | `UserResponse` |
| API clients | `app/api/{service_name}/` | `app/api/stripe/` |
| Internal API | `app/api/` | Routes, middleware, auth |

## Key Principles

- Use Pydantic models or dataclasses for grouped variables
- Keep utilities as modules (`utils/env.py`) not single files (`utils.py`)
- External API integrations get their own directory
- All data types centralized in `model.py`

---

## Scaffolding a New Project

If `$ARGUMENTS` is provided, create a new Python project with that name:

### 1. Create project structure

```
$ARGUMENTS/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── model.py
│   ├── routes.py
│   ├── api/
│   │   └── __init__.py
│   └── utils/
│       ├── __init__.py
│       └── env.py
├── tests/
│   └── __init__.py
├── pyproject.toml
├── .env.example
├── .gitignore
└── README.md
```

### 2. Configure pyproject.toml with:
- FastAPI + uvicorn
- ruff for linting
- pyright for type checking
- pytest for testing

### 3. Set up AppSettings using Pydantic

### 4. Create .env.example with placeholder values

### 5. Initialize git with appropriate .gitignore
