# Dotfiles

Ce dépôt suit une sélection de fichiers de configuration personnels depuis `~/.config` et les fichiers shell du répertoire home.

## Structure

- `files/` : copies suivies des fichiers de configuration
- `files.manifest` : correspondance des chemins suivis
- `sync-from-system.sh` : copie la configuration système actuelle dans `files/`
- `install.sh` : crée des liens symboliques des fichiers suivis dans `$HOME` avec sauvegarde automatique

## Démarrage rapide

```bash
cd ~/.config/dotfiles
./sync-from-system.sh
git init
git add .
git commit -m "Snapshot initial des dotfiles"
```

## Flux de mise à jour

1. Modifiez vos véritables fichiers de configuration comme d'habitude.
2. Exécutez :

```bash
~/.config/dotfiles/sync-from-system.sh
```

3. Validez les modifications :

```bash
cd ~/.config/dotfiles && git add . && git commit -m "Mise à jour des dotfiles"
```

## Flux de restauration

```bash
~/.config/dotfiles/install.sh
```

Ce script crée des sauvegardes sous `~/.config/dotfiles-backup/<timestamp>/` avant de créer les liens symboliques.
