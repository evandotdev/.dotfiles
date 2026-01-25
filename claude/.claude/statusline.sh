#!/bin/bash
# Claude Code Status Line - Comprehensive
# Displays: Session Name/ID | Model | Directory | Git Branch | Cost | Context % | Lines +/-

# Read JSON input from stdin
input=$(cat)

# ═══════════════════════════════════════════════════════════════════════════════
# COLORS (ANSI escape codes)
# ═══════════════════════════════════════════════════════════════════════════════
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# Foreground colors
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

# Bright foreground colors
BRIGHT_BLACK="\033[90m"
BRIGHT_RED="\033[91m"
BRIGHT_GREEN="\033[92m"
BRIGHT_YELLOW="\033[93m"
BRIGHT_BLUE="\033[94m"
BRIGHT_MAGENTA="\033[95m"
BRIGHT_CYAN="\033[96m"
BRIGHT_WHITE="\033[97m"

# ═══════════════════════════════════════════════════════════════════════════════
# EXTRACT VALUES FROM JSON
# ═══════════════════════════════════════════════════════════════════════════════
SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')
MODEL_ID=$(echo "$input" | jq -r '.model.id // "?"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // empty')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // empty')
VERSION=$(echo "$input" | jq -r '.version // empty')

# Cost metrics
COST_USD=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Context window
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // empty')

# ═══════════════════════════════════════════════════════════════════════════════
# GET SESSION NAME (custom title or fallback to ID)
# ═══════════════════════════════════════════════════════════════════════════════
get_session_name() {
    local session_id="$1"
    local project_dir="$2"

    if [ -z "$session_id" ]; then
        echo ""
        return
    fi

    # Convert project path to Claude's encoded format
    # /Users/jarvis/.dotfiles -> -Users-jarvis--dotfiles
    local encoded_path=$(echo "$project_dir" | sed 's|^/||' | sed 's|/|-|g' | sed 's|\.|-|g')
    local session_file="$HOME/.claude/projects/-${encoded_path}/${session_id}.jsonl"
    local index_file="$HOME/.claude/projects/-${encoded_path}/sessions-index.json"

    # Try to get custom title from session file first (most up-to-date)
    if [ -f "$session_file" ]; then
        local custom_title=$(grep '"type":"custom-title"' "$session_file" 2>/dev/null | tail -1 | jq -r '.customTitle // empty' 2>/dev/null)
        if [ -n "$custom_title" ]; then
            echo "$custom_title"
            return
        fi
    fi

    # Try sessions-index.json for customTitle or summary
    if [ -f "$index_file" ]; then
        local title=$(jq -r --arg sid "$session_id" '.entries[] | select(.sessionId == $sid) | .customTitle // .summary // empty' "$index_file" 2>/dev/null)
        if [ -n "$title" ]; then
            echo "$title"
            return
        fi
    fi

    # Fallback to short session ID
    echo "${session_id:0:8}"
}

SESSION_NAME=$(get_session_name "$SESSION_ID" "$PROJECT_DIR")

