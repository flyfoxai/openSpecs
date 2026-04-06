#!/bin/sh

set -eu

SCRIPT_DIR=""
SOURCE_ROOT=""
SOURCE_MODE=""
ARCHIVE_URL="${SP_INSTALL_ARCHIVE_URL:-}"
TARGET_DIR="${SP_INSTALL_TARGET_DIR:-.}"
AUTO_YES="${SP_INSTALL_AUTO_YES:-0}"
AI_TARGET="${SP_INSTALL_AI:-}"
INSTALL_CODEX_SKILLS="${SP_INSTALL_AI_SKILLS:-0}"
DOWNLOAD_DIR=""
DETECTED_CODEX_HOME="${CODEX_HOME:-}"
RESOLVED_CODEX_HOME=""
RESOLVED_CODEX_SKILLS_DIR=""
INSTALLED_SKILLS=""
INSTALLED_SKILLS_JSON=""

cleanup() {
  if [ -n "$DOWNLOAD_DIR" ] && [ -d "$DOWNLOAD_DIR" ]; then
    rm -rf "$DOWNLOAD_DIR"
  fi
}

trap cleanup EXIT INT TERM

usage() {
  cat <<'EOF'
Usage:
  sh scripts/install.sh [target_dir]
  sh scripts/install.sh --yes [target_dir]
  sh scripts/install.sh --archive-url <tar.gz-url> [target_dir]
  sh scripts/install.sh --ai codex --ai-skills [target_dir]

Behavior:
  - If target_dir is omitted, install into the current directory.
  - Prompts for confirmation before writing files unless --yes is used.
  - macOS/Linux local mode copies assets from the current repository.
  - curl|sh mode requires --archive-url or SP_INSTALL_ARCHIVE_URL.
  - Remote mode can also use SP_INSTALL_TARGET_DIR and SP_INSTALL_AUTO_YES.
  - Codex skills install is enabled only with --ai codex --ai-skills.
EOF
}

is_yes_value() {
  case "${1:-}" in
    1|y|Y|yes|YES|true|TRUE)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

abs_path() {
  if [ "$1" = "." ]; then
    pwd
  else
    (
      cd "$1" 2>/dev/null && pwd
    )
  fi
}

codex_skill_slugs() {
  cat <<'EOF'
sp-constitution
sp-specify
sp-clarify
sp-flow
sp-ui
sp-gate
sp-bundle
sp-plan
sp-tasks
sp-analyze
EOF
}

