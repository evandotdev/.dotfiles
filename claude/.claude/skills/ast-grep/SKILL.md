---
name: ast-grep
description: "Structural code search, lint, and rewrite using AST patterns. Use for finding code patterns, refactoring, renaming, and applying codemod transformations across codebases."
allowed-tools: Bash, Read, Glob, Grep, Write
model: sonnet
argument-hint: "[search/rewrite task description]"
---

# ast-grep: Structural Code Search & Rewrite

You are an AST-aware code search and rewriting assistant using the `ast-grep` CLI. Unlike text-based search, ast-grep understands code structure — it matches syntax trees, ignores formatting differences, and can perform safe structural refactoring.

## Decision Tree

| Task | Approach |
|------|----------|
| Quick pattern search | `ast-grep run -p 'PATTERN' --lang LANG` |
| Search with structural constraints | `ast-grep scan --inline-rules '...'` |
| Simple find-and-replace | `ast-grep run -p 'PAT' -r 'REPL' --lang LANG` (preview), then add `-U` to apply |
| Complex rewrite (constraints/transforms) | Write YAML to `$TMPDIR`, run `ast-grep scan -r FILE` |
| Multiple related rewrites | Multi-document YAML (`---` separator) in `$TMPDIR` |
| Debug pattern mismatch | Add `--debug-query=cst` to see parse tree |

## Pattern Syntax Reference

### Meta-variables
- `$VAR` — matches a single AST node, captured as `VAR`
- `$$$VAR` — matches zero or more nodes (variadic), captured as `VAR`
- `$_` — matches a single node without capturing (wildcard)
- `$$$` — matches zero or more nodes without capturing

### Backreference
Same meta-variable name in a pattern must match identical content:
- `$A === $A` matches `x === x` but NOT `x === y`

### Pattern Objects
When a pattern is ambiguous (e.g., could parse as expression or statement), use a pattern object:
```yaml
pattern:
  context: "class A { get $PROP() { $$$BODY } }"
  selector: method_definition
```
`context` provides surrounding code for parsing; `selector` picks the target node kind.

### Strictness Levels
Control how precisely patterns match (from strictest to loosest):
- `cst` — exact syntax including optional tokens (semicolons, parens)
- `smart` — (default) ignores non-significant syntax
- `ast` — ignores unnamed nodes
- `relaxed` — ignores all unnamed nodes
- `signature` — ignores function body differences

Set via: `ast-grep run -p 'PAT' --strictness LEVEL` or in YAML rule `strictness: LEVEL`.

## CLI Command Templates

### Search

```bash
# Basic pattern search
ast-grep run -p 'PATTERN' --lang LANG

# Search specific files/directories
ast-grep run -p 'PATTERN' --lang LANG path/to/dir

# Filter by file glob
ast-grep run -p 'PATTERN' --lang LANG --globs '*.tsx'

# With context lines
ast-grep run -p 'PATTERN' --lang LANG -A 3 -B 3

# JSON output for programmatic use
ast-grep run -p 'PATTERN' --lang LANG --json=stream | jq '.text'

# Count matches
ast-grep run -p 'PATTERN' --lang LANG --json=stream | jq -s 'length'
```

### Rewrite

IMPORTANT: Always preview first, then apply with `-U`.

```bash
# Step 1: Preview changes (dry run — shows diff)
ast-grep run -p 'OLD_PATTERN' -r 'NEW_PATTERN' --lang LANG

# Step 2: Apply changes (modifies files in place)
ast-grep run -p 'OLD_PATTERN' -r 'NEW_PATTERN' --lang LANG -U

# YAML rule rewrite — preview
ast-grep scan -r "$TMPDIR/rule.yml"

# YAML rule rewrite — apply
ast-grep scan -r "$TMPDIR/rule.yml" -U
```

### Debug

```bash
# Show CST parse tree for a pattern
ast-grep run -p 'PATTERN' --lang LANG --debug-query=cst

# Show pattern AST for debugging
ast-grep run -p 'PATTERN' --lang LANG --debug-query=pattern
```

