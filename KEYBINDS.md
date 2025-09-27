# Janus Keybinds (Sway)

Mod key: Super (Mod4)

Launchers
- Super+Enter → launch Foot terminal
- Super+D → open Wofi application launcher

Window management
- Super+Q → close focused window
- Super+F → toggle fullscreen
- Super+Space → toggle floating
- Super+E → toggle split layout (horizontal/vertical)

Focus movement
- Super+H/J/K/L → focus left/down/up/right

Move containers
- Super+Shift+H/J/K/L → move container left/down/up/right

Workspaces
- Super+1..9 → switch to workspace 1..9
- Super+Shift+1..9 → move container to workspace 1..9

Resize mode
- Super+R → enter resize mode
  - H → shrink width by 10px
  - J → grow height by 10px
  - K → shrink height by 10px
  - L → grow width by 10px
  - Enter or Esc → exit resize mode

Session
- Super+Shift+C → reload Sway
- Super+Shift+E → exit Sway (confirmation prompt)

Janus theme control
- Super+Alt+T → toggle Janus mode (Day/Night)
- CLI:
  - janusctl mode toggle
  - janusctl mode day
  - janusctl mode night
  - janusctl status
  - janusctl doctor

Tips
- After toggling themes, Waybar restarts automatically; Wofi/Foot pick up theme on next launch.
- All configs live under ~/.config/janus; the active theme is the symlink ~/.config/janus/modes/active.
