#!/bin/sh
# Re-assert the Simplified Technical English rules as the context grows.
#
# Why this exists: Claude Code injects a per-turn system reminder naming the
# active output style, but only for BUILT-IN styles. The render step looks the
# display name up in a map holding default/Proactive/Explanatory/Learning, and a
# plugin style registers as "<plugin>:<name>", which is never a key in it. So a
# built-in style gets re-anchored every turn and a plugin style gets re-anchored
# never. Custom styles also cannot declare their own reminder text — the
# frontmatter schema is strict and accepts only name, description,
# keep-coding-instructions, and force-for-plugin. This script restores the parity
# the harness withholds. Verified against Claude Code 2.1.222.
#
#   UserPromptSubmit        short reminder, mirrors what built-ins get
#   SessionStart(compact)   longer reminder, because compaction also deletes
#                           every compliant turn and those examples are what
#                           actually hold the voice
#
# Inert unless one of the STE styles is active, so it costs nothing when they
# are off. Toggle with /behavior:toggle-simplified-english.
# Exits 0 on every path — a hook failure must never block a turn or startup.
#
# This runs on EVERY user turn, so process spawns are the dominant cost (~35ms
# each on Windows). It holds itself to three on the normal path: cat, one jq to
# read settings, one jq to emit. Event and source detection use case globs, and
# a fourth spawn appears only when CLAUDE_PROJECT_DIR is unset. Prefer a shell
# builtin over a subprocess when adding to this.

set -u

STE_PLAIN='behavior:Simplified Technical English'
STE_INSIGHTS='behavior:Simplified Technical English with Insights'

# No jq means no way to read settings or emit JSON. Stay silent.
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null) || exit 0

# Event and source come from globs rather than jq, to save two spawns per turn.
# Claude Code emits compact JSON with no space after the colon, so these match.
# If a future version pretty-prints, the globs miss and the hook goes silent —
# the same fail-safe path as jq being absent, never a wrong injection.
case "$INPUT" in
  *'"hook_event_name":"UserPromptSubmit"'*) EVENT=UserPromptSubmit ;;
  *'"hook_event_name":"SessionStart"'*)     EVENT=SessionStart ;;
  *) exit 0 ;;
esac

# Only claim a compaction when the payload actually says so. Without this the
# SessionStart wording would assert a compaction on any registration that omits
# the "compact" matcher in hooks.json.
case "$INPUT" in
  *'"source":"compact"'*) COMPACTED=yes ;;
  *)                      COMPACTED=no ;;
esac

# .cwd needs real JSON parsing, since a Windows path carries escaped
# backslashes. Claude Code sets CLAUDE_PROJECT_DIR, so this rarely spawns.
PROJECT_DIR=${CLAUDE_PROJECT_DIR:-$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)}

# Resolve the user scope to '' rather than joining a base that is missing, so an
# unset HOME reads as "there is no user scope" instead of pointing at /.claude.
# ${HOME:-} rather than $HOME: `set -u` makes an unset HOME a fatal expansion
# error, which would exit 1 and break the exit-0 contract above.
if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
  CONFIG_DIR=$CLAUDE_CONFIG_DIR
elif [ -n "${HOME:-}" ]; then
  CONFIG_DIR=$HOME/.claude
else
  CONFIG_DIR=''
fi

# Collect the settings files that exist, highest precedence first. A base
# directory that resolved to nothing is skipped rather than joined, because
# "$PROJECT_DIR/.claude/settings.json" with PROJECT_DIR empty probes /.claude —
# an absolute path the user never configured, and on a POSIX host a readable one.
set --
if [ -n "$PROJECT_DIR" ]; then
  for settings in \
    "$PROJECT_DIR/.claude/settings.local.json" \
    "$PROJECT_DIR/.claude/settings.json"
  do
    if [ -f "$settings" ]; then
      set -- "$@" "$settings"
    fi
  done
fi
if [ -n "$CONFIG_DIR" ] && [ -f "$CONFIG_DIR/settings.json" ]; then
  set -- "$@" "$CONFIG_DIR/settings.json"
fi
[ "$#" -gt 0 ] || exit 0

# One jq for all of them, slurped so jq itself picks the winner — piping to
# `head -1` would cost another spawn. Argument order is precedence order, so the
# first file that sets the key wins. Accepted trade-off: a malformed
# high-precedence file aborts jq before it reaches the lower ones, where a
# per-file loop would have fallen through to them.
active=$(jq -s -r 'first(.[] | .outputStyle // empty | select(. != "")) // empty' \
  "$@" 2>/dev/null) || active=''

case "$active" in
  "$STE_PLAIN"|"$STE_INSIGHTS") ;;
  *) exit 0 ;;
esac

# The per-turn reminder is deliberately terse — it accumulates in the
# transcript once per turn, so every token is paid N times over a session. The
# full spec already sits in the system prompt. This only re-anchors the rules
# that drift first. The compact reminder runs 2-3 times per session, so it can
# afford to be longer.
LABEL='STE'
INSIGHTS=''
if [ "$active" = "$STE_INSIGHTS" ]; then
  LABEL='STE+Insights'
  INSIGHTS=' Insights in STE too.'
fi

RULES='short sentences, one idea each, active voice, no progressive, no should/would/could/may/might.'

if [ "$EVENT" = SessionStart ] && [ "$COMPACTED" = yes ]; then
  CONTEXT="${active#*:} output style is active, and the context was just compacted. Compaction removed every STE-compliant turn, and those examples are what hold the voice, so re-anchor deliberately: $RULES Conditions first, no filler, no idioms. Transcript prose only — not code, commits, or file contents.$INSIGHTS"
else
  CONTEXT="$LABEL active: $RULES$INSIGHTS"
fi

jq -n --arg event "$EVENT" --arg ctx "$CONTEXT" \
  '{hookSpecificOutput: {hookEventName: $event, additionalContext: $ctx}}' \
  2>/dev/null || exit 0

exit 0
