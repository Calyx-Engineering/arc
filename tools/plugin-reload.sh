#!/usr/bin/env bash
# plugin-reload.sh — reload the locally-installed Arc plugin from this working tree.
#
#   tools/plugin-reload.sh                     reload arc@calyx-engineering
#   tools/plugin-reload.sh <plugin@market>     reload another one
#   tools/plugin-reload.sh --force [<p@m>]     reload anyway, after naming what is uncommitted
#   tools/plugin-reload.sh selftest            the dirty-tree cases
#   tools/plugin-reload.sh --help              this comment block
#
# THE DEV LOOP. Installing copies the plugin into
# ~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/, keyed by the version in
# .claude-plugin/plugin.json. A plain reinstall resolves the same version, reports "already
# installed", and serves the first cached snapshot — so local edits never load.
# `marketplace update` does not refresh it either. Uninstall does not delete the cache
# directory, but a reinstall overwrites it. That pair is the dev loop. Tested 2026-09-05 — #132.
#
# A running session does NOT pick this up. Restart it after reloading.
#
# WHAT THE CYCLE ACTUALLY WRITES — measured 2026-09-09 against a scratch clone, #211. The
# uninstall/install pair writes ~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/,
# installed_plugins.json and known_marketplaces.json. It writes NOTHING into the source
# directory. A clone dirtied in every shape #158 reported — tracked modifications inside
# skills/, hooks/, agents/ and commands/, a tracked deletion, untracked files, staged changes —
# came through the cycle byte-identical, and so did a second pass through this script and a
# `marketplace update`. #211 opened on the premise that the cycle reverts a working tree; it
# does not, and the revert #158 hit had another cause that is still unidentified.
#
# WHY THE GUARD IS HERE ANYWAY. The install reads the WORKING TREE, not HEAD: the cache
# received the dirty content, honoured a deletion, and copied untracked files. So a reload run
# on a dirty tree ships uncommitted work into the installed plugin, and the only copy of that
# work is the tree it came from. The session then behaves according to edits that exist in no
# commit, which is the condition under which #158 lost a file it could not name. Refusing until
# the tree is clean makes the installed plugin equal to a commit, and makes the at-risk files
# visible before they matter rather than after.
#
# IT REFUSES, IT NEVER SKIPS. #132's dev loop depends on this script, so a refusal names every
# file and gives the two ways forward — commit them, or --force. It never reloads a stale
# snapshot quietly, and it never edits the tree to make itself runnable.
#
# FAILS CLOSED, UNLIKE A HOOK. A hook that cannot decide exits 0, because it fires on every
# tool call in every repo. This script fires when a person asks for it, and being unable to
# read the tree means being unable to prove the reload is safe — so it stops and says which
# check it could not run. Every such path goes through cannot_check(): a missing
# known_marketplaces.json, a marketplace name it does not hold, no python, a source directory
# that is not a git work tree, and a `git status` that fails on one that is. --force is the
# answer to every one of them, and "this plugin ships no local tree at all" is the one case
# that is an answer rather than a failure to get one.
#
# WHICH TREE IT CHECKS. The marketplace's own installLocation, read from
# ~/.claude/plugins/known_marketplaces.json — not the current directory. `calyx-engineering` is
# a directory source pointing at R:\arc, so a reload run from a worktree still installs from
# the main tree, and checking $PWD would clear a tree the reload is not going to read.
# ARC_PLUGIN_SOURCE_DIR overrides the lookup; the cases below are its only user.
#
# REPORTS, NEVER BLOCKS beyond its own exit code. 1 dirty, 2 usage, 3 cannot check.

set -u

