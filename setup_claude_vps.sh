#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── stow ────────────────────────────────────────────────────────────────────
if ! command -v stow &>/dev/null; then
	echo "Installing stow..."
	if command -v apt-get &>/dev/null; then
		sudo apt-get install -y stow
	elif command -v brew &>/dev/null; then
		brew install stow
	else
		echo "ERROR: Cannot install stow — install it manually and re-run." >&2
		exit 1
	fi
fi

cd "$DOTFILES"
echo "Stowing claude..."
stow -vD claude
stow -v claude
echo

# ── MCP servers ─────────────────────────────────────────────────────────────
if command -v claude &>/dev/null; then
	bash "$DOTFILES/setup_mcp.sh"
else
	echo "WARN: claude CLI not found — skipping MCP setup. Re-run after installing Claude Code."
fi