# ═══════════════════════════════════════════════════════════════════════════════
# GET GIT INFO (branch + lines changed on branch)
# ═══════════════════════════════════════════════════════════════════════════════
GIT_BRANCH=""
GIT_LINES_ADDED=0
GIT_LINES_REMOVED=0
GIT_SYNC_STATUS=""
if [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR" ]; then
    cd "$CURRENT_DIR" 2>/dev/null
    if git rev-parse --git-dir > /dev/null 2>&1; then
        BRANCH=$(git branch --show-current 2>/dev/null)
        if [ -n "$BRANCH" ]; then
            GIT_BRANCH="$BRANCH"

            # Determine base branch
            BASE_BRANCH=""
            if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
                BASE_BRANCH="main"
            elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
                BASE_BRANCH="master"
            fi

            # Get lines changed: branch diff if on feature branch, uncommitted if on main/master
            if [ -n "$BASE_BRANCH" ] && [ "$BRANCH" != "$BASE_BRANCH" ]; then
                DIFF_STATS=$(git diff --shortstat "$BASE_BRANCH"...HEAD 2>/dev/null)
            else
                DIFF_STATS=$(git diff --shortstat HEAD 2>/dev/null)
            fi

            if [ -n "$DIFF_STATS" ]; then
                GIT_LINES_ADDED=$(echo "$DIFF_STATS" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
                GIT_LINES_REMOVED=$(echo "$DIFF_STATS" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)
            fi

            # Check sync status with upstream
            UPSTREAM=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
            if [ -n "$UPSTREAM" ]; then
                COUNTS=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
                AHEAD=$(echo "$COUNTS" | cut -f1)
                BEHIND=$(echo "$COUNTS" | cut -f2)
                if [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -eq 0 ]; then
                    GIT_SYNC_STATUS="✓"
                elif [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -eq 0 ]; then
                    GIT_SYNC_STATUS="↑${AHEAD}"
                elif [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -gt 0 ]; then
                    GIT_SYNC_STATUS="↓${BEHIND}"
                else
                    GIT_SYNC_STATUS="↑${AHEAD}↓${BEHIND}"
                fi
            fi
        fi
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# FORMAT VALUES
# ═══════════════════════════════════════════════════════════════════════════════
# Directory - just the basename
DIR_NAME="${CURRENT_DIR##*/}"

# Cost - format to cents or dollars
if (( $(echo "$COST_USD < 0.01" | bc -l) )); then
    COST_DISPLAY=$(printf "%.1f¢" $(echo "$COST_USD * 100" | bc -l))
else
    COST_DISPLAY=$(printf "\$%.2f" "$COST_USD")
fi

# Context percentage - calculate from transcript for accuracy
# See: github.com/anthropics/claude-code/issues/13652
CONTEXT_TOKENS=0
CONTEXT_PCT=0
CONTEXT_PREFIX=""
MAX_K=$((CONTEXT_SIZE / 1000))

if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    CONTEXT_TOKENS=$(jq -s '
        map(select(.message.usage and .isSidechain != true and .isApiErrorMessage != true)) |
        last |
        if . then
            (.message.usage.input_tokens // 0) +
            (.message.usage.cache_read_input_tokens // 0) +
            (.message.usage.cache_creation_input_tokens // 0)
        else 0 end
    ' < "$TRANSCRIPT_PATH" 2>/dev/null)

    if [ "$CONTEXT_TOKENS" -gt 0 ]; then
        CONTEXT_PCT=$((CONTEXT_TOKENS * 100 / CONTEXT_SIZE))
    else
        # Baseline: ~20k for system prompt, tools, memory
        CONTEXT_PCT=$((20000 * 100 / CONTEXT_SIZE))
        CONTEXT_PREFIX="~"
    fi
else
    CONTEXT_PCT=$((20000 * 100 / CONTEXT_SIZE))
    CONTEXT_PREFIX="~"
fi
[ "$CONTEXT_PCT" -gt 100 ] && CONTEXT_PCT=100

# Duration - convert to seconds/minutes
if [ "$DURATION_MS" -gt 60000 ]; then
    DURATION_DISPLAY="$(( DURATION_MS / 60000 ))m"
else
    DURATION_DISPLAY="$(( DURATION_MS / 1000 ))s"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# BUILD STATUS LINE
# ═══════════════════════════════════════════════════════════════════════════════
# Separator
SEP="${DIM}│${RESET}"

# Directory section
DIR_SECTION="${DIM}CWD:${RESET}${BLUE}${DIR_NAME}${RESET}"

# Session name/ID section (on its own line)
SESSION_SECTION=""
if [ -n "$SESSION_NAME" ]; then
    SESSION_SECTION="\n${DIM}SESH:${RESET}${CYAN}${SESSION_NAME}${RESET}"
fi

# Model section
MODEL_SECTION="${SEP} ${YELLOW}${MODEL_ID}${RESET}"

# Git section (branch + lines changed + sync status)
GIT_SECTION=""
if [ -n "$GIT_BRANCH" ]; then
    LINES_PART=""
    if [ "$GIT_LINES_ADDED" -gt 0 ] || [ "$GIT_LINES_REMOVED" -gt 0 ]; then
        LINES_PART="${GREEN}+${GIT_LINES_ADDED}${RESET}/${RED}-${GIT_LINES_REMOVED}${RESET} "
    fi
    SYNC_PART=""
    if [ -n "$GIT_SYNC_STATUS" ]; then
        SYNC_PART=" ${DIM}${GIT_SYNC_STATUS}${RESET}"
    fi
    GIT_SECTION="${SEP} ${DIM}Git:${RESET}${LINES_PART}${GREEN}${GIT_BRANCH}${RESET}${SYNC_PART}"
fi

# Cost section
COST_SECTION="${SEP} ${DIM}Cost:${RESET}${MAGENTA}${COST_DISPLAY}${RESET}"

# Context section - visual bar + percentage
BAR_WIDTH=10
BAR=""
C_BAR_FILLED='\033[38;5;245m'
C_BAR_EMPTY='\033[38;5;238m'
for ((i=0; i<BAR_WIDTH; i++)); do
    BAR_START=$((i * 10))
    PROGRESS=$((CONTEXT_PCT - BAR_START))
    if [ "$PROGRESS" -ge 8 ]; then
        BAR+="${C_BAR_FILLED}█${RESET}"
    elif [ "$PROGRESS" -ge 3 ]; then
        BAR+="${C_BAR_FILLED}▄${RESET}"
    else
        BAR+="${C_BAR_EMPTY}░${RESET}"
    fi
done
CONTEXT_SECTION="${SEP} ${DIM}Ctx:${RESET}${BAR} ${DIM}${CONTEXT_PREFIX}${CONTEXT_PCT}% of ${MAX_K}k${RESET}"

# Version section (optional - uncomment if wanted)
# VERSION_SECTION="${SEP} ${DIM}v${VERSION}${RESET}"

# ═══════════════════════════════════════════════════════════════════════════════
# OUTPUT
# ═══════════════════════════════════════════════════════════════════════════════
echo -e "${DIR_SECTION} ${GIT_SECTION}${MODEL_SECTION}${CONTEXT_SECTION}${COST_SECTION}${SESSION_SECTION}"
