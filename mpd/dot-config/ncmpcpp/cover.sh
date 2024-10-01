#!/bin/bash

COVER="/tmp/album_cover.png"

if [ ! -f "$COVER" ]; then
  cp "$HOME/Pictures/default-album-art.png" "$COVER"
  sleep 2 # let tmux start
fi

bash "$(dirname $0)/cover_show.sh" &

TTY=$(tty)
pane=$(tmux list-panes -F "#D #{pane_tty}" | grep "$TTY" | awk '{print $1}')
# echo "$0 - Pane: $pane"

# Render image when changed
while inotifywait -q -q -e close_write "$COVER"; do
  bash "$(dirname $0)/cover_show.sh" $pane &
done
# )
