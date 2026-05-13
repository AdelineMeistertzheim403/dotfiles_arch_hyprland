# =========================
#  Zsh + Powerlevel10k OK
# =========================

# 0) Recommandation p10k : supprimer le warning sans sacrifier la vitesse
#    (doit être placé AVANT l'instant prompt)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# 1) Powerlevel10k Instant Prompt — doit rester tout en haut
#    (ne rien afficher avant ce bloc)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2) Chemin Oh My Zsh
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# 3) Thème Powerlevel10k (pas de Starship ici)
ZSH_THEME="powerlevel10k/powerlevel10k"

# 4) Plugins Oh My Zsh
# - L’ordre compte : 'zsh-syntax-highlighting' en DERNIER
plugins=(
  git
  z
  sudo
  docker
  docker-compose
  npm
  zsh-autosuggestions
  zsh-syntax-highlighting
  kubectl
  colored-man-pages
  command-not-found
)

# 5) Désactiver les prompts de compfix (éviter les sorties console)
#    (si tu préfères corriger les permissions proprement, voir plus bas)
ZSH_DISABLE_COMPFIX=true

# 6) Charger Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# 7) Plugins externes en fallback uniquement (évite les double-sources)
if [[ -z "${_ZSH_AUTOSUGGEST_BIND_COUNTS+x}" ]] && [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if ! (( ${+functions[_zsh_highlight]} )) && [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# 8) Historique (paramètres utiles)
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt share_history
setopt inc_append_history
setopt extended_history

# 9) Options pratiques
setopt autocd           # cd implicite
setopt correct          # correction légère des fautes de frappe
setopt nocaseglob       # globbing insensible à la casse

# 10) Aliases utiles
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gp='git pull'
alias gpf='git push --force-with-lease'
alias eduroam="nmcli connection up eduroam"
alias ros2="docker run -p 6080:80  -v "/home/adeline/ros2_course_docker_data:/home/ubuntu/ros2_course" --shm-size=1064m yguel/ros2_in_practice:humble"

# 11) Langue / PATH (adapte si besoin)
export EDITOR="nano"
export LANG=fr_FR.UTF-8
export LC_ALL=fr_FR.UTF-8

# 12) Charger la config Powerlevel10k (après oh-my-zsh)
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 13) (IMPORTANT) Ne pas initialiser Starship (conflit avec p10k)
# Si tu vois cette ligne chez toi, laisse-la commentée :
# eval "$(starship init zsh)"

# --- Afficher fastfetch une fois à l'ouverture du shell interactif ---
autoload -Uz add-zsh-hook
__run_fastfetch_once() {
  command -v fastfetch >/dev/null || return
  [[ -t 1 ]] || return  # seulement en terminal interactif
  fastfetch
  add-zsh-hook -d precmd __run_fastfetch_once
}
# Déclenche dès le premier prompt
add-zsh-hook precmd __run_fastfetch_once
# Et déclenche aussi à la fin de l'init pour ne pas attendre une commande
__run_fastfetch_once
# ===== ANDROID SDK =====
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# ===== JAVA =====
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$PATH:$JAVA_HOME/bin


# Waybar quick recovery
alias wbfix="$HOME/.config/bin/wbfix"
alias talert="$HOME/.config/bin/thermal-alert-test.sh"
alias talert-loop="$HOME/.config/bin/thermal-alert-test-loop.sh"
alias tquiet="$HOME/.config/bin/thermal-alert-mode.sh toggle"
alias tquiet-on="$HOME/.config/bin/thermal-alert-mode.sh on"
alias tquiet-off="$HOME/.config/bin/thermal-alert-mode.sh off"
alias tquiet-status="$HOME/.config/bin/thermal-alert-mode.sh status"
alias tdaemon-status="systemctl --user --no-pager --full status thermal-alert.service"
alias tdaemon-restart="systemctl --user restart thermal-alert.service"

# Dotfiles workflow
alias dot-home="cd $HOME/.config/dotfiles"
alias dot-status="git -C $HOME/.config/dotfiles status -sb"
alias dot-sync="$HOME/.config/dotfiles/sync-from-system.sh"
alias dot-install="$HOME/.config/dotfiles/install.sh"
alias dot-log="tail -n 40 $HOME/.local/state/thermal-alert/alerts.log"
alias dcheck="$HOME/.config/bin/desktop-healthcheck.sh"
alias dcheck-json="$HOME/.config/bin/desktop-healthcheck.sh --json"
alias dcheck-notify="$HOME/.config/bin/desktop-healthcheck.sh --notify"
alias dcheck-watch="watch -n 3 '$HOME/.config/bin/desktop-healthcheck.sh'"
alias dcheck-watch-json="watch -n 3 '$HOME/.config/bin/desktop-healthcheck.sh --json | jq'"

# ===== ADVANCED TERMINAL SETUP =====

# 1) VI MODE - Keybindings Vim
bindkey -v
export KEYTIMEOUT=1

# 2) VI Move between words with Alt+{b,f}
bindkey "^[b" backward-word
bindkey "^[f" forward-word

# 3) Search in history with Vi mode
bindkey -M vicmd "?" history-incremental-search-backward
bindkey -M vicmd "/" history-incremental-search-forward

# 4) Change cursor shape based on mode (for compatible terminals)
function zle-keymap-select {
  if [[ $KEYMAP == main ]]; then
    echo -ne "\033[1 q"  # Block cursor in insert mode
  elif [[ $KEYMAP == vicmd ]]; then
    echo -ne "\033[2 q"  # Beam cursor in normal mode
  fi
}
zle -N zle-keymap-select

# 5) Init cursor shape on startup
echo -ne "\033[1 q"

# ===== USEFUL FUNCTIONS =====

# Extract archives intelligently
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar x "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "Unknown archive type: $1" ;;
    esac
  else
    echo "File not found: $1"
  fi
}