# WHAT COUNTS — an exclusion list, not an inclusion list. The install copies the whole
# directory, so everything here reaches the cache; the question is only which of it the
# installed plugin then reads. An inclusion list would leave a new top-level directory silently
# uncovered, which is #68's lesson in verify-all.sh: the check whose job is catching a gap
# reports success instead. So each entry below is a path proven inert, with its reason.
#
#   docs/              the repository's own record. Nothing at runtime opens it
#   evals/             corpus and fixtures. tools/ reads them from the repository, never the cache
#   .claude/           this repository's OWN Claude configuration, including the arc's activation
#                      log. record-route appends to it most sessions, so leaving it in would
#                      refuse nearly every reload over bookkeeping the plugin never reads
#   .vscode/           editor settings
#   .gitignore  ·  .gitattributes  ·  .markdownlint.json   git and lint configuration
#   README.md          prose about the repository
#   ROADMAP.md         the same, and #175 may retire it outright
#   CLAUDE.md          instructions for sessions working ON this repo. Not loaded from an install
#
# The list is exhaustive against this repository's tracked top level as of 2026-09-09, checked
# by `git ls-files | awk -F/ '{print $1}' | sort -u`. A NEW top-level path is covered until
# someone adds it here with a reason, which is the direction that fails safe.
#
# tools/ IS NOT INERT, and #211's "Survived" column reads as though it were. That column named
# one file, `tools/verify-all.sh`, which nothing loads — but three of its siblings are executed
# by a live hook: hooks/tracker-verify resolves ../tools/verify-tracker-body.sh,
# ../tools/verify-linked-branch.sh and ../tools/verify-issue-boxes.sh against the plugin root,
# which is the cache. An uncommitted verifier is copied there and then run on every issue write.
# reference/ is not inert either: skills/record-route and skills/engineering-report both link
# ../../reference/knowledge-tiers.md, so an edit there changes what two installed skills teach.
# Generalising from one inert file to its whole directory is the mistake this comment exists to
# stop being repeated.
INERT_PATHS="docs evals .claude .vscode .gitignore .gitattributes .markdownlint.json
             README.md ROADMAP.md CLAUDE.md"

