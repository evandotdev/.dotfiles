---
description: Scaffold a new Python project with best practices
allowed-tools: Bash, Write, Read
model: sonnet
argument-hint: [project-name]
---

Create a new Python project: $ARGUMENTS

First, review the Python conventions by reading the standards at `/code:standards:python-rules`.

## Project Setup Steps

1. **Create project structure**
   ```
   project-name/
   ├── app/
   │   ├── __init__.py
   │   ├── main.py
   │   ├── model.py
   │   ├── routes.py
   │   ├── api/           # Our API routes, middleware, auth
   │   │   └── __init__.py
   │   └── utils/
   │       ├── __init__.py
   │       └── env.py     # Environment variable handling
   ├── tests/
   │   └── __init__.py
   ├── pyproject.toml
   ├── .env.example
   ├── .gitignore
   └── README.md
   ```

2. **Configure pyproject.toml** with:
   - FastAPI + uvicorn
   - ruff for linting
   - pyright for type checking
   - pytest for testing

3. **Set up AppSettings** using Pydantic:
   ```python
   from pydantic import SecretStr
   from pydantic_settings import BaseSettings

   class AppSettings(BaseSettings):
       debug: bool = False
       api_key: SecretStr

       class Config:
           env_file = ".env"
   ```

4. **Create .env.example** with placeholder values

5. **Initialize git** with appropriate .gitignore