# Directory listing with colors
lst() {
  ls -lhAF --color=auto "$@"
}

# Quick file search
qfind() {
  find . -iname "*$1*" 2>/dev/null
}

# Show disk usage per directory
dusage() {
  du -sh */ | sort -hr | head -10
}

# Create and cd into directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick note taking
qnote() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $*" >> "$HOME/.local/state/notes.log"
  echo "✓ Note saved"
}

# ===== CLI TOOL ALIASES & REPLACEMENTS =====

# Use 'cat' with fallback to syntax highlighting
if command -v bat &> /dev/null; then
  alias cat="bat --style=plain"
  alias cath="bat"  # with syntax highlighting
else
  alias cat="/usr/bin/cat"
fi

# Use 'ls' replacement if available
if command -v lsd &> /dev/null; then
  alias ls="lsd --color=auto"
  alias la="lsd -A"
  alias ll="lsd -lh"
  alias lla="lsd -lhA"
fi

# Grep with ripgrep (faster)
if command -v rg &> /dev/null; then
  alias grep="rg"
fi

# Fast navigation with zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias j="z"
fi

# FZF integration (history + project jump)
if command -v fzf &> /dev/null; then
  # Better Ctrl+R: fuzzy history with newest-first preview.
  fzf-history-widget() {
    local selected
    selected=$(fc -rl 1 | sed 's/^ *[0-9]\+ *//' | awk '!seen[$0]++' | fzf --height=40% --layout=reverse --prompt='history> ')
    if [[ -n "$selected" ]]; then
      LBUFFER="$selected"
      zle redisplay
    fi
  }
  zle -N fzf-history-widget
  bindkey '^R' fzf-history-widget

  # Ctrl+G: fuzzy cd from common roots.
  fzf-cd-widget() {
    local target
    target=$(find "$HOME/.config" "$HOME" -maxdepth 2 -type d 2>/dev/null | fzf --height=40% --layout=reverse --prompt='cd> ')
    if [[ -n "$target" ]]; then
      cd "$target" || return
      zle reset-prompt
    fi
  }
  zle -N fzf-cd-widget
  bindkey '^G' fzf-cd-widget
fi

# ===== USEFUL UTILITIES =====

# Show most used commands
alias topcmd="history | cut -d' ' -f 7 | sort | uniq -c | sort -rn | head -15"

# Measure interactive shell startup time quickly.
zbench() {
  local i
  for i in {1..5}; do
    if command -v /usr/bin/time >/dev/null 2>&1; then
      /usr/bin/time -f '%E real' zsh -i -c exit >/dev/null
    elif command -v gtime >/dev/null 2>&1; then
      gtime -f '%E real' zsh -i -c exit >/dev/null
    else
      time zsh -i -c exit >/dev/null
    fi
  done
}

# Clear all caches
alias cleancache="rm -rf ~/.cache/* && echo 'Cache cleared'"

# Count files in directory
alias countfiles="find . -type f | wc -l"

# Compress a directory
comp() {
  tar -czf "$1.tar.gz" "$1" && echo "Compressed: $1.tar.gz"
}

# Quick markdown to HTML preview
if command -v pandoc &> /dev/null; then
  mdhtml() {
    pandoc "$1" -o "${1%.md}.html" && echo "Generated: ${1%.md}.html"
  }
fi

# ===== SYSTEM INFO =====

# Show system uptime nicely
alias uptime="uptime -p"

# Show CPU info
alias cpuinfo="lscpu | head -20"

# Show mounted filesystems
alias mounts="mount | grep -E '^/dev' | column -t"
