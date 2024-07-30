#!/bin/bash

clear
source "`ueberzug library`"
COVER="/tmp/album_cover.png"

# pane=$(tmux display -p '#{pane_id}') # active pane changes
TTY=$(tty)
pane=$(tmux list-panes -F "#D #{pane_tty}" | grep "$TTY" | awk '{print $1}')
if [[ "$#" -eq 1  ]]
then
  pane=$1
fi
width=$(tmux display -pt "$pane" '#{pane_width}')
height=$(tmux display -pt "$pane" '#{pane_height}')
# offset=$(($width / 4))
# x=$(tmux display -pt "$pane" '#{pane_left}')
# y=$(tmux display -pt "$pane" '#{pane_top}')
# echo "Pane: $pane, Width: $width, Height: $height, X: $x, Y: $y" #, Offset: $offset"

# Initial add cover
if [ -f "$COVER" ]; then
  {
    # echo "about to add image at cover_init"
    ImageLayer::add [identifier]="img" [x]="0" [y]="0" [height]="$height" [width]="$width" [path]="$COVER" [scaler]="fit_contain"
    # echo "end adding image at cover_init"
    while ! inotifywait -q -q -e modify "$COVER"; do
      # echo "sleeping in cover_init"
      sleep 1
    done
    exit 0
  } | ImageLayer
fi
# echo "Ending cover_init"
