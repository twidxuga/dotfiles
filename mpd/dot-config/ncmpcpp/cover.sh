#!/bin/bash

source "`ueberzug library`"
COVER="/tmp/album_cover.png"

if [ ! -f "$COVER" ]; then
  cp "$HOME/Pictures/default-album-art.png" "$COVER"
fi

bash "$(dirname $0)/cover_show.sh" &

TTY=$(tty)
pane=$(tmux list-panes -F "#D #{pane_tty}" | grep "$TTY" | awk '{print $1}')

# function add_cover() {
#   ImageLayer::add [identifier]="img" [x]="$3" [y]="$4" [width]="$1" [height]="$2" [path]="$COVER" [scaler]="fit_contain"
# }

# ImageLayer 0< <(
# if [ ! -f "$COVER" ]; then
#   cp "$HOME/Pictures/default-album-art.png" "$COVER"
# fi
#rerender image when changed
while inotifywait -q -q -e close_write "$COVER"; do
  # width=$(tmux display -pt "$pane" '#{pane_width}')
  # height=$(tmux display -pt "$pane" '#{pane_height}')
  # x=$(tmux display -pt "$pane" '#{pane_left}')
  # y=$(tmux display -pt "$pane" '#{pane_top}')
  # # echo "Width: $width, Height: $height, X: $x, Y: $y"
  # add_cover "$width" "$height" "$x" $y

  bash "$(dirname $0)/cover_show.sh" $pane &
done
# )
