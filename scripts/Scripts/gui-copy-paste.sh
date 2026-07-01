#!/bin/bash
# gui-copy-paste.sh - Global Alt+C / Alt+V copy & paste for i3 (X11)
#
# i3 globally grabs Alt+C / Alt+V (Mod1+c / Mod1+v) and runs this script.
# The script synthesizes the correct copy/paste keystroke into the focused
# window, routing by the focused window's class:
#
#   - wezterm (org.wezfurlong.wezterm) -> Ctrl+Shift+C / Ctrl+Shift+V
#       (wezterm's native terminal copy/paste; never bare Ctrl+C which would
#        SIGINT the foreground process)
#   - any other GUI app                -> Ctrl+C / Ctrl+V
#
# STUCK-MODIFIER FIX (xdotool issue #43): the previous version used
# `xdotool key --clearmodifiers`, which snapshots held modifiers, releases
# them, sends the key, then RE-PRESSES them. If the physical Alt/Super is
# released mid-sequence, that re-press desyncs X's modifier state and leaves
# a phantom modifier "stuck down" (symptom: next Enter acts as $mod+Return =
# fullscreen). We instead explicitly `keyup` every modifier keysym BEFORE
# injecting (forcing a known all-released state, never restoring), and sweep
# them up again on exit via a trap. No --clearmodifiers, no re-press, no race.
# i3 fires this with `bindsym --release`, so the trigger key is already up.
#
# Usage: gui-copy-paste.sh copy|paste

set -euo pipefail

# All modifier keysyms present in this keyboard's `xmodmap -pm` output, plus
# the common ones. Releasing keysyms that aren't pressed is a harmless no-op,
# so we can safely sweep a superset. This is what prevents the stuck modifier.
MODS=(
  Shift_L Shift_R
  Control_L Control_R
  Alt_L Alt_R Meta_L Meta_R
  Super_L Super_R
  ISO_Level3_Shift ISO_Level5_Shift
)

release_all_mods() {
  xdotool keyup "${MODS[@]}" >/dev/null 2>&1 || true
}

# Defensive sweep on any exit path so we never leave a modifier stuck.
trap release_all_mods EXIT INT TERM

action=${1:?usage: gui-copy-paste.sh copy|paste}

class=$(xdotool getactivewindow getwindowclassname 2>/dev/null || true)

case "$class" in
  org.wezfurlong.wezterm)
    case "$action" in
      copy)  combo="ctrl+shift+c" ;;
      paste) combo="ctrl+shift+v" ;;
      *) echo "unknown action: $action" >&2; exit 2 ;;
    esac
    ;;
  *)
    case "$action" in
      copy)  combo="ctrl+c" ;;
      paste) combo="ctrl+v" ;;
      *) echo "unknown action: $action" >&2; exit 2 ;;
    esac
    ;;
esac

# Force a clean, fully-released modifier state, THEN inject the chord.
# No --clearmodifiers: we never want xdotool to re-press anything.
release_all_mods
xdotool key "$combo"