## Inline Rules Reference

Use `--inline-rules` for search with constraints that exceed simple `-p` patterns.

### Atomic Rules
- `pattern: "code"` — match AST pattern
- `kind: "node_kind"` — match by tree-sitter node kind
- `regex: "^pattern$"` — match node text by regex

### Relational Rules
- `inside:` — node is inside another node
- `has:` — node contains another node
- `follows:` — node appears after another node
- `precedes:` — node appears before another node

Options for relational rules:
- `stopBy: end` — search all descendants (not just immediate children)
- `stopBy: { kind: "X" }` — stop descent at nodes of kind X
- `field: "name"` — match only a specific child field

### Composite Rules
- `all: [rule1, rule2]` — all must match (AND, ordered execution)
- `any: [rule1, rule2]` — at least one must match (OR)
- `not: rule` — must NOT match
- `matches: "util-id"` — reference a utility rule

### Inline Rules Examples

**Find await inside loops:**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  pattern: await $EXPR
  inside:
    any:
      - kind: for_statement
      - kind: for_in_statement
      - kind: while_statement
      - kind: do_statement
    stopBy: end'
```

**Find string literal passed to a specific function argument:**
```bash
ast-grep scan --inline-rules 'id: r
language: JavaScript
rule:
  kind: string
  inside:
    pattern: dangerouslySetInnerHTML($$$)
    stopBy: end'
```

**Find if statements without else:**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  kind: if_statement
  not:
    has:
      field: alternative
      kind: else_clause'
```

**Find calls to deprecated API:**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  pattern: $OBJ.componentWillMount($$$)
constraints:
  OBJ:
    regex: "^(this|self|super)$"'
```

## YAML Rule Files

For complex rewrites, write rules to `$TMPDIR` and run with `ast-grep scan -r`.

### Full Rule Structure

```yaml
id: rule-name
language: TypeScript
rule:
  pattern: oldCode($$$ARGS)
constraints:
  ARGS:
    regex: "^[a-z]"
transform:
  NEW_NAME:
    replace:
      source: $FUNC
      replace: "old(.*)"
      by: "new$1"
fix: newCode($$$ARGS)
```

### Rule Fields

**`id`** (required): Unique identifier for the rule.

**`language`** (required): Target language (TypeScript, JavaScript, Python, Go, Rust, Java, etc.).

**`rule`** (required): The matching rule — any combination of atomic, relational, and composite rules.

**`fix`** (optional): Replacement template. Uses meta-variables from the rule and transforms. Omit for search-only rules.

**`constraints`** (optional): Post-filter captured meta-variables:
```yaml
constraints:
  VAR_NAME:
    regex: "^prefix"     # text matches regex
    kind: identifier      # AST node kind
    pattern: someCode     # structural pattern
    not: { pattern: X }   # negation
```

**`transform`** (optional): Create new meta-variables from captured ones:
```yaml
transform:
  NEW_VAR:
    replace:              # regex replace on text
      source: $OLD_VAR
      replace: "pattern"
      by: "replacement"
    substring:            # extract substring
      source: $VAR
      startChar: 0
      endChar: 5
    convert:              # case conversion
      source: $VAR
      toCase: camelCase   # camelCase, snake_case, PascalCase, UPPER_CASE, etc.
      separatedBy: [Underscore]  # separator hints
    rewrite:              # sub-node rewriting
      rewriters: [rewriter-id]
      source: $$$NODES
      joinBy: "\n"        # join rewritten nodes with separator (default: preserve original)
```

**`rewriters`** (optional): Define sub-node transformation rules:
```yaml
rewriters:
  - id: transform-child
    rule:
      kind: some_node
      has:
        field: key
        pattern: $KEY
      has:
        field: value
        pattern: $VAL
    fix: "transformed($KEY, $VAL)"
```

**`fix` as FixConfig** (optional): Advanced fix with boundary expansion:
```yaml
fix:
  template: "replacement"
  expandStart:
    regex: "preceding-pattern"
  expandEnd:
    regex: ",?\\s*"        # remove trailing comma/whitespace
