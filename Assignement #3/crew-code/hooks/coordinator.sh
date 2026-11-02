#!/usr/bin/env bash
# Machine coordinator: runs at the start of every Claude Code session (SessionStart hook).
# Works out which machine this is, syncs the repository with git, and tells Claude what
# this machine can and cannot do. Its output is added to Claude's context.
# Light on purpose: a few git commands, no network calls other than git fetch.

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
REG=".claude/machines.txt"

# --- 1. Which machine? ---------------------------------------------------------
if [ -n "$COORD_TEST_ID" ]; then
  ID="$COORD_TEST_ID"
elif [ -n "$CLAUDE_CODE_REMOTE" ] || { [ "$(uname -s)" = "Linux" ] && [ -z "$WSL_DISTRO_NAME" ]; }; then
  ID="cloud"
else
  ID="${COMPUTERNAME:-$(hostname 2>/dev/null)}"
fi
ID=$(printf '%s' "$ID" | tr '[:lower:]' '[:upper:]')
ROLE=$(grep -i "^$ID=" "$REG" 2>/dev/null | head -1 | cut -d= -f2 | tr -d '\r')
[ "$ID" = "CLOUD" ] && [ -z "$ROLE" ] && ROLE="telephone"

echo "## Machine coordinator"
if [ -z "$ROLE" ]; then
  echo "- Unknown machine: \`$ID\`. Before anything else, ask the designer (one short question, in French) which machine this is: pc-fixe or pc-portable. Then add the line \`$ID=<answer>\` to $REG and commit it."
  ROLE="unknown"
else
  echo "- Machine: **$ROLE** (\`$ID\`)."
fi

case "$ROLE" in
  pc-fixe|pc-portable)
    echo "- This machine has Unreal 5.8, the unreal-mcp server and the build scripts: the full verify loop of CLAUDE.md applies." ;;
  telephone)
    echo "- Cloud session (phone or web): no Unreal, no MCP, no PowerShell, no build. Work on docs, the review inbox, plans and C++ text only. Never claim C++ builds or passes tests here: list every C++ change as 'not compiled yet' in the hand-over and in the commit message, so the next PC session builds it first. The verify gate is skipped on this machine." ;;
esac

# --- 2. Git sync --------------------------------------------------------------
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "- Not a git repository: no sync."; exit 0; }
BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
UP=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
if [ -z "$UP" ]; then echo "- Branch \`$BR\` has no remote branch: nothing to pull. Push it with \`git push -u origin $BR\` when ready."; exit 0; fi

if ! timeout 25 git fetch --quiet 2>/dev/null; then
  echo "- git fetch failed (offline?). Work continues on the local copy; sync before ending the session."
  exit 0
fi
BEHIND=$(git rev-list --count HEAD.."$UP" 2>/dev/null || echo 0)
AHEAD=$(git rev-list --count "$UP"..HEAD 2>/dev/null || echo 0)
DIRTY=$(git status --porcelain 2>/dev/null | grep -v '^??' | wc -l | tr -d ' ')

LAST=$(git log -1 --format='%(trailers:key=Machine,valueonly)' "$UP" 2>/dev/null | head -1 | tr -d '\r')
WHEN=$(git log -1 --format='%cr' "$UP" 2>/dev/null)
[ -n "$LAST" ] && echo "- Last push came from **$LAST**, $WHEN."

if [ "$BEHIND" -gt 0 ] && [ "$AHEAD" -gt 0 ]; then
  echo "- DIVERGED: $AHEAD local commit(s) and $BEHIND remote commit(s) on \`$BR\`. Nothing was pulled. Hand this to the machine-coordinator agent before any other work."
elif [ "$BEHIND" -gt 0 ] && [ "$DIRTY" -gt 0 ]; then
  echo "- $BEHIND new commit(s) on the remote, but $DIRTY uncommitted local change(s): nothing was pulled. Hand this to the machine-coordinator agent before any other work."
elif [ "$BEHIND" -gt 0 ]; then
  OLD=$(git rev-parse HEAD)
  if git pull --ff-only --quiet 2>/dev/null; then
    echo "- Pulled $BEHIND commit(s) from the other machine:"
    git log --format='  - %s' "$OLD"..HEAD | head -8
    CHANGED=$(git diff --name-only "$OLD" HEAD)
    if printf '%s\n' "$CHANGED" | grep -qE '(^|/)(Source|Plugins)/.*\.(h|cpp|cs)$|\.uproject$'; then
      if [ "$ROLE" = "telephone" ]; then echo "  - C++ changed: it will need a build on the next PC session."
      else echo "  - C++ changed: before opening or using the editor, close it if open (close-editor.ps1) and run .claude\\scripts\\build.ps1."; fi
    fi
    printf '%s\n' "$CHANGED" | grep -q '^review/' && echo "  - The review inbox changed: mention the pending count to the designer."
  else
    echo "- git pull failed. Hand this to the machine-coordinator agent before any other work."
  fi
else
  echo "- Up to date with \`$UP\`."
fi
[ "$AHEAD" -gt 0 ] && [ "$BEHIND" -eq 0 ] && echo "- $AHEAD local commit(s) not pushed yet: push them before switching machine."
[ "$DIRTY" -gt 0 ] && [ "$BEHIND" -eq 0 ] && echo "- $DIRTY uncommitted change(s) left from a previous session on this machine: tell the designer in one line."
[ "$ROLE" != "unknown" ] && echo "- Commits made on this machine end with the trailer \`Machine: $ROLE\`."
exit 0
