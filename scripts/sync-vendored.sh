#!/bin/sh
# Check or apply upstream updates for the skills vendored from other people's
# repos. Reads vendor/UPSTREAM.json; see CLAUDE.md, "Vendored skills".
#
#   sh scripts/sync-vendored.sh           report what changed upstream (exit 1 on drift)
#   sh scripts/sync-vendored.sh --apply   copy the new upstream files in and record the new SHA
#
# Files listed under "deltas" are never overwritten by --apply — their upstream
# diff is printed instead, so a deliberate local change is ported by hand rather
# than silently reverted.

set -eu

MANIFEST=vendor/UPSTREAM.json
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

command -v jq >/dev/null 2>&1 || { echo "sync-vendored: jq is required" >&2; exit 2; }
[ -f "$MANIFEST" ] || { echo "sync-vendored: $MANIFEST not found — run from the repo root" >&2; exit 2; }

# jq built for Windows writes CRLF. A stray CR rides along into every path and
# comparison built from its output, so strip it at the source; a no-op elsewhere.
jqr() { jq "$@" | tr -d '\r'; }

# --apply overwrites the vendored files in place. An uncommitted edit to one of
# them that is not recorded under "deltas" would be destroyed with nothing to
# recover it from, so refuse rather than clobber.
if [ "$APPLY" = 1 ]; then
  TARGETS=$(jq -r '.sources[].paths[].to' "$MANIFEST" | tr -d '\r')
  DIRTY=$(git status --porcelain -- $TARGETS 2>/dev/null || true)
  if [ -n "$DIRTY" ]; then
    echo "sync-vendored: refusing --apply, the vendored paths have uncommitted changes:" >&2
    printf '%s\n' "$DIRTY" >&2
    echo "Commit or stash them first — --apply overwrites these files." >&2
    exit 3
  fi
fi

# Plain `mktemp -d` is a GNU extension; BSD/macOS wants an explicit template.
WORK=$(mktemp -d 2>/dev/null || mktemp -d "${TMPDIR:-/tmp}/sync-vendored.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

DRIFT=0

for i in $(jqr -r '.sources | to_entries[] | .key' "$MANIFEST"); do
  SRC=$(jqr -c ".sources[$i]" "$MANIFEST")
  NAME=$(printf '%s' "$SRC" | jqr -r '.name')
  REPO=$(printf '%s' "$SRC" | jqr -r '.repo')
  REF=$(printf '%s' "$SRC" | jqr -r '.ref')
  SYNCED=$(printf '%s' "$SRC" | jqr -r '.synced')
  EXCLUDES=$(printf '%s' "$SRC" | jqr -r '.exclude[]?')

  echo "=== $NAME ($REPO @ $REF)"

  CLONE="$WORK/$NAME"
  # No --depth: the diff against the recorded SHA needs that commit's history.
  git clone --quiet --filter=blob:none --sparse "$REPO" "$CLONE"
  git -C "$CLONE" sparse-checkout set $(printf '%s' "$SRC" | jqr -r '.paths[].from') >/dev/null
  git -C "$CLONE" checkout --quiet "$REF"
  HEAD=$(git -C "$CLONE" rev-parse HEAD | tr -d '\r')

  if [ "$HEAD" = "$SYNCED" ]; then
    echo "up to date at $HEAD"
    echo
    continue
  fi

  echo "upstream moved: $SYNCED -> $HEAD"

  # Walk each mapped directory file by file so excluded files stay out of both
  # the report and the copy, and so a file added upstream shows up as new.
  printf '%s' "$SRC" | jqr -r '.paths[] | .from + "\t" + .to' > "$WORK/paths"
  while IFS="$(printf '\t')" read -r FROM TO; do
    # 2>/dev/null: a directory dropped upstream entirely is reported by the
    # deletion pass below, not as a find error.
    for ABS in $(cd "$CLONE" && find "$FROM" -type f 2>/dev/null | sort); do
      REL=${ABS#"$FROM"/}
      SKIP=0
      for EX in $EXCLUDES; do
        [ "$REL" = "$EX" ] && SKIP=1
      done
      [ "$SKIP" = 1 ] && continue

      LOCAL="$TO/$REL"
      DELTA=$(printf '%s' "$SRC" | jqr -r --arg f "$LOCAL" '.deltas[]? | select(.file == $f) | .why')
      # A delta file diffs from its own baseline, which --apply never advances.
      # Against the source's SHA the report would show the change once and then
      # lose it at the next --apply, even though nobody ported it. From its own
      # baseline it keeps showing until a human ports it and moves that baseline.
      BASE=$(printf '%s' "$SRC" | jqr -r --arg f "$LOCAL" --arg s "$SYNCED" \
        '(.deltas[]? | select(.file == $f) | .synced) // $s')

      if git -C "$CLONE" diff --quiet "$BASE" "$HEAD" -- "$ABS" 2>/dev/null; then
        continue
      fi

      echo
      if [ -n "$DELTA" ]; then
        echo "--- $LOCAL (LOCAL DELTA — not overwritten, port by hand)"
        echo "    why: $DELTA"
        echo "    once ported, set this delta's \"synced\" to $HEAD or it keeps reporting"
      else
        echo "--- $LOCAL"
      fi
      git -C "$CLONE" --no-pager diff "$BASE" "$HEAD" -- "$ABS" | tail -n +5

      if [ "$APPLY" = 1 ] && [ -z "$DELTA" ]; then
        mkdir -p "$(dirname "$LOCAL")"
        cp "$CLONE/$ABS" "$LOCAL"
        echo "    applied"
      fi
    done

    # A file dropped upstream is invisible to the walk above, which only sees
    # what still exists at HEAD. Report it; deleting is left to a human.
    for GONE in $(git -C "$CLONE" diff --name-only --diff-filter=D "$SYNCED" "$HEAD" -- "$FROM" | tr -d '\r'); do
      REL=${GONE#"$FROM"/}
      SKIP=0
      for EX in $EXCLUDES; do
        [ "$REL" = "$EX" ] && SKIP=1
      done
      [ "$SKIP" = 1 ] && continue
      echo
      echo "--- $TO/$REL (DELETED UPSTREAM — remove it by hand if you agree)"
    done
  done < "$WORK/paths"

  echo
  if [ "$APPLY" = 1 ]; then
    jqr --argjson i "$i" --arg sha "$HEAD" '.sources[$i].synced = $sha' "$MANIFEST" > "$WORK/m.json"
    mv "$WORK/m.json" "$MANIFEST"
    echo "recorded $NAME at $HEAD — review the diff before committing"
  else
    DRIFT=1
  fi
  echo
done

[ "$DRIFT" = 1 ] && { echo "Run 'sh scripts/sync-vendored.sh --apply' to pull these in."; exit 1; }
echo "No drift."