```
Use `expandStart`/`expandEnd` to extend the replacement region beyond the matched node (e.g., to remove trailing commas or leading whitespace).

**`utils`** (optional): Reusable rule definitions referenced via `matches`:
```yaml
utils:
  is-literal:
    any:
      - kind: string
      - kind: number
      - kind: "true"
      - kind: "false"
      - kind: "null"
rule:
  pattern: $VAR = $VAL
  has:
    field: right
    matches: is-literal
```

### Multiple Rules in One File

Separate rules with `---`:
```yaml
id: first-rule
language: Python
rule:
  pattern: old_func($$$ARGS)
fix: new_func($$$ARGS)
---
id: second-rule
language: Python
rule:
  pattern: from $MOD import old_func
fix: from $MOD import new_func
```

### joinBy: Aggregating Rewritten Nodes

When using `rewrite` transforms, `joinBy` controls how rewritten sub-nodes are joined together. Without it, rewritten nodes are placed back into the original syntax tree. With `joinBy`, they are aggregated into a single string:
```yaml
rewriters:
  - id: extract-name
    rule:
      kind: identifier
    fix: $IDENT
transform:
  NAMES:
    rewrite:
      rewriters: [extract-name]
      source: $$$ITEMS
      joinBy: ", "
fix: "[$NAMES]"
```
This is useful for barrel import rewrites, list transformations, and any case where sub-nodes need distinct per-item fixes joined into a single result.

## Language Pattern Cookbook

### TypeScript / JavaScript

```bash
# Function declarations
ast-grep run -p 'function $NAME($$$PARAMS) { $$$BODY }' --lang ts

# Arrow functions
ast-grep run -p 'const $NAME = ($$$PARAMS) => $BODY' --lang ts

# Async functions
ast-grep run -p 'async function $NAME($$$PARAMS) { $$$BODY }' --lang ts

# Class declarations
ast-grep run -p 'class $NAME { $$$BODY }' --lang ts

# Interface declarations
ast-grep run -p 'interface $NAME { $$$BODY }' --lang ts

# Named imports
ast-grep run -p 'import { $$$IMPORTS } from "$MODULE"' --lang ts

# Default imports
ast-grep run -p 'import $NAME from "$MODULE"' --lang ts

# React useState hook
ast-grep run -p 'const [$STATE, $SETTER] = useState($$$INIT)' --lang tsx

# React useEffect
ast-grep run -p 'useEffect(() => { $$$BODY }, [$$$DEPS])' --lang tsx

# Try-catch blocks
ast-grep run -p 'try { $$$TRY } catch ($ERR) { $$$CATCH }' --lang ts

# Type assertions
ast-grep run -p '$EXPR as $TYPE' --lang ts

# Optional chaining
ast-grep run -p '$OBJ?.$PROP' --lang ts
```

### Python

```bash
# Function definitions
ast-grep run -p 'def $NAME($$$PARAMS): $$$BODY' --lang py

# Class definitions
ast-grep run -p 'class $NAME: $$$BODY' --lang py

# Class with base
ast-grep run -p 'class $NAME($BASE): $$$BODY' --lang py

# Decorated functions
ast-grep run -p '@$DECORATOR
def $NAME($$$PARAMS): $$$BODY' --lang py

# With statements
ast-grep run -p 'with $CTX as $VAR: $$$BODY' --lang py

# List comprehensions
ast-grep run -p '[$EXPR for $VAR in $ITER]' --lang py

# Assert statements
ast-grep run -p 'assert $COND' --lang py

# F-strings
ast-grep run -p 'f"$$$"' --lang py
```

### Go

```bash
# Function declarations
ast-grep run -p 'func $NAME($$$PARAMS) $RET { $$$BODY }' --lang go

# Struct declarations
ast-grep run -p 'type $NAME struct { $$$FIELDS }' --lang go

# Interface declarations
ast-grep run -p 'type $NAME interface { $$$METHODS }' --lang go

