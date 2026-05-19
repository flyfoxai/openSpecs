#!/usr/bin/env bash

# Consolidated prerequisite checking script
#
# The default mode is deliberately non-blocking: it resolves and reports routing
# context without requiring plan.md. Stage-specific commands opt into stricter
# checks with --require-spec / --require-bundle / --require-plan / --require-tasks.

set -e

JSON_MODE=false
REQUIRE_SPEC=false
REQUIRE_BUNDLE=false
REQUIRE_PLAN=false
REQUIRE_TASKS=false
INCLUDE_TASKS=false
PATHS_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --require-spec)
            REQUIRE_SPEC=true
            ;;
        --require-bundle)
            REQUIRE_BUNDLE=true
            ;;
        --require-plan)
            REQUIRE_PLAN=true
            ;;
        --require-tasks)
            REQUIRE_TASKS=true
            ;;
        --include-tasks)
            INCLUDE_TASKS=true
            ;;
        --paths-only)
            PATHS_ONLY=true
            ;;
        --help|-h)
            cat << 'EOF'
Usage: check-prerequisites.sh [OPTIONS]

Consolidated prerequisite checking for the SP document workflow.

OPTIONS:
  --json              Output in JSON format
  --require-spec      Require specs/<feature>/spec.md to exist
  --require-bundle    Require spec.md and bundle.md to exist
  --require-plan      Require spec.md, bundle.md, and plan.md to exist
  --require-tasks     Require plan.md and tasks.md to exist
  --include-tasks     Include tasks.md in AVAILABLE_DOCS when present
  --paths-only        Only output path variables
  --help, -h          Show this help message
EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

_paths_output=$(get_feature_paths) || { echo "ERROR: Failed to resolve feature paths" >&2; exit 1; }
eval "$_paths_output"
unset _paths_output

relative_to_repo() {
    local path="$1"
    if [[ "$path" == "$REPO_ROOT/"* ]]; then
        printf '%s\n' "${path#"$REPO_ROOT/"}"
    else
        printf '%s\n' "$path"
    fi
}