download_archive() {
  if [ -z "$ARCHIVE_URL" ]; then
    echo "error: no local source found and no archive URL was provided." >&2
    echo "hint: use --archive-url <tar.gz-url> when running through curl|sh." >&2
    exit 1
  fi

  if command -v curl >/dev/null 2>&1; then
    :
  elif command -v wget >/dev/null 2>&1; then
    :
  else
    echo "error: curl or wget is required to download the install archive." >&2
    exit 1
  fi

  DOWNLOAD_DIR="$(mktemp -d)"
  ARCHIVE_PATH="$DOWNLOAD_DIR/sp-install.tar.gz"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"
  else
    wget -qO "$ARCHIVE_PATH" "$ARCHIVE_URL"
  fi

  tar -xzf "$ARCHIVE_PATH" -C "$DOWNLOAD_DIR"

  if [ -d "$DOWNLOAD_DIR/docs" ] && [ -d "$DOWNLOAD_DIR/installer-assets" ]; then
    SOURCE_ROOT="$DOWNLOAD_DIR"
    return
  fi

  for candidate in "$DOWNLOAD_DIR"/*; do
    if [ -d "$candidate/docs" ] && [ -d "$candidate/installer-assets" ]; then
      SOURCE_ROOT="$candidate"
      return
    fi
  done

  echo "error: downloaded archive does not contain the expected sp asset layout." >&2
  exit 1
}

count_existing_targets() {
  count=0
  for rel in \
    "docs" \
    "layer-1-business-clarification" \
    "layer-2-delivery" \
    ".specify/memory" \
    "specs" \
    ".sp/install-manifest.json" \
    "docs/sp-overview.zh-CN.md" \
    "docs/sp-overview-details.zh-CN.md" \
    "docs/sp-overview.en.md" \
    "docs/sp-overview-details.en.md"
  do
    if [ -e "$TARGET_ABS/$rel" ]; then
      count=$((count + 1))
    fi
  done
  echo "$count"
}

copy_tree() {
  src="$1"
  dest="$2"
  mkdir -p "$dest"
  cp -R "$src"/. "$dest"/
}

resolve_codex_paths() {
  if [ -n "${DETECTED_CODEX_HOME:-}" ]; then
    RESOLVED_CODEX_HOME="$DETECTED_CODEX_HOME"
  else
    if [ -z "${HOME:-}" ]; then
      echo "error: Codex skills installation failed: unable to resolve home directory for default ~/.codex fallback." >&2
      exit 1
    fi
    RESOLVED_CODEX_HOME="$HOME/.codex"
  fi

  RESOLVED_CODEX_SKILLS_DIR="$RESOLVED_CODEX_HOME/skills"

  if [ -z "$RESOLVED_CODEX_SKILLS_DIR" ]; then
    echo "error: Codex skills installation failed: resolved skills directory missing or empty." >&2
    exit 1
  fi
}

install_codex_skills() {
  if ! command -v codex >/dev/null 2>&1; then
    echo "error: Codex skills installation failed: 'codex' command not found in PATH." >&2
    exit 1
  fi

  resolve_codex_paths

  SKILL_SOURCE_ROOT="$SOURCE_ROOT/installer-assets/codex-skills"
  if [ ! -d "$SKILL_SOURCE_ROOT" ]; then
    echo "error: Codex skills installation failed: missing installer-assets/codex-skills in source." >&2
    exit 1
  fi

  if ! mkdir -p "$RESOLVED_CODEX_SKILLS_DIR"; then
    echo "error: Codex skills installation failed: resolved skills directory missing or unwritable: $RESOLVED_CODEX_SKILLS_DIR" >&2
    exit 1
  fi

  INSTALLED_SKILLS=""
  INSTALLED_SKILLS_JSON=""

  for slug in $(codex_skill_slugs); do
    src="$SKILL_SOURCE_ROOT/$slug"
    dest="$RESOLVED_CODEX_SKILLS_DIR/$slug"

    if [ ! -f "$src/SKILL.md" ]; then
      echo "error: Codex skills installation failed: missing source skill file for $slug" >&2
      exit 1
    fi

    copy_tree "$src" "$dest"

    if [ ! -f "$dest/SKILL.md" ]; then
      echo "error: Codex skills installation failed: failed to write $slug into $RESOLVED_CODEX_SKILLS_DIR" >&2
      exit 1
    fi

    if [ -n "$INSTALLED_SKILLS" ]; then
      INSTALLED_SKILLS="$INSTALLED_SKILLS
$slug"
      INSTALLED_SKILLS_JSON="$INSTALLED_SKILLS_JSON, \"$slug\""
    else
      INSTALLED_SKILLS="$slug"
      INSTALLED_SKILLS_JSON="\"$slug\""
    fi
  done

  if [ -z "$INSTALLED_SKILLS" ]; then
    echo "error: Codex skills installation failed: no sp-* skills were written to $RESOLVED_CODEX_SKILLS_DIR" >&2
    exit 1
  fi
}

write_install_manifest() {
  version="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$SOURCE_ROOT/package.json" | head -n 1)"
  if [ -z "$version" ]; then
    version="unknown"
  fi

  mkdir -p "$TARGET_ABS/.sp"

  {
    echo "{"
    echo "  \"name\": \"sp-document-workflow\","
    echo "  \"version\": \"$version\","
    echo "  \"installedAt\": \"$(date -u '+%Y-%m-%dT%H:%M:%SZ')\","
    echo "  \"sourceMode\": \"$SOURCE_MODE\","
    echo "  \"targetDir\": \"$TARGET_ABS\""
    if [ "$INSTALL_CODEX_SKILLS" -eq 1 ]; then
      echo "  ,\"ai\": \"codex\""
      echo "  ,\"detectedCodexHome\": \"${DETECTED_CODEX_HOME:-}\""
      echo "  ,\"codexHome\": \"$RESOLVED_CODEX_HOME\""
      echo "  ,\"codexSkillsDir\": \"$RESOLVED_CODEX_SKILLS_DIR\""
      echo "  ,\"installedSkills\": [$INSTALLED_SKILLS_JSON]"
    fi
    echo "}"
  } >"$TARGET_ABS/.sp/install-manifest.json"
}

confirm_install() {
  if [ "$AUTO_YES" -eq 1 ]; then
    return 0
  fi

  if ! { exec 3<>/dev/tty; } 2>/dev/null; then
    echo "error: interactive confirmation requires a terminal." >&2
    echo "hint: rerun with --yes (or SP_INSTALL_AUTO_YES=1) for non-interactive install." >&2
    exit 1
  fi

  cat <<EOF >&3
sp installer is about to write the document-stage starter pack.

Target directory:
  $TARGET_ABS

This will install or refresh:
  - docs/sp-*.md and overview docs
  - layer-1-business-clarification/
  - layer-2-delivery/
  - .specify/memory/
  - specs/
  - .sp/install-manifest.json
EOF

  if [ "$INSTALL_CODEX_SKILLS" -eq 1 ]; then
    cat <<EOF >&3
  - Codex skills: $(printf '%s' "$INSTALLED_SKILL_NAMES_PREVIEW")

Codex integration:
  detected CODEX_HOME: ${DETECTED_CODEX_HOME:-<empty>}
  resolved Codex home: $RESOLVED_CODEX_HOME
  resolved skills directory: $RESOLVED_CODEX_SKILLS_DIR
EOF
  fi

  cat <<EOF >&3

Managed paths that already exist:
  $EXISTING_COUNT

Unrelated files will not be deleted.
Continue? [y/N]:
EOF

  IFS= read -r answer <&3 || answer=""
  exec 3>&-
  exec 3<&-
  case "$answer" in
    y|Y|yes|YES)
      ;;
    *)
      echo "Installation cancelled." >&2
      exit 1
      ;;
  esac
}

if is_yes_value "$AUTO_YES"; then
  AUTO_YES=1
else
  AUTO_YES=0
fi

if is_yes_value "$INSTALL_CODEX_SKILLS"; then
  INSTALL_CODEX_SKILLS=1
else
  INSTALL_CODEX_SKILLS=0
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes|-y)
      AUTO_YES=1
      shift
      ;;
    --archive-url)
      if [ "$#" -lt 2 ]; then
        echo "error: --archive-url requires a value." >&2
        exit 1
      fi
      ARCHIVE_URL="$2"
      shift 2
      ;;
    --ai)
      if [ "$#" -lt 2 ]; then
        echo "error: --ai requires a value." >&2
        exit 1
      fi
      AI_TARGET="$2"
      shift 2
      ;;
    --ai-skills)
      INSTALL_CODEX_SKILLS=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

if [ -n "${0:-}" ]; then
  case "$0" in
    */*)
      SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
      ;;
  esac
