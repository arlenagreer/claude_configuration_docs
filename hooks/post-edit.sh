#!/usr/bin/env bash
# Global Claude Code hook - runs quality checks after file edit
# Symlink behavior to post-write.sh for same quality checks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/post-write.sh" "$@"