# True when an uncommitted change at this path would reach the installed plugin as something
# it reads. Ignored files are the one shipped-but-unnamed case — see dirty_component_paths.
affects_installed_plugin() {
  local p="$1" inert
  for inert in $INERT_PATHS; do
    case "$p" in "$inert"|"$inert"/*) return 1 ;; esac
  done
  return 0
}

# Every uncommitted change at a path the installed plugin reads, one "XY<TAB>path" line each.
#
#   0   the output is the answer; empty means clean
#   2   the directory is not a git work tree
#   3   it is one, but its state could not be read
#
# 2 AND 3 ARE NOT 0. `git status` can fail on a repository that exists: a corrupt index, an I/O
# error, a permissions problem. (Not a held .git/index.lock — status takes that lock with the
# non-fatal flag, skips refreshing the index and still exits 0. Tested; an earlier draft of this
# comment asserted otherwise.) Reading an empty result as a clean tree is the fail-open this
# script's header promises it will not do, so the failure is carried out as its own code rather
# than swallowed by the pipeline, and git's own message is left on stderr where the user sees
# which check could not run.
#
# WHAT IT STILL CANNOT SEE. Ignored files. `--untracked-files=all` does not list them and
# `--ignored` would name every __pycache__ on every run, so an ignored file inside skills/ or
# hooks/ is copied into the cache without being named here. That is the one gap in "the
# installed plugin equals a commit", and it is a deliberate trade against a guard nobody could
# use. A path containing a newline is the other: it is listed and counted as two.
dirty_component_paths() {
  local dir="$1" entry xy path src status_file err_file
  git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 2

  # A file rather than a process substitution: the exit status of the substitution is
  # unreadable, and command substitution would drop the NUL separators the -z format is for.
  status_file="$(mktemp -t plugin-reload-status.XXXXXX)" || return 3
  err_file="$(mktemp -t plugin-reload-stderr.XXXXXX)" || { rm -f "$status_file"; return 3; }
  # git's stderr is held rather than discarded, and replayed only if the command fails: on
  # success it is CRLF advice nobody asked for, and on failure it is the only thing that
  # distinguishes a corrupt index from a permissions problem.
  if ! git -C "$dir" status --porcelain=v1 -z --untracked-files=all \
         >"$status_file" 2>"$err_file"; then
    sed 's/^/          git: /' "$err_file" >&2
    rm -f "$status_file" "$err_file"
    return 3
  fi
  rm -f "$err_file"

  while IFS= read -r -d '' entry; do
    xy="${entry:0:2}"
    path="${entry:3}"
    src=""
    # -z renames and copies emit the destination first, then the source as its own record. R and
    # C appear in EITHER column — ` R` is a worktree rename, which `git add -N` makes reachable —
    # so the match cannot be anchored to the first one.
    case "$xy" in *R*|*C*) IFS= read -r -d '' src || true ;; esac
    if affects_installed_plugin "$path"; then
      printf '%s\t%s\n' "$xy" "$path"
    elif [ -n "$src" ] && affects_installed_plugin "$src"; then
      # A rename OUT of a loaded directory into an inert one. The destination is inert, but the
      # source's disappearance is what ships — `git mv skills/x/SKILL.md docs/x.md` removes a
      # skill from the installed plugin while naming nothing.
      printf '%s\t%s\n' "$xy" "$src"
    fi
  done < "$status_file"

  rm -f "$status_file"
  return 0
}

# The directory a marketplace installs from.
#
#   0   the printed path — a directory source
#   3   read, and it is definitively not a directory source: nothing local is shipped
#   4   could not be read at all — no known_marketplaces.json, no python, unparseable JSON,
#       or no entry under that name
#
# 3 AND 4 ARE DIFFERENT ANSWERS. "This plugin ships no working tree" and "I could not find out"
# lead to opposite actions, and collapsing them is how a guard turns into a reassuring message
# in front of an unchecked reload. Same distinction tools/verify-linked-branch.sh draws.
#
# ARC_KNOWN_MARKETPLACES overrides the file, so the cases below can drive all three answers.
marketplace_source_dir() {
  local mkt="${1##*@}"
  local kj="${ARC_KNOWN_MARKETPLACES:-${HOME}/.claude/plugins/known_marketplaces.json}"
  [ -f "$kj" ] || return 4
  local out rc
  out="$(python - "$kj" "$mkt" 2>/dev/null <<'PY'
import json, sys
try:
    entries = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    sys.exit(4)
entry = entries.get(sys.argv[2])
if not isinstance(entry, dict):
    sys.exit(4)
source = entry.get("source") or {}
if source.get("source") != "directory":
    sys.exit(3)
location = entry.get("installLocation") or source.get("path")
if not location:
    sys.exit(4)
print(location)
PY
)"
  rc=$?
  # python missing entirely exits 127 through the subshell; that is "could not be read".
  case "$rc" in
    0) [ -n "$out" ] || return 4; printf '%s\n' "$out"; return 0 ;;
    3) return 3 ;;
    *) return 4 ;;
  esac
}

# The whole leading comment block, however long it grows. A fixed line range silently
# truncates its own help the first time a paragraph is added above it.
usage() { awk 'NR>1 && /^#/ {print; next} NR>1 {exit}' "$0"; }

reload() {
  local plugin="$1"
  echo "Reloading ${plugin} from the working tree..."
  claude plugin uninstall "${plugin}" --keep-data >/dev/null || return $?
  claude plugin install   "${plugin}" -y          >/dev/null || return $?
  echo "Done. Restart any running Claude Code session to pick it up."
}

# The refusal, and the forced reload's warning, share one listing — the files are the point of
# both. Everything goes to stderr: a refusal that scrolls past on stdout is a refusal nobody read.
name_the_files() {
  local dirty="$1" xy path
  printf '%s\n' "$dirty" | while IFS=$'\t' read -r xy path; do
    printf '  %-2s  %s\n' "$xy" "$path"
  done
}

# Every path that cannot establish whether the tree is clean ends here, so they cannot drift
# apart: one message shape, exit 3, and --force as the way through. Returns the exit code the
# caller should use rather than exiting itself, so the whole decision stays inside main.
cannot_check() {
  local plugin="$1" force="$2" why="$3"
  if [ "$force" = "1" ]; then
    echo "WARNING  ${why} — reloading unchecked, because --force." >&2
    reload "$plugin"
    return $?
  fi
  echo "REFUSED — ${why}, so uncommitted work cannot be ruled out." >&2
  echo "          Reload ${plugin} anyway with --force." >&2
  return 3
}

main() {
  local force=0 plugin="" a
  for a in "$@"; do
    case "$a" in
      --force) force=1 ;;
      -h|--help) usage; exit 0 ;;
      -*) echo "unknown option: $a" >&2; echo "try: tools/plugin-reload.sh --help" >&2; exit 2 ;;
      *@*) [ -z "$plugin" ] || { echo "two plugins named: $plugin and $a" >&2; exit 2; }
           plugin="$a" ;;
      *) echo "not a plugin@marketplace: $a" >&2; exit 2 ;;
    esac
  done
  [ -n "$plugin" ] || plugin="arc@calyx-engineering"

  local src dirty status count why
  if [ -n "${ARC_PLUGIN_SOURCE_DIR:-}" ]; then
    src="$ARC_PLUGIN_SOURCE_DIR"
  else
    src="$(marketplace_source_dir "$plugin")"
    case "$?" in
      # Read, and it ships no local tree: the reload fetches its own copy, so there is
      # nothing here to protect.
      3) echo "${plugin} does not install from a local directory — no working tree is shipped." >&2
         reload "$plugin"
         exit $? ;;
      # Could not be read. Not the same answer, and not a reason to reload unchecked.
      4) cannot_check "$plugin" "$force" \
           "the marketplace ${plugin##*@} could not be read from ${ARC_KNOWN_MARKETPLACES:-\$HOME/.claude/plugins/known_marketplaces.json}"
         exit $? ;;
    esac
  fi

  dirty="$(dirty_component_paths "$src")"
  status=$?

  if [ "$status" = "2" ] || [ "$status" = "3" ]; then
    if [ "$status" = "2" ]; then why="${src} is not a git work tree"
    else why="git could not read the state of ${src}"; fi
    cannot_check "$plugin" "$force" "$why"
    exit $?
  fi

  if [ -n "$dirty" ]; then
    count="$(printf '%s\n' "$dirty" | wc -l | tr -d ' ')"
    if [ "$force" = "1" ]; then
      {
        echo "FORCED — ${count} uncommitted change(s) will be installed from ${src}:"
        name_the_files "$dirty"
        echo
      } >&2
      reload "$plugin"
      exit $?
    fi
    {
      echo "REFUSED — ${count} uncommitted change(s) in the plugin's own component directories."
      echo
      echo "  tree  ${src}"
      name_the_files "$dirty"
      echo
      echo "A reload copies this tree into the plugin cache, so these files would be installed in"
      echo "a state that exists in no commit — and the tree they came from is their only copy."
      echo
      echo "Commit them, or set them aside, then re-run. To reload them as they stand:"
      echo "  tools/plugin-reload.sh --force ${plugin}"
    } >&2
    exit 1
  fi

  reload "$plugin"
}

# ---------------------------------------------------------------------------------------
# The cases. Every one runs against a throwaway git repository, and the end-to-end half puts a
# recording stub on PATH in place of `claude` — so no case installs, uninstalls or reads a real
# plugin, and "ran no claude command" is checkable rather than assumed. #211.
# ---------------------------------------------------------------------------------------
PASS=0
FAIL=0

ok()  { PASS=$((PASS + 1)); echo "  PASS  $1"; }
bad() { FAIL=$((FAIL + 1)); echo "  FAIL  $1"; shift; printf '        %s\n' "$@"; }

check() { # name expected actual
  if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "expected: $2" "actual:   $3"; fi
}

# A committed tree with one file in every component directory and two outside them.
fixture_repo() {
  local d="$1"
  mkdir -p "$d/.claude-plugin" "$d/agents" "$d/commands" "$d/hooks" "$d/reference" \
           "$d/skills/camp" "$d/skills/chat-response" "$d/templates" \
           "$d/docs" "$d/evals" "$d/tools"
  echo '{"name":"f","version":"0.0.1"}' > "$d/.claude-plugin/plugin.json"
  echo a > "$d/agents/a.md"
  echo c > "$d/commands/c.md"
  echo h > "$d/hooks/h"
  echo k > "$d/reference/knowledge-tiers.md"
  mkdir -p "$d/.claude/arc" && echo l > "$d/.claude/arc/log.md"
  echo i > "$d/.gitignore"
  echo m > "$d/.markdownlint.json"
  echo s > "$d/skills/camp/SKILL.md"
  echo s > "$d/skills/chat-response/SKILL.md"
  echo t > "$d/templates/t.md"
  echo d > "$d/docs/d.md"
  echo e > "$d/evals/e.md"
  echo v > "$d/tools/verify-all.sh"
  echo v > "$d/tools/verify-tracker-body.sh"
  echo r > "$d/README.md"
  echo r > "$d/ROADMAP.md"
  echo c > "$d/CLAUDE.md"
  git -C "$d" init -q >/dev/null 2>&1
  git -C "$d" config core.autocrlf false >/dev/null 2>&1
  git -C "$d" add -A >/dev/null 2>&1
  git -C "$d" -c user.email=cases@arc -c user.name=cases commit -qm base >/dev/null 2>&1
}

tree_hashes() { (cd "$1" && find . -path ./.git -prune -o -type f -print0 | xargs -0 md5sum | sort -k2); }

# The cases' scratch directory is a global with a distinctive name, and it is cleaned by a
# function rather than by an expansion inside the trap string. An EXIT trap runs after the
# function that set it has returned, so a `local` name is out of scope by then and the trap
# expands whatever else holds that name — and on Windows `TMP` is already an environment
# variable pointing at %TEMP%, which is how `rm -rf "$TMP"` came to be aimed at the user's
# entire temp directory. Tested 2026-09-09, #211: the name is unique, the value is checked
# non-empty, and it must match the pattern mktemp was asked for before anything is removed.
CASES_DIR=""

cases_cleanup() {
  [ -n "${CASES_DIR:-}" ] || return 0
  [ -d "$CASES_DIR" ] || return 0
  case "$CASES_DIR" in
    */plugin-reload-cases.??????*) rm -rf "$CASES_DIR" ;;
    *) echo "refusing to remove an unexpected scratch directory: $CASES_DIR" >&2 ;;
  esac
}

