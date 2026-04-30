#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="$DOTFILES_DIR/files"
MANIFEST="$DOTFILES_DIR/files.manifest"
HOME_DIR="${HOME:?HOME is not set}"

while IFS= read -r line; do
  [[ -z "$line" || "${line:0:1}" == "#" ]] && continue

  src_rel="${line%%=>*}"
  src_rel="$(echo "$src_rel" | xargs)"

  src_path="$HOME_DIR/$src_rel"
  dst_path="$FILES_DIR/$src_rel"

  if [[ ! -e "$src_path" ]]; then
    echo "skip (missing): $src_rel"
    continue
  fi

  mkdir -p "$(dirname "$dst_path")"
  rm -rf "$dst_path"
  cp -a "$src_path" "$dst_path"
  echo "synced: $src_rel"
done < "$MANIFEST"

echo "Sync complete -> $FILES_DIR"