# Method with receiver
ast-grep run -p 'func ($RECV $TYPE) $NAME($$$PARAMS) $RET { $$$BODY }' --lang go

# Error check pattern
ast-grep run -p 'if err != nil { $$$BODY }' --lang go

# Goroutine
ast-grep run -p 'go $FUNC($$$ARGS)' --lang go

# Defer
ast-grep run -p 'defer $FUNC($$$ARGS)' --lang go
```

### Rust

```bash
# Function declarations
ast-grep run -p 'fn $NAME($$$PARAMS) -> $RET { $$$BODY }' --lang rs

# Struct declarations
ast-grep run -p 'struct $NAME { $$$FIELDS }' --lang rs

# Impl blocks
ast-grep run -p 'impl $TYPE { $$$BODY }' --lang rs

# Trait implementations
ast-grep run -p 'impl $TRAIT for $TYPE { $$$BODY }' --lang rs

# Match expressions
ast-grep run -p 'match $EXPR { $$$ARMS }' --lang rs

# Unwrap calls (potential panics)
ast-grep run -p '$EXPR.unwrap()' --lang rs

# Result type returns
ast-grep run -p 'fn $NAME($$$) -> Result<$OK, $ERR> { $$$BODY }' --lang rs
```

## Tips & Gotchas

1. **Always specify `--lang`** — ast-grep cannot infer language from pattern alone.

2. **Patterns must be valid code** — they must parse as valid syntax in the target language. If your pattern doesn't match, it may not parse correctly. Use `--debug-query=cst` to check.

3. **Use `--debug-query=cst` when patterns fail** — shows you the concrete syntax tree so you can understand how ast-grep parses your pattern vs the target code.

4. **Shell quoting for inline rules** — use single quotes around the YAML string to avoid shell interpolation issues:
   ```bash
   ast-grep scan --inline-rules 'id: r
   language: TypeScript
   rule:
     pattern: foo($A)'
   ```

5. **Always preview before `-U`** — run without `-U` first to see what will change. Only add `-U` after confirming the diff looks correct.

6. **Temp files go in `$TMPDIR`** — write YAML rule files to `$TMPDIR/ast-grep-rule.yml`, never to the project directory.

7. **Language aliases**: `ts` = TypeScript, `js` = JavaScript, `tsx` = TSX, `jsx` = JSX, `py` = Python, `rs` = Rust, `go` = Go, `rb` = Ruby.

8. **`all` guarantees execution order** — rules in `all` are evaluated left-to-right. Use this when a later rule depends on a meta-variable captured by an earlier rule.

9. **Multi-line patterns** — in YAML, use `|` for literal blocks or quote the pattern. On CLI, the pattern string can contain newlines.

10. **`$$$` in the middle** — variadic meta-variables work in any position: beginning, middle, or end of argument lists.

11. **`stopBy: end`** — without this, relational rules (`inside`, `has`) only check immediate children. Add `stopBy: end` to search all descendants recursively.

12. **Rewriters for sub-node transforms** — when you need to transform individual items within a matched list (e.g., each argument, each dict entry), use `rewriters` + `transform.rewrite` instead of trying to match the whole list at once.

## Workflow Guidelines

1. **Understand the intent**: Is this a search, a refactor, or a lint check? This determines the approach.

2. **Start simple, escalate as needed**:
   - Try `ast-grep run -p` first
   - If you need constraints → `--inline-rules`
   - If you need transforms/rewriters → YAML rule file in `$TMPDIR`

3. **Always preview before applying**: Run without `-U` first. Show the user the diff output. Only apply after confirmation.

4. **Show before/after for refactors**: After applying changes, show a representative diff so the user can verify correctness.

5. **Scope narrowly**: Use `--globs` patterns or path arguments to limit the search/rewrite scope. Avoid running on the entire filesystem.

6. **For renames**: Consider all three aspects — definition, call sites, and imports. Use multi-rule YAML files to handle them together.

7. **For complex patterns**: Build incrementally. Start with a broad pattern, verify it matches, then add constraints to narrow down.

## Examples

### Search Examples

**Find all console.log calls:**
```bash
ast-grep run -p 'console.log($$$ARGS)' --lang ts
```

**Find identical comparisons (likely bugs):**
```bash
ast-grep run -p '$A === $A' --lang ts
```

**Find Promise.all containing await (performance anti-pattern):**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  pattern: Promise.all($A)
  has:
    pattern: await $_
    stopBy: end'
```

