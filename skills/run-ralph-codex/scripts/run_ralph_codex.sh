#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$SKILL_DIR/assets/ralph-template"

find_target_root() {
  if [ -n "${TARGET_REPO:-}" ]; then
    echo "$TARGET_REPO"
    return 0
  fi

  if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    echo "$git_root"
  else
    echo "$PWD"
  fi
}

ensure_runtime_file() {
  local source_file="$1"
  local target_file="$2"
  local label="$3"

  if [ -f "$target_file" ]; then
    echo "Reusing existing $label: $target_file"
    return 0
  fi

  mkdir -p "$(dirname "$target_file")"
  cp "$source_file" "$target_file"
  echo "Injected $label: $target_file"
}

MODE="single"
ITERATIONS="1"
TARGET_REPO=""
INIT_GIT="false"
MODEL=""
REASONING_EFFORT=""

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'EOF'
Usage:
  ./skills/run-ralph-codex/scripts/run_ralph_codex.sh [iterations]
  ./skills/run-ralph-codex/scripts/run_ralph_codex.sh --all
  ./skills/run-ralph-codex/scripts/run_ralph_codex.sh --repo /path/to/repo [iterations|--all]
  ./skills/run-ralph-codex/scripts/run_ralph_codex.sh --init-git [iterations|--all]
  ./skills/run-ralph-codex/scripts/run_ralph_codex.sh --model gpt-5.4 --reasoning-effort high --all

Options:
  [iterations]       Run a fixed number of Ralph iterations
  --all              Use the current number of pending stories as the iteration cap
  --repo <path>      Use an existing Git repository at the given path
  --init-git         Initialize Git in the target directory before running
  --model <model>    Pass an explicit model to codex exec
  --reasoning-effort <level>
                     Pass an explicit reasoning effort (low|medium|high|xhigh)
EOF
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --all)
      MODE="all"
      shift
      ;;
    --init-git)
      INIT_GIT="true"
      shift
      ;;
    --repo)
      if [ $# -lt 2 ]; then
        echo "Error: --repo requires a path argument" >&2
        exit 1
      fi
      TARGET_REPO="$2"
      shift 2
      ;;
    --model)
      if [ $# -lt 2 ]; then
        echo "Error: --model requires a model name" >&2
        exit 1
      fi
      MODEL="$2"
      shift 2
      ;;
    --reasoning-effort)
      if [ $# -lt 2 ]; then
        echo "Error: --reasoning-effort requires a value" >&2
        exit 1
      fi
      REASONING_EFFORT="$2"
      shift 2
      ;;
    *)
      ITERATIONS="$1"
      if ! [[ "$ITERATIONS" =~ ^[0-9]+$ ]]; then
        echo "Error: iteration count must be a positive integer, or use --all / --repo / --init-git / --model / --reasoning-effort. Got: $ITERATIONS" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -n "$REASONING_EFFORT" ]; then
  case "$REASONING_EFFORT" in
    low|medium|high|xhigh)
      ;;
    *)
      echo "Error: --reasoning-effort must be one of: low, medium, high, xhigh" >&2
      exit 1
      ;;
  esac
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to inspect prd.json before running Ralph" >&2
  exit 1
fi

ROOT="$(find_target_root)"

if [ ! -d "$ROOT" ]; then
  echo "Error: target path does not exist: $ROOT" >&2
  exit 1
fi

cd "$ROOT"

ensure_runtime_file "$TEMPLATE_DIR/ralph.sh" "$ROOT/ralph.sh" "Ralph runner"
ensure_runtime_file "$TEMPLATE_DIR/CODEX.md" "$ROOT/CODEX.md" "Codex prompt"
chmod +x "$ROOT/ralph.sh"
mkdir -p tmp/ralph

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  if [ "$INIT_GIT" = "true" ]; then
    echo "Initializing Git repository in: $ROOT"
    if git init -b main >/dev/null 2>&1; then
      :
    else
      git init >/dev/null
      if git symbolic-ref HEAD >/dev/null 2>&1; then
        git branch -M main >/dev/null 2>&1 || true
      fi
    fi
  else
    RERUN_ARGS="1"
    if [ "$MODE" = "all" ]; then
      RERUN_ARGS="--all"
    elif [ "$ITERATIONS" != "1" ]; then
      RERUN_ARGS="$ITERATIONS"
    fi

    EXTRA_ARGS=()
    if [ -n "$MODEL" ]; then
      EXTRA_ARGS+=( --model "$MODEL" )
    fi
    if [ -n "$REASONING_EFFORT" ]; then
      EXTRA_ARGS+=( --reasoning-effort "$REASONING_EFFORT" )
    fi

    cat <<EOF
Error: target directory is not a Git repository: $ROOT

Ralph depends on Git for branches, commits, and iteration history.

Choose one of the following, then run this skill again:
1. Initialize Git in the current directory:
   ./skills/run-ralph-codex/scripts/run_ralph_codex.sh --init-git ${EXTRA_ARGS[*]} $RERUN_ARGS
2. Point to an existing Git repository:
   ./skills/run-ralph-codex/scripts/run_ralph_codex.sh --repo /path/to/existing/repo ${EXTRA_ARGS[*]} $RERUN_ARGS
3. Pause here and switch to the correct project directory first.
EOF
    exit 1
  fi
fi

if [ ! -f prd.json ]; then
  cat <<'EOF'
Error: prd.json is missing in the target project.

Run the first two Ralph skills before this one:
1. Use `prd` to generate a markdown PRD
2. Use `ralph` to convert that PRD into prd.json
EOF
  exit 1
fi

jq . prd.json >/dev/null

PENDING_COUNT="$(jq '[.userStories[] | select(.passes == false)] | length' prd.json)"
if [ "$PENDING_COUNT" -eq 0 ]; then
  echo "All stories already pass in $ROOT/prd.json; nothing to run."
  exit 0
fi

if [ "$MODE" = "all" ]; then
  ITERATIONS="$PENDING_COUNT"
fi

echo "Running Ralph with Codex in: $ROOT"
echo "Pending stories: $PENDING_COUNT"
if [ "$MODE" = "all" ]; then
  echo "Mode: --all (iteration cap set to pending story count: $ITERATIONS)"
else
  echo "Mode: fixed iterations = $ITERATIONS"
fi
if [ -n "$MODEL" ]; then
  echo "Model override: $MODEL"
fi
if [ -n "$REASONING_EFFORT" ]; then
  echo "Reasoning effort override: $REASONING_EFFORT"
fi
jq -r '.userStories[] | select(.passes == false) | "- \(.id): \(.title)"' prd.json

CMD=( ./ralph.sh --tool codex )
if [ -n "$MODEL" ]; then
  CMD+=( --model "$MODEL" )
fi
if [ -n "$REASONING_EFFORT" ]; then
  CMD+=( --reasoning-effort "$REASONING_EFFORT" )
fi
CMD+=( "$ITERATIONS" )

exec "${CMD[@]}"
