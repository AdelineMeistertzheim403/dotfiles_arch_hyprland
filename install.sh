#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="$DOTFILES_DIR/files"
MANIFEST="$DOTFILES_DIR/files.manifest"
HOME_DIR="${HOME:?HOME is not set}"
BACKUP_DIR="$HOME_DIR/.config/dotfiles-backup/$(date +%F_%H-%M-%S)"

mkdir -p "$BACKUP_DIR"

while IFS= read -r line; do
  [[ -z "$line" || "${line:0:1}" == "#" ]] && continue

  src_rel="${line%%=>*}"
  src_rel="$(echo "$src_rel" | xargs)"

  dst_rel="${line#*=>}"
  dst_rel="$(echo "$dst_rel" | xargs)"

  src_path="$FILES_DIR/$src_rel"
  dst_path="$HOME_DIR/$dst_rel"

  if [[ ! -e "$src_path" ]]; then
    echo "skip (missing in repo): $src_rel"
    continue
  fi

  mkdir -p "$(dirname "$dst_path")"

  if [[ -L "$dst_path" ]]; then
    rm -f "$dst_path"
  elif [[ -e "$dst_path" ]]; then
    backup_path="$BACKUP_DIR/$dst_rel"
    mkdir -p "$(dirname "$backup_path")"
    mv "$dst_path" "$backup_path"
  fi

  ln -s "$src_path" "$dst_path"
  echo "linked: $dst_rel"
done < "$MANIFEST"

echo "Install complete. Backup dir: $BACKUP_DIR"
