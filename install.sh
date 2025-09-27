#!/usr/bin/env zsh
# Janus installer (zsh 5.9+) — atomic, idempotent
set -euo pipefail
emulate -L zsh
setopt PIPE_FAIL ERR_EXIT NO_UNSET

JANUS_REPO_ROOT="${0:A:h}"
JANUS_SRC="${JANUS_REPO_ROOT}/janus"
JANUS_DST="${HOME}/.config/janus"
ZSHRC="${HOME}/.zshrc"

version_ge() {
  # Compare two dotted versions: returns 0 if $1 >= $2
  local IFS=.
  local -a a=(${1}) b=(${2})
  local i max=${#a}
  (( ${#b} > max )) && max=${#b}
  for ((i=1; i<=max; i++)); do
    local ai="${a[i]:-0}" bi="${b[i]:-0}"
    if (( ai > bi )); then return 0; fi
    if (( ai < bi )); then return 1; fi
  done
  return 0
}

require_zsh() {
  local need="5.9"
  local have="${ZSH_VERSION:-0}"
  if ! version_ge "$have" "$need"; then
    print -u2 "Error: zsh >= ${need} required, found ${have}"
    exit 1
  fi
}

detect_pkg_mgr() {
  if command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  else
    echo "none"
  fi
}

install_deps() {
  local mgr="$1"
  case "$mgr" in
    pacman)
      local pkgs=(sway waybar wofi foot swaybg swayidle swaylock jq coreutils findutils sed awk rsync)
      print "Installing dependencies with pacman (requires sudo)..."
      sudo pacman --needed --noconfirm -S "${pkgs[@]}"
      ;;
    apt)
      local pkgs=(sway waybar wofi foot swaybg swayidle swaylock jq coreutils findutils sed gawk rsync)
      print "Installing dependencies with apt (requires sudo)..."
      sudo apt-get update
      sudo apt-get install -y "${pkgs[@]}"
      ;;
    *)
      print "No supported package manager found. Please install: sway waybar wofi foot swaybg swayidle swaylock jq coreutils findutils sed awk rsync"
      ;;
  esac
}

backup_if_exists() {
  local path="$1"
  if [[ -e "$path" && ! -L "$path" ]]; then
    local ts=$(date +%Y%m%d-%H%M%S)
    local bak="${path}.bak-${ts}"
    print "Backing up ${path} -> ${bak}"
    mv "$path" "$bak"
  fi
}

link_to() {
  local target="$1"
  local link="$2"
  mkdir -p "${link:h}"
  ln -sfn "$target" "$link"
  print "Linked ${link} -> ${target}"
}

ensure_active_symlink() {
  local default="${JANUS_DST}/modes/day"
  local active="${JANUS_DST}/modes/active"
  if [[ ! -L "$active" ]]; then
    ln -sfn "$default" "$active"
    print "Active mode set to day"
  fi
}

ensure_zshrc() {
  local pathline='export PATH="$HOME/.config/janus/bin:$PATH"'
  local sourceline='[[ -f "$HOME/.config/janus/zsh/janus.zsh" ]] && source "$HOME/.config/janus/zsh/janus.zsh"'
  touch "$ZSHRC"
  if ! grep -Fq "$pathline" "$ZSHRC"; then
    print "\n# Janus\n${pathline}" >> "$ZSHRC"
    print "Appended PATH to ${ZSHRC}"
  fi
  if ! grep -Fq "$sourceline" "$ZSHRC"; then
    print "${sourceline}" >> "$ZSHRC"
    print "Appended Janus zsh sourcing to ${ZSHRC}"
  fi
}

copy_tree() {
  # Prefer rsync if available, otherwise cp -a
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$JANUS_SRC"/ "$JANUS_DST"/
  else
    mkdir -p "$JANUS_DST"
    cp -a "$JANUS_SRC"/. "$JANUS_DST"/
  fi
}

main() {
  require_zsh

  local mgr=$(detect_pkg_mgr)
  print "Detected package manager: ${mgr}"
  if [[ "${1:-}" == "--install-deps" ]]; then
    install_deps "$mgr" || true
  else
    print "Skipping dependency install. You can run: ./install.sh --install-deps"
  fi

  if [[ ! -d "$JANUS_SRC" ]]; then
    print -u2 "Error: ${JANUS_SRC} not found. Run from the repo root."
    exit 1
  fi

  mkdir -p "${HOME}/.config"
  if [[ -d "$JANUS_DST" ]]; then
    print "Updating existing ${JANUS_DST}..."
  else
    print "Installing ${JANUS_DST}..."
  fi
  copy_tree

  # Ensure executables
  chmod +x "${JANUS_DST}/bin/"*

  # Ensure active symlink
  ensure_active_symlink

  # Symlink standard configs into Janus
  link_to "${JANUS_DST}/core/sway/config" "${HOME}/.config/sway/config"
  link_to "${JANUS_DST}/modes/active/waybar/config.jsonc" "${HOME}/.config/waybar/config.jsonc"
  link_to "${JANUS_DST}/modes/active/waybar/style.css" "${HOME}/.config/waybar/style.css"
  link_to "${JANUS_DST}/modes/active/wofi/config" "${HOME}/.config/wofi/config"
  link_to "${JANUS_DST}/modes/active/wofi/style.css" "${HOME}/.config/wofi/style.css"
  link_to "${JANUS_DST}/modes/active/foot/foot.ini" "${HOME}/.config/foot/foot.ini"

  ensure_zshrc

  print "\nDone."
  print "Tips:"
  print " - Start Sway (or reload: swaymsg reload)"
  print " - Toggle themes: janusctl mode toggle  (or Super+Alt+T)"
  print " - Check status:  janusctl status"
  print " - Doctor:        janusctl doctor"
}

main "$@"
