# Dotfiles — Arch Linux / Hyprland

Configuration personnelle pour Arch Linux avec Hyprland, waybar, mako, kitty, rofi/quickshell et divers scripts système.

## Structure

- `files/` : copies suivies des fichiers de configuration
- `files.manifest` : correspondance des chemins suivis (source → destination)
- `sync-from-system.sh` : copie la configuration système actuelle dans `files/`
- `install.sh` : crée des liens symboliques des fichiers suivis dans `$HOME` avec sauvegarde automatique

## Fichiers suivis

| Chemin | Description |
|--------|-------------|
| `.config/hypr/` | Configuration Hyprland (modulaire, `conf.d/`) |
| `.config/waybar/` | Barre de statut waybar + scripts |
| `.config/mako/config` | Notifications mako |
| `.config/kitty/kitty.conf` | Terminal kitty |
| `.config/rofi/spotlight.rasi` | Thème rofi |
| `.config/quickshell/spotlight/shell.qml` | Lanceur quickshell |
| `.config/bin/hypr-focus-mode.sh` | Modes visuels : focus / gaming / stream / présentation |
| `.config/bin/hypr-smart-layout.sh` | Smart gaps automatiques |
| `.config/bin/hypr-app-router.sh` | Routage apps + déplacement inter-écrans |
| `.config/bin/desktop-healthcheck.sh` | Healthcheck bureau |
| `.config/bin/thermal-alert-*.sh` | Alertes thermiques |
| `.config/starship.toml` | Prompt starship |
| `.config/thermal-alert.conf` | Config alertes thermiques |
| `.zshrc` / `.p10k.zsh` | Shell zsh + powerlevel10k |

## Flux de mise à jour

1. Modifiez vos fichiers de configuration comme d'habitude.
2. Synchronisez dans le dépôt :

```bash
~/.config/dotfiles/sync-from-system.sh
```

3. Commitez :

```bash
cd ~/.config/dotfiles && git add . && git commit -m "Mise à jour des dotfiles"
```

4. Poussez sur GitHub :

```bash
git push
```

## Flux de restauration

```bash
~/.config/dotfiles/install.sh
```

Ce script crée des sauvegardes sous `~/.config/dotfiles-backup/<timestamp>/` avant de créer les liens symboliques.
