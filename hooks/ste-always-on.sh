#!/usr/bin/env sh
# SessionStart hook: injects the asd-ste100-output ruleset when the user has
# turned always-on mode on, which is recorded by the presence of
# $CLAUDE_CONFIG_DIR/.asd-ste100-always (default ~/.claude).
#
# Toggle it with `/asd-ste100-output on` and `/asd-ste100-output off`.
#
# Pure POSIX sh so it runs anywhere Claude Code runs a command hook (sh on
# macOS and Linux, Git Bash on Windows) with no dependency on Node being on
# PATH. Any failure exits 0 so session start is never blocked.
#
# Load pattern adapted from ayghri/i-have-adhd (MIT).

claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
flag_path="$claude_dir/.asd-ste100-always"

# Only fire when the user has turned always-on mode on.
[ -f "$flag_path" ] || exit 0

# $0 is the absolute script path substituted into hooks.json by Claude Code,
# so resolve SKILL.md relative to it instead of trusting an exported env var.
script_dir=$(dirname -- "$0")
skill_path="$script_dir/../skills/asd-ste100-output/SKILL.md"
[ -f "$skill_path" ] || exit 0

# Strip a leading YAML frontmatter block (--- ... --- at the very top of file).
body=$(awk '
  NR == 1 && $0 ~ /^---[[:space:]]*$/ { in_fm = 1; next }
  in_fm && $0 ~ /^---[[:space:]]*$/   { in_fm = 0; next }
  !in_fm                              { print }
' "$skill_path") || exit 0

printf 'ASD-STE100 OUTPUT MODE ACTIVE (always-on). The ruleset below shapes every message you send to the user for the rest of this session. Step 1 is already done: the mode is on, so do not re-read the argument table or announce the mode unless the user asks. "stop STE mode" turns it off for this session only. `/asd-ste100-output off` (or deleting %s) turns always-on off for good.\n\n%s\n' \
  "$flag_path" "$body"
