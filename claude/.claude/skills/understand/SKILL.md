---
description: Get a comprehensive overview of the current project
allowed-tools: Read, Glob, Grep, Bash, LS
model: sonnet
---

Analyze this project and answer:

1. **What does this project do?**
   - Core purpose and functionality
   - Target users/use cases

2. **What technologies does this project use?**
   - Language(s) and frameworks
   - Key dependencies
   - Database/storage
   - External services/APIs

3. **Where is the main entry point?**
   - Application entry file
   - How to run the project
   - Environment setup needed

4. **Explain the folder structure**
   - Purpose of each top-level directory
   - Key files and their roles
   - Conventions used (if any)

## Output Format

```
## Project: [name]

### Purpose
[2-3 sentences describing what this does]

### Tech Stack
- **Language**:
- **Framework**:
- **Database**:
- **Key Dependencies**:

### Entry Point
- **File**: `path/to/main`
- **Run command**: `command here`
- **Required env vars**: list them

### Structure
```
project/
├── src/          # [description]
├── tests/        # [description]
└── config/       # [description]
```

### Key Files
- `file1` - description
- `file2` - description
```