fi

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/../docs" ] && [ -d "$SCRIPT_DIR/../installer-assets" ]; then
  SOURCE_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
  SOURCE_MODE="local"
else
  download_archive
  SOURCE_MODE="archive"
fi

if [ -n "$AI_TARGET" ] && [ "$AI_TARGET" != "codex" ]; then
  echo "error: this installer only supports Codex skills via --ai codex --ai-skills." >&2
  exit 1
fi

if [ "$AI_TARGET" = "codex" ] && [ "$INSTALL_CODEX_SKILLS" -ne 1 ]; then
  echo "error: Codex installation requires --ai-skills. Use --ai codex --ai-skills." >&2
  exit 1
fi

if [ "$INSTALL_CODEX_SKILLS" -eq 1 ] && [ "$AI_TARGET" != "codex" ]; then
  echo "error: --ai-skills currently requires --ai codex." >&2
  exit 1
fi

if [ "$INSTALL_CODEX_SKILLS" -eq 1 ]; then
  resolve_codex_paths
  INSTALLED_SKILL_NAMES_PREVIEW="$(printf '%s' "$(codex_skill_slugs)" | tr '\n' ' ' | sed 's/[[:space:]][[:space:]]*/ /g; s/[[:space:]]$//')"
fi

mkdir -p "$TARGET_DIR"
TARGET_ABS="$(abs_path "$TARGET_DIR")"
EXISTING_COUNT="$(count_existing_targets)"
confirm_install

copy_tree "$SOURCE_ROOT/docs" "$TARGET_ABS/docs"
copy_tree "$SOURCE_ROOT/installer-assets/project/docs" "$TARGET_ABS/docs"
copy_tree "$SOURCE_ROOT/layer-1-business-clarification" "$TARGET_ABS/layer-1-business-clarification"
copy_tree "$SOURCE_ROOT/layer-2-delivery" "$TARGET_ABS/layer-2-delivery"
copy_tree "$SOURCE_ROOT/installer-assets/project/.specify/memory" "$TARGET_ABS/.specify/memory"
mkdir -p "$TARGET_ABS/specs"

if [ "$INSTALL_CODEX_SKILLS" -eq 1 ]; then
  install_codex_skills
fi

write_install_manifest

echo "sp document-stage starter pack installed to:"
echo "  $TARGET_ABS"

if [ "$INSTALL_CODEX_SKILLS" -eq 1 ]; then
  echo
  echo "Codex integration:"
  echo "  detected CODEX_HOME: ${DETECTED_CODEX_HOME:-<empty>}"
  echo "  resolved Codex home: $RESOLVED_CODEX_HOME"
  echo "  resolved skills directory: $RESOLVED_CODEX_SKILLS_DIR"
  echo "  installed sp-* skills:"
  printf '%s\n' "$INSTALLED_SKILLS" | while IFS= read -r skill_name; do
    [ -n "$skill_name" ] || continue
    echo "    - $skill_name"
  done
  echo
  echo "Codex trigger examples:"
  echo "  \$sp-specify"
  echo "  \$sp-analyze"
  echo "  reload the Codex workspace if the new skills do not appear immediately"
else
  echo
  echo "Codex skills were not installed."
  echo "To install Codex skills as well, rerun with:"
  echo "  sh scripts/install.sh --ai codex --ai-skills ${TARGET_DIR}"
fi

echo
echo "Trigger conventions:"
echo "  - Codex skills use \$sp-*"
echo "  - slash-command agents use /sp.*"
echo
echo "Recommended next steps:"
echo "  1. Read docs/sp-overview.zh-CN.md or docs/sp-overview.en.md"
echo "  2. Review .specify/memory/constitution.md"
if [ "$INSTALL_CODEX_SKILLS" -eq 1 ]; then
  echo "  3. Reload Codex, then start with \$sp-specify"
else
  echo "  3. Start the workflow with sp.specify in your target agent"
fi
