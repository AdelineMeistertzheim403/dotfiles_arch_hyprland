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

# 7) (Optionnel) Activer des plugins externes installés via pacman/AUR
#    Vérifie les chemins selon ton système
#    Autosuggestions
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
#    Syntax highlighting (toujours après les autres)
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# 8) Historique (paramètres utiles)
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history
setopt inc_append_history

# 9) Options pratiques
setopt autocd           # cd implicite
setopt correct          # correction légère des fautes de frappe
setopt nocaseglob       # globbing insensible à la casse
bindkey -e              # keymap Emacs par défaut

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
