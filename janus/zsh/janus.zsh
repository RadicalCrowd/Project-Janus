# Janus zsh customization — minimal and fast

# Prefer Wayland apps
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

# Janus helpers
alias jt='janusctl mode toggle'
alias js='janusctl status'
alias jd='janusctl doctor'

# Add Janus bin to PATH in case installer missed it
if [[ ":$PATH:" != *":$HOME/.config/janus/bin:"* ]]; then
  export PATH="$HOME/.config/janus/bin:$PATH"
fi
