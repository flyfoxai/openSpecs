#!/bin/sh

set -eu

SCRIPT_DIR=""
SOURCE_ROOT=""
SOURCE_MODE=""
ARCHIVE_URL="${SP_INSTALL_ARCHIVE_URL:-}"
TARGET_DIR="${SP_INSTALL_TARGET_DIR:-.}"
AUTO_YES="${SP_INSTALL_AUTO_YES:-0}"
DOWNLOAD_DIR=""

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

Behavior:
  - If target_dir is omitted, install into the current directory.
  - Prompts for confirmation before writing files unless --yes is used.
  - macOS/Linux local mode copies assets from the current repository.
  - curl|sh mode requires --archive-url or SP_INSTALL_ARCHIVE_URL.
  - Remote mode can also use SP_INSTALL_TARGET_DIR and SP_INSTALL_AUTO_YES.
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

write_install_manifest() {
  version="$(sed -n 's/.*"version": "\(.*\)".*/\1/p' "$SOURCE_ROOT/package.json" | head -n 1)"
  if [ -z "$version" ]; then
    version="unknown"
  fi

  mkdir -p "$TARGET_ABS/.sp"
  cat >"$TARGET_ABS/.sp/install-manifest.json" <<EOF
{
  "name": "sp-document-workflow",
  "version": "$version",
  "installedAt": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "sourceMode": "$SOURCE_MODE",
  "targetDir": "$TARGET_ABS"
}
EOF
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
write_install_manifest

echo "sp document-stage starter pack installed to:"
echo "  $TARGET_ABS"
echo
echo "Recommended next steps:"
echo "  1. Read docs/sp-overview.zh-CN.md or docs/sp-overview.en.md"
echo "  2. Review .specify/memory/constitution.md"
echo "  3. Start your first feature with sp.specify"