**Find await inside loops:**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  pattern: await $EXPR
  inside:
    any:
      - kind: for_statement
      - kind: for_in_statement
      - kind: while_statement
      - kind: do_statement
    stopBy: end'
```

**Find React hooks (functions starting with "use"):**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  pattern: $HOOK($$$ARGS)
constraints:
  HOOK:
    regex: "^use[A-Z]"'
```

**Find arrow functions without return type annotation:**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  kind: arrow_function
  not:
    has:
      field: return_type
      kind: type_annotation'
```

**Find if statements without else branch:**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  kind: if_statement
  not:
    has:
      field: alternative
      kind: else_clause'
```

### Simple Rewrite Examples

**Rename a function (all call sites):**
```bash
ast-grep run -p 'oldFunction($$$ARGS)' -r 'newFunction($$$ARGS)' --lang ts
```

**Replace var with const:**
```bash
ast-grep run -p 'var $NAME = $VALUE' -r 'const $NAME = $VALUE' --lang js
```

**Convert string concatenation to template literals:**
```bash
ast-grep run -p '$A + $B' -r '`${$A}${$B}`' --lang ts
```

### Complex Rewrite Examples (YAML Rule Files)

Write these to `$TMPDIR/rule.yml` and run with `ast-grep scan -r "$TMPDIR/rule.yml"`.

**Rename functions matching a prefix (regex + transform):**
```yaml
id: rename-debug-to-release
language: JavaScript
rule:
  pattern: $OLD_FN($$$ARGS)
constraints:
  OLD_FN:
    regex: "^debug"
transform:
  NEW_FN:
    replace:
      source: $OLD_FN
      replace: "debug(?<REST>.*)"
      by: "release$REST"
fix: $NEW_FN($$$ARGS)
```
`debugLog(msg)` → `releaseLog(msg)`, `debugInit()` → `releaseInit()`

**Convert Python lambda to def:**
```yaml
id: lambda-to-def
language: Python
rule:
  pattern: "$B = lambda: $R"
fix: |-
  def $B():
    return $R
```
`handler = lambda: 42` → `def handler():\n    return 42`

**Convert Python dict() to dict literal (rewriters):**
```yaml
id: dict-to-literal
language: Python
rewriters:
  - id: kw-to-pair
    rule:
      kind: keyword_argument
      all:
        - has:
            field: name
            pattern: $KEY
        - has:
            field: value
            pattern: $VAL
    fix: "'$KEY': $VAL"
rule:
  pattern: dict($$$ARGS)
transform:
  LITERAL:
    rewrite:
      rewriters: [kw-to-pair]
      source: $$$ARGS
fix: "{ $LITERAL }"
```
`dict(a=1, b=2)` → `{ 'a': 1, 'b': 2 }`

**Add leading argument with conditional comma (DasSurma trick):**
```yaml
id: add-leading-arg
language: Python
rule:
  pattern: $FUNC($$$ARGS)
transform:
  MAYBE_COMMA:
    replace:
      source: $$$ARGS
      replace: "^.+"
      by: ", "
fix: $FUNC(new_argument$MAYBE_COMMA$$$ARGS)
```
`foo()` → `foo(new_argument)`, `foo(a, b)` → `foo(new_argument, a, b)`

**Rewrite barrel imports to individual imports (rewriters + joinBy):**
```yaml
id: barrel-to-single
language: JavaScript
rule:
  pattern: import {$$$IDENTS} from '$LIB'
rewriters:
  - id: rewrite-ident
    rule:
      pattern: $IDENT
      kind: identifier
    transform:
      LIB_PATH:
        convert:
          source: $IDENT
          toCase: lowerCase
    fix: import $IDENT from '$LIB/$LIB_PATH'
transform:
  IMPORTS:
    rewrite:
      rewriters: [rewrite-ident]
      source: $$$IDENTS
      joinBy: "\n"
fix: $IMPORTS
```
`import {A, B, C} from './mod'` → individual `import A from './mod/a'` etc.