selftest() {
  CASES_DIR="$(mktemp -d -t plugin-reload-cases.XXXXXX)" || CASES_DIR=""
  if [ -z "$CASES_DIR" ] || [ ! -d "$CASES_DIR" ]; then
    echo "  FAIL  could not create a scratch directory — no case ran" >&2
    return 1
  fi
  trap cases_cleanup EXIT
  # NOT `TMP`. On Windows that name is already an exported environment variable, and a `local`
  # shadowing an exported name is itself exported to every child — so the cases would run git,
  # python and their own nested bash with a rewritten temp directory. The trap was only half
  # the lesson; the name was the other half.
  local WORK="$CASES_DIR"

  echo "plugin-reload — the dirty-tree cases"
  echo

  local R out
  local TAB
  TAB="$(printf '\t')"

  # Empty output AND status 0. Asserting only the output would let a `return 3` with nothing
  # printed — the exact fail-open code 3 exists to prevent — pass as "clean".
  R="$WORK/u1"; fixture_repo "$R"
  out="$(dirty_component_paths "$R")"
  check "a clean tree is clean" "0|" "$?|$out"

  # tools/ is loaded: hooks/tracker-verify executes three of its scripts from the plugin root.
  # #211's "Survived" column named one inert file there and this is the correction.
  R="$WORK/u1b"; fixture_repo "$R"; echo x >> "$R/tools/verify-tracker-body.sh"
  check "an edited tool is named — hooks run them from the cache" \
        " M${TAB}tools/verify-tracker-body.sh" "$(dirty_component_paths "$R")"

  R="$WORK/u1c"; fixture_repo "$R"; echo x >> "$R/reference/knowledge-tiers.md"
  check "an edited reference is named — skills link into it" \
        " M${TAB}reference/knowledge-tiers.md" "$(dirty_component_paths "$R")"

  R="$WORK/u2"; fixture_repo "$R"; echo x >> "$R/skills/chat-response/SKILL.md"
  check "a modified skill is named" " M${TAB}skills/chat-response/SKILL.md" \
        "$(dirty_component_paths "$R")"

  R="$WORK/u3"; fixture_repo "$R"; echo x > "$R/hooks/new-hook"
  check "an untracked hook is named" "??${TAB}hooks/new-hook" "$(dirty_component_paths "$R")"

  R="$WORK/u4"; fixture_repo "$R"
  echo '{"name":"f","version":"0.0.2"}' > "$R/.claude-plugin/plugin.json"
  git -C "$R" add .claude-plugin/plugin.json >/dev/null 2>&1
  check "a staged manifest is named" "M ${TAB}.claude-plugin/plugin.json" \
        "$(dirty_component_paths "$R")"

  R="$WORK/u5"; fixture_repo "$R"; rm -f "$R/agents/a.md"
  check "a deleted agent is named" " D${TAB}agents/a.md" "$(dirty_component_paths "$R")"

  # Every inert path, in every dirty shape at once — and the status, for the same reason as u1.
  # `.claude/arc/log.md` is the one that matters in practice: record-route appends to it most
  # sessions, so a guard that named it would refuse nearly every reload in this repository.
  R="$WORK/u6"; fixture_repo "$R"
  echo x >> "$R/docs/d.md"; echo x >> "$R/README.md"; echo x >> "$R/ROADMAP.md"
  echo x >> "$R/CLAUDE.md"; echo x >> "$R/evals/e.md"; echo x >> "$R/.claude/arc/log.md"
  echo x >> "$R/.gitignore"; echo x >> "$R/.markdownlint.json"
  echo x > "$R/docs/untracked.txt"; echo x > "$R/evals/untracked.txt"
  echo x > "$R/.claude/arc/untracked.md"
  out="$(dirty_component_paths "$R")"
  check "an inert path is not named" "0|" "$?|$out"

  R="$WORK/u7"; fixture_repo "$R"
  echo x >> "$R/commands/c.md"; echo x >> "$R/templates/t.md"
  check "every component directory counts" " M${TAB}commands/c.md
 M${TAB}templates/t.md" "$(dirty_component_paths "$R")"

  R="$WORK/u8"; fixture_repo "$R"
  git -C "$R" mv skills/camp/SKILL.md skills/camp/RENAMED.md >/dev/null 2>&1
  out="$(dirty_component_paths "$R")"
  if [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = "1" ] &&
     printf '%s' "$out" | grep -q 'skills/camp/RENAMED.md'; then
    ok "a rename is one line, naming the destination"
  else
    bad "a rename is one line, naming the destination" "actual: $out"
  fi

  R="$WORK/u9"; fixture_repo "$R"
  mkdir -p "$R/skills/new/sub"; echo x > "$R/skills/new/sub/SKILL.md"
  check "an untracked nested file is named, not its directory" "??${TAB}skills/new/sub/SKILL.md" \
        "$(dirty_component_paths "$R")"

  # ` R` rather than `R `: a rename git detects in the WORK TREE, which `git add -N` makes
  # reachable. A match anchored to the first status column reads the source record as a fresh
  # entry and prints a status made of path characters.
  R="$WORK/u8b"; fixture_repo "$R"
  mv "$R/skills/camp/SKILL.md" "$R/skills/camp/MOVED.md"
  git -C "$R" add -N skills/camp/MOVED.md >/dev/null 2>&1
  out="$(dirty_component_paths "$R")"
  if [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = "1" ] &&
     printf '%s' "$out" | grep -q 'skills/camp/MOVED.md'; then
    ok "a worktree rename is one line too"
  else
    bad "a worktree rename is one line too" "actual: $out"
  fi

  # A rename OUT of a loaded directory into an inert one. The destination is inert, so naming
  # only the destination names nothing — while the installed plugin loses a skill.
  R="$WORK/u8c"; fixture_repo "$R"
  git -C "$R" mv skills/camp/SKILL.md docs/camp.md >/dev/null 2>&1
  out="$(dirty_component_paths "$R")"
  if printf '%s' "$out" | grep -q 'skills/camp/SKILL.md'; then
    ok "a rename out of a loaded directory names the source"
  else
    bad "a rename out of a loaded directory names the source" "actual: $out"
  fi

  R="$WORK/u9b"; fixture_repo "$R"; echo x > "$R/skills/camp/two words.md"
  check "a path with a space is named whole" "??${TAB}skills/camp/two words.md" \
        "$(dirty_component_paths "$R")"

  R="$WORK/u10"; mkdir -p "$R/skills"
  dirty_component_paths "$R" >/dev/null 2>&1
  check "a non-repository is reported, never called clean" "2" "$?"

  # A repository whose index git cannot read. rev-parse still answers, so this is the path that
  # would otherwise come back as an empty status and be read as clean.
  R="$WORK/u11"; fixture_repo "$R"; printf 'not an index' > "$R/.git/index"
  dirty_component_paths "$R" >/dev/null 2>&1
  check "an unreadable git state is reported, never called clean" "3" "$?"

  # ---- the three answers marketplace_source_dir has to keep apart ----
  local MK="$WORK/known_marketplaces.json"
  cat > "$MK" <<'JSON'
{
  "dir-source":  {"source": {"source": "directory", "path": "X"}, "installLocation": "/tmp/here"},
  "git-source":  {"source": {"source": "github", "repo": "o/r"}}
}
JSON
  out="$(ARC_KNOWN_MARKETPLACES="$MK" marketplace_source_dir "p@dir-source")"
  check "a directory source returns its installLocation" "/tmp/here" "$out"

  ARC_KNOWN_MARKETPLACES="$MK" marketplace_source_dir "p@git-source" >/dev/null 2>&1
  check "a non-directory source is answer 3, not a failure" "3" "$?"

  ARC_KNOWN_MARKETPLACES="$MK" marketplace_source_dir "p@absent" >/dev/null 2>&1
  check "a marketplace it does not hold is answer 4" "4" "$?"

  ARC_KNOWN_MARKETPLACES="$WORK/no-such-file.json" marketplace_source_dir "p@dir-source" \
    >/dev/null 2>&1
  check "a missing marketplaces file is answer 4" "4" "$?"

  printf 'not json' > "$WORK/broken.json"
  ARC_KNOWN_MARKETPLACES="$WORK/broken.json" marketplace_source_dir "p@dir-source" \
    >/dev/null 2>&1
  check "unparseable JSON is answer 4" "4" "$?"

  # ---- the script end to end, against a stub that records instead of installing ----
  mkdir -p "$WORK/bin"
  {
    echo '#!/usr/bin/env bash'
    echo 'printf "%s\n" "$*" >> "$CLAUDE_CALL_LOG"'
  } > "$WORK/bin/claude"
  chmod +x "$WORK/bin/claude"

  local SELF code before after
  SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

  run_case() { # repo [args...] — exit code returned, calls in calls.log, output in out.txt
    local repo="$1"; shift
    : > "$WORK/calls.log"
    CLAUDE_CALL_LOG="$WORK/calls.log" ARC_PLUGIN_SOURCE_DIR="$repo" PATH="$WORK/bin:$PATH" \
      bash "$SELF" "$@" > "$WORK/out.txt" 2>&1
  }

  local CYCLE="plugin uninstall f@m --keep-data
plugin install f@m -y"

  R="$WORK/e1"; fixture_repo "$R"; echo x >> "$R/skills/chat-response/SKILL.md"
  before="$(tree_hashes "$R")"
  run_case "$R" f@m; code=$?
  after="$(tree_hashes "$R")"
  check "a dirty component directory exits non-zero" "1" "$code"
  check "a dirty refusal runs no claude command" "" "$(cat "$WORK/calls.log")"
  check "a dirty refusal leaves the tree byte-identical" "$before" "$after"
  if grep -q 'skills/chat-response/SKILL.md' "$WORK/out.txt"; then
    ok "the refusal names the file at risk"
  else
    bad "the refusal names the file at risk" "output: $(tr '\n' '|' < "$WORK/out.txt")"
  fi

  R="$WORK/e2"; fixture_repo "$R"
  run_case "$R" f@m; code=$?
  check "a clean tree reloads" "0" "$code"
  check "a clean tree runs uninstall then install" "$CYCLE" "$(cat "$WORK/calls.log")"

  R="$WORK/e3"; fixture_repo "$R"; echo x >> "$R/hooks/h"
  run_case "$R" --force f@m; code=$?
  check "--force reloads a dirty tree" "0" "$code"
  check "--force still runs the cycle" "$CYCLE" "$(cat "$WORK/calls.log")"
  if grep -q 'hooks/h' "$WORK/out.txt"; then
    ok "--force still names the files"
  else
    bad "--force still names the files" "output: $(tr '\n' '|' < "$WORK/out.txt")"
  fi

  R="$WORK/e4"; fixture_repo "$R"
  run_case "$R" --nonsense; code=$?
  check "an unknown option is a usage error" "2" "$code"
  check "an unknown option runs no claude command" "" "$(cat "$WORK/calls.log")"

  # e5 and e6 both exit 3, so the exit code alone cannot tell them apart — and a regression in
  # which rev-parse started failing on a corrupt index would make e6 silently retest e5. Each
  # asserts the sentence that identifies its own path.
  R="$WORK/e5"; mkdir -p "$R/skills"
  run_case "$R" f@m; code=$?
  check "a source that is not a repository refuses" "3" "$code"
  check "that refusal runs no claude command" "" "$(cat "$WORK/calls.log")"
  if grep -q 'is not a git work tree' "$WORK/out.txt"; then
    ok "and says which check it could not run"
  else
    bad "and says which check it could not run" "output: $(tr '\n' '|' < "$WORK/out.txt")"
  fi

  R="$WORK/e6"; fixture_repo "$R"; printf 'not an index' > "$R/.git/index"
  run_case "$R" f@m; code=$?
  check "a source git cannot read refuses" "3" "$code"
  check "that refusal runs no claude command too" "" "$(cat "$WORK/calls.log")"
  if grep -q 'git could not read the state of' "$WORK/out.txt"; then
    ok "and names a different check from e5's"
  else
    bad "and names a different check from e5's" "output: $(tr '\n' '|' < "$WORK/out.txt")"
  fi

  R="$WORK/e7"; fixture_repo "$R"; printf 'not an index' > "$R/.git/index"
  run_case "$R" --force f@m; code=$?
  check "--force reloads what could not be checked" "0" "$code"
  check "--force still runs the cycle there" "$CYCLE" "$(cat "$WORK/calls.log")"

  # The marketplace path, with ARC_PLUGIN_SOURCE_DIR out of the way — an unreadable
  # known_marketplaces.json must refuse, not reload with a reassuring message.
  : > "$WORK/calls.log"
  CLAUDE_CALL_LOG="$WORK/calls.log" ARC_KNOWN_MARKETPLACES="$WORK/broken.json" \
    PATH="$WORK/bin:$PATH" bash "$SELF" f@m > "$WORK/out.txt" 2>&1
  code=$?
  check "an unreadable marketplace file refuses" "3" "$code"
  check "it runs no claude command" "" "$(cat "$WORK/calls.log")"

  # cannot_check has two callers. e7 proved the --force composition for the git one; this is
  # the marketplace one, and an untested branch of a shared function is an untested function.
  : > "$WORK/calls.log"
  CLAUDE_CALL_LOG="$WORK/calls.log" ARC_KNOWN_MARKETPLACES="$WORK/broken.json" \
    PATH="$WORK/bin:$PATH" bash "$SELF" --force f@m > "$WORK/out.txt" 2>&1
  code=$?
  check "--force gets past an unreadable marketplace file" "0" "$code"
  check "and runs the cycle there" "$CYCLE" "$(cat "$WORK/calls.log")"

  # …and a marketplace that genuinely ships no local tree reloads, because that is an answer.
  : > "$WORK/calls.log"
  CLAUDE_CALL_LOG="$WORK/calls.log" ARC_KNOWN_MARKETPLACES="$MK" \
    PATH="$WORK/bin:$PATH" bash "$SELF" f@git-source > "$WORK/out.txt" 2>&1
  code=$?
  check "a marketplace shipping no local tree reloads" "0" "$code"
  check "that reload runs the cycle" "plugin uninstall f@git-source --keep-data
plugin install f@git-source -y" "$(cat "$WORK/calls.log")"

  echo
  if [ "$FAIL" = "0" ]; then
    echo "$PASS passed"
    return 0
  fi
  echo "$((PASS + FAIL)) cases, $FAIL failed"
  return 1
}

case "${1:-}" in
  selftest) selftest; exit $? ;;
  *) main "$@" ;;
esac
