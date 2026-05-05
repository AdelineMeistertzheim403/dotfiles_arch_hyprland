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

## Raccourcis clavier (Hyprland)

> `SUPER` = touche Windows/Meta — `$mainMod` dans la config

### Applications

| Raccourci | Action |
|-----------|--------|
| `SUPER + Entrée` | Terminal (sur l'écran focusé) |
| `SUPER + B` | Navigateur (workspace 2) |
| `SUPER + C` | Éditeur de code (workspace 3) |
| `SUPER + M` | Chat (workspace 4) |
| `SUPER + E` | Gestionnaire de fichiers (workspace 7) |
| `SUPER + D` | Lanceur d'apps (quickshell spotlight) |
| `SUPER SHIFT + D` | Fermer le lanceur |
| `SUPER SHIFT + Q` | Quitter quickshell |
| `SUPER + V` | Historique presse-papiers |
| `SUPER + L` | Verrouiller l'écran |

### Gestion des fenêtres

| Raccourci | Action |
|-----------|--------|
| `SUPER + Q` | Fermer la fenêtre active |
| `SUPER + F` | Plein écran |
| `SUPER + ESPACE` | Basculer flottant |
| `SUPER SHIFT + ESPACE` | Centrer la fenêtre |
| `SUPER + J` | Basculer split |
| `SUPER + P` | Mode pseudo-tile |
| `SUPER + TAB` / `SUPER SHIFT + TAB` | Fenêtre suivante/précédente |
| `ALT + TAB` / `ALT SHIFT + TAB` | Fenêtre suivante/précédente |
| `SUPER + ←↑→↓` | Déplacer le focus |
| `SUPER SHIFT + ←↑→↓` | Déplacer la fenêtre dans le layout |
| `SUPER CTRL + ←↑→↓` | Redimensionner la fenêtre |
| `SUPER + clic gauche` | Déplacer fenêtre (souris) |
| `SUPER + clic droit` | Redimensionner fenêtre (souris) |

### Déplacement inter-écrans

| Raccourci | Action |
|-----------|--------|
| `SUPER ALT + ←` | Envoyer la fenêtre sur l'écran gauche (DP-4) |
| `SUPER ALT + ↑` | Envoyer la fenêtre sur le laptop (eDP-1) |
| `SUPER ALT + →` | Envoyer la fenêtre sur l'écran droit (DP-2) |
| `SUPER CTRL ALT + ←` | Focaliser l'écran gauche (DP-4) |
| `SUPER CTRL ALT + ↑` | Focaliser le laptop (eDP-1) |
| `SUPER CTRL ALT + →` | Focaliser l'écran droit (DP-2) |

### Modes visuels

| Raccourci | Action |
|-----------|--------|
| `SUPER SHIFT + F` | Basculer mode focus |
| `SUPER SHIFT + G` | Mode gaming |
| `SUPER SHIFT + O` | Mode stream |
| `SUPER SHIFT + N` | Mode normal |
| `SUPER SHIFT + A` | Mode auto (détecte OBS/jeux) |
| `SUPER SHIFT + P` | Basculer mode présentation (coupe waybar, mako, quickshell) |

### Workspaces

| Raccourci | Action |
|-----------|--------|
| `SUPER + 1-8` | Aller au workspace N |
| `SUPER SHIFT + 1-8` | Envoyer la fenêtre au workspace N |
| `SUPER + molette` | Workspace suivant/précédent |

### Captures d'écran

| Raccourci | Action |
|-----------|--------|
| `SUPER + S` | Sélection → fichier + presse-papiers |
| `SUPER SHIFT + S` | Sélection → édition (swappy) |
| `SUPER + Impr écran` | Écran entier → fichier |
| `SUPER SHIFT + Impr écran` | Fenêtre active → fichier |

### Système

| Raccourci | Action |
|-----------|--------|
| `SUPER SHIFT + W` | Redémarrer waybar |
| `SUPER SHIFT + E` | Quitter Hyprland |
| Touches média | Volume +/- / muet |
| Touches luminosité | Luminosité +/- |

---

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