apply_feature_dir() {
    local dir="$1"
    [[ -n "$dir" ]] || return 0
    [[ "$dir" != /* ]] && dir="$REPO_ROOT/$dir"
    FEATURE_DIR="$dir"
    FEATURE_SPEC="$FEATURE_DIR/spec.md"
    IMPL_PLAN="$FEATURE_DIR/plan.md"
    TASKS="$FEATURE_DIR/tasks.md"
    RESEARCH="$FEATURE_DIR/research.md"
    DATA_MODEL="$FEATURE_DIR/data-model.md"
    QUICKSTART="$FEATURE_DIR/quickstart.md"
    CONTRACTS_DIR="$FEATURE_DIR/contracts"
}

find_feature_from_active_context() {
    local active_context="$REPO_ROOT/.specify/memory/active-context.md"
    [[ -f "$active_context" ]] || return 0
    sed -n 's#.*specs/\([^/]*\)/.*#\1#p' "$active_context" | head -n 1
}

find_single_feature_dir() {
    local specs_dir="$REPO_ROOT/specs"
    [[ -d "$specs_dir" ]] || return 0

    local matches count
    matches=$(find "$specs_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
    count=$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l | tr -d ' ')
    if [[ "$count" == "1" ]]; then
        printf '%s\n' "$matches" | sed '/^$/d'
    fi
}

# If branch-derived routing points to a missing feature, prefer persisted active
# project memory before reporting a gap. This keeps SP usable from main branches
# and from host sessions that do not expose a feature branch.
if [[ ! -d "$FEATURE_DIR" ]]; then
    active_feature=$(find_feature_from_active_context || true)
    if [[ -n "$active_feature" && -d "$REPO_ROOT/specs/$active_feature" ]]; then
        apply_feature_dir "$REPO_ROOT/specs/$active_feature"
    else
        single_feature_dir=$(find_single_feature_dir || true)
        if [[ -n "$single_feature_dir" ]]; then
            apply_feature_dir "$single_feature_dir"
        fi
    fi
fi

BUNDLE="$FEATURE_DIR/bundle.md"
PLAN="$IMPL_PLAN"
HAS_ACTIVE_FEATURE=false
if [[ -n "$FEATURE_DIR" && -d "$FEATURE_DIR" ]]; then
    HAS_ACTIVE_FEATURE=true
fi

missing=()
REQUIRE_ANY=false
if $REQUIRE_SPEC || $REQUIRE_BUNDLE || $REQUIRE_PLAN || $REQUIRE_TASKS; then
    REQUIRE_ANY=true
fi

require_file() {
    local label="$1"
    local path="$2"
    if [[ -z "$path" || ! -f "$path" ]]; then
        missing+=("$label")
    fi
}

if ! $HAS_ACTIVE_FEATURE && $REQUIRE_ANY; then
    missing+=("no_active_feature")
else
    if $REQUIRE_SPEC || $REQUIRE_BUNDLE || $REQUIRE_PLAN; then
        require_file "spec.md" "$FEATURE_SPEC"
    fi
    if $REQUIRE_BUNDLE || $REQUIRE_PLAN; then
        require_file "bundle.md" "$BUNDLE"
    fi
    if $REQUIRE_PLAN || $REQUIRE_TASKS; then
        require_file "plan.md" "$PLAN"
    fi
    if $REQUIRE_TASKS; then
        require_file "tasks.md" "$TASKS"
    fi
fi

docs=()
[[ -f "$FEATURE_SPEC" ]] && docs+=("spec.md")
[[ -f "$BUNDLE" ]] && docs+=("bundle.md")
[[ -f "$PLAN" ]] && docs+=("plan.md")
[[ -f "$RESEARCH" ]] && docs+=("research.md")
[[ -f "$DATA_MODEL" ]] && docs+=("data-model.md")
if [[ -d "$CONTRACTS_DIR" && -n "$(ls -A "$CONTRACTS_DIR" 2>/dev/null)" ]]; then
    docs+=("contracts/")
fi
[[ -f "$QUICKSTART" ]] && docs+=("quickstart.md")
if $INCLUDE_TASKS && [[ -f "$TASKS" ]]; then
    docs+=("tasks.md")
fi

json_array() {
    if [[ "$#" -eq 0 ]]; then
        printf '[]'
        return
    fi
    local first=true
    printf '['
    for item in "$@"; do
        if $first; then
            first=false
        else
            printf ','
        fi
        printf '"%s"' "$(json_escape "$item")"
    done
    printf ']'
}

FEATURE_DIR_REL=$(relative_to_repo "$FEATURE_DIR")
FEATURE_SPEC_REL=$(relative_to_repo "$FEATURE_SPEC")
BUNDLE_REL=$(relative_to_repo "$BUNDLE")
PLAN_REL=$(relative_to_repo "$PLAN")
TASKS_REL=$(relative_to_repo "$TASKS")
ACTIVE_FEATURE_NAME=""
OUTPUT_FEATURE_DIR="$FEATURE_DIR"
OUTPUT_FEATURE_SPEC="$FEATURE_SPEC"
OUTPUT_BUNDLE="$BUNDLE"
OUTPUT_PLAN="$PLAN"
OUTPUT_TASKS="$TASKS"
if $HAS_ACTIVE_FEATURE; then
    ACTIVE_FEATURE_NAME="$(basename "$FEATURE_DIR")"
else
    OUTPUT_FEATURE_DIR=""
    OUTPUT_FEATURE_SPEC=""
    OUTPUT_BUNDLE=""
    OUTPUT_PLAN=""
    OUTPUT_TASKS=""
    FEATURE_DIR_REL=""
    FEATURE_SPEC_REL=""
    BUNDLE_REL=""
    PLAN_REL=""
    TASKS_REL=""
fi

if $PATHS_ONLY; then
    if $JSON_MODE; then
        printf '{"REPO_ROOT":"%s","BRANCH":"%s","FEATURE_DIR":"%s","FEATURE_SPEC":"%s","BUNDLE":"%s","IMPL_PLAN":"%s","TASKS":"%s","hasActiveFeature":%s,"activeFeature":"%s","featureDir":"%s"}\n' \
            "$(json_escape "$REPO_ROOT")" "$(json_escape "$CURRENT_BRANCH")" "$(json_escape "$OUTPUT_FEATURE_DIR")" \
            "$(json_escape "$OUTPUT_FEATURE_SPEC")" "$(json_escape "$OUTPUT_BUNDLE")" "$(json_escape "$OUTPUT_PLAN")" "$(json_escape "$OUTPUT_TASKS")" \
            "$HAS_ACTIVE_FEATURE" "$(json_escape "$ACTIVE_FEATURE_NAME")" "$(json_escape "$FEATURE_DIR_REL")"
    else
        echo "REPO_ROOT: $REPO_ROOT"
        echo "BRANCH: $CURRENT_BRANCH"
        echo "FEATURE_DIR: $FEATURE_DIR"
        echo "FEATURE_SPEC: $FEATURE_SPEC"
        echo "BUNDLE: $BUNDLE"
        echo "IMPL_PLAN: $PLAN"
        echo "TASKS: $TASKS"
    fi
    exit 0
fi

if $JSON_MODE; then
    docs_json=$(json_array "${docs[@]}")
    missing_json=$(json_array "${missing[@]}")
    printf '{"FEATURE_DIR":"%s","FEATURE_SPEC":"%s","BUNDLE":"%s","IMPL_PLAN":"%s","TASKS":"%s","AVAILABLE_DOCS":%s,"MISSING":%s,"projectRoot":"%s","branch":"%s","hasActiveFeature":%s,"activeFeature":"%s","featureDir":"%s","specPath":"%s","bundlePath":"%s","planPath":"%s","tasksPath":"%s","missing":%s}\n' \
        "$(json_escape "$OUTPUT_FEATURE_DIR")" "$(json_escape "$OUTPUT_FEATURE_SPEC")" "$(json_escape "$OUTPUT_BUNDLE")" \
        "$(json_escape "$OUTPUT_PLAN")" "$(json_escape "$OUTPUT_TASKS")" "$docs_json" "$missing_json" \
        "$(json_escape "$REPO_ROOT")" "$(json_escape "$CURRENT_BRANCH")" "$HAS_ACTIVE_FEATURE" \
        "$(json_escape "$ACTIVE_FEATURE_NAME")" "$(json_escape "$FEATURE_DIR_REL")" \
        "$(json_escape "$FEATURE_SPEC_REL")" "$(json_escape "$BUNDLE_REL")" "$(json_escape "$PLAN_REL")" \
        "$(json_escape "$TASKS_REL")" "$missing_json"
else
    echo "FEATURE_DIR:$FEATURE_DIR"
    echo "AVAILABLE_DOCS:"
    check_file "$FEATURE_SPEC" "spec.md"
    check_file "$BUNDLE" "bundle.md"
    check_file "$PLAN" "plan.md"
    check_file "$RESEARCH" "research.md"
    check_file "$DATA_MODEL" "data-model.md"
    check_dir "$CONTRACTS_DIR" "contracts/"
    check_file "$QUICKSTART" "quickstart.md"
    if $INCLUDE_TASKS; then
        check_file "$TASKS" "tasks.md"
    fi
fi

if [[ ${#missing[@]} -gt 0 ]]; then
    if [[ " ${missing[*]} " == *" no_active_feature "* ]]; then
        printf 'Missing required stage outputs: no_active_feature. No active feature was found; run sp.specify first (skills hosts: sp-specify).\n' >&2
    else
        printf 'Missing required stage outputs: %s\n' "$(IFS=', '; echo "${missing[*]}")" >&2
    fi
    exit 1
fi
