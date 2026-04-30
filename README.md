# Dotfiles

This repository tracks selected personal config files from `~/.config` and home shell files.

## Layout

- `files/`: tracked copies of config files
- `files.manifest`: mapping of tracked paths
- `sync-from-system.sh`: copy current system config into `files/`
- `install.sh`: symlink tracked files back into `$HOME` with automatic backup

## Quick Start

```bash
cd ~/.config/dotfiles
./sync-from-system.sh
git init
git add .
git commit -m "Initial dotfiles snapshot"
```

## Update workflow

1. Edit your real config files as usual.
2. Run:

```bash
~/.config/dotfiles/sync-from-system.sh
```

3. Commit changes:

```bash
cd ~/.config/dotfiles && git add . && git commit -m "Update dotfiles"
```

## Restore workflow

```bash
~/.config/dotfiles/install.sh
```

This script creates backups under `~/.config/dotfiles-backup/<timestamp>/` before creating symlinks.