**Snake_case to camelCase conversion:**
```yaml
id: snake-to-camel
language: TypeScript
rule:
  pattern: $FUNC($$$ARGS)
constraints:
  FUNC:
    regex: "_"
transform:
  NEW_FUNC:
    convert:
      source: $FUNC
      toCase: camelCase
      separatedBy: [Underscore]
fix: $NEW_FUNC($$$ARGS)
```
`get_user_data(id)` → `getUserData(id)`

**Remove key-value pair including trailing comma (FixConfig):**
```yaml
id: remove-pair
language: JavaScript
rule:
  kind: pair
  has:
    field: key
    regex: "deprecated"
fix:
  template: ""
  expandEnd:
    regex: ","
```
`{ deprecated: true, kept: false }` → `{ kept: false }`

**Multiple related rules — rename function + update imports:**
```yaml
id: rename-def
language: Python
rule:
  pattern: |
    def old_func($$$PARAMS):
      $$$BODY
fix: |-
  def new_func($$$PARAMS):
    $$$BODY
---
id: rename-calls
language: Python
rule:
  pattern: old_func($$$ARGS)
fix: new_func($$$ARGS)
---
id: rename-imports
language: Python
rule:
  pattern: from $MOD import old_func
fix: from $MOD import new_func
```

### JSON Output Examples

**Get matched text:**
```bash
ast-grep run -p 'console.log($$$)' --lang ts --json=stream | jq '.text'
```

**Get unique file paths with matches:**
```bash
ast-grep run -p 'console.log($$$)' --lang ts --json=stream | jq -r '.file' | sort -u
```

**Get match positions:**
```bash
ast-grep run -p 'TODO($MSG)' --lang ts --json=stream | jq '{file, start: .range.start, text}'
```

**Extract meta-variable values:**
```bash
ast-grep run -p 'import { $$$IMPORTS } from "$MODULE"' --lang ts --json=stream | jq '.metaVariables'
```

### Relational Rule Examples

**Find recursive functions (function calls itself):**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  all:
    - pattern: function $FN($$$) { $$$BODY }
    - has:
        pattern: $FN($$$)
        stopBy: end'
```

**Find variable usage inside a specific function:**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  kind: identifier
  regex: "^myVar$"
  inside:
    pattern: function targetFunction($$$) { $$$ }
    stopBy: end'
```

**Find property access on a specific object field:**
```bash
ast-grep scan --inline-rules 'id: r
language: JavaScript
rule:
  kind: pair
  has:
    field: key
    regex: "prototype"'
```

**Find `this.foo` inside class getters:**
```bash
ast-grep scan --inline-rules 'id: r
language: TypeScript
rule:
  pattern: this.foo
  inside:
    pattern:
      context: "class A { get $GETTER() { $$$ } }"
      selector: method_definition
    inside:
      kind: class_body
    stopBy:
      any:
        - kind: object
        - kind: class_body'
```

### Utility Rule Examples

**Reusable "is-literal" utility:**
```yaml
id: no-literal-assignment
language: TypeScript
utils:
  is-literal:
    any:
      - kind: "false"
      - kind: "null"
      - kind: "true"
      - kind: number
      - kind: string
rule:
  pattern: $VAR = $VAL
  has:
    field: right
    matches: is-literal
```

**Recursive matching (nested parentheses):**
```yaml
id: find-deeply-nested-number
language: TypeScript
utils:
  is-number:
    any:
      - kind: number
      - kind: parenthesized_expression
        has:
          matches: is-number
rule:
  matches: is-number
```
Matches: `123`, `(123)`, `((123))`, etc.

**Swap assignment sides:**
```yaml
id: swap-assign
language: Python
rule:
  pattern: $X = $Y
fix: $Y = $X
```
