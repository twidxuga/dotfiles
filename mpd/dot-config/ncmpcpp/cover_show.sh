#!/bin/bash

clear
# source "`ueberzug library`"
COVER="/tmp/album_cover.png"

# check if the cover file exists 
[[ ! -f "$COVER" ]] && exit 1

# pane=$(tmux display -p '#{pane_id}') # active pane changes
TTY=$(tty)
pane=$(tmux list-panes -F "#D #{pane_tty}" | grep "$TTY" | awk '{print $1}')
if [[ "$#" -eq 1  ]]
then
  pane=$1
  width=$(tmux display -pt "$pane" '#{pane_width}')
  height=$(tmux display -pt "$pane" '#{pane_height}')
  #offset=$(($width / 4))
  x=$(tmux display -pt "$pane" '#{pane_left}')
  y=$(tmux display -pt "$pane" '#{pane_top}')
else
  pane="start"
  width=57
  height=26
  x=0
  y=35
fi
# echo "Pane: $pane, Width: $width, Height: $height, X: $x, Y: $y" #, Offset: $offset"

# ueberzugpp uses relative y and x, not absolute like ueberzug
y=0 
x=0
{
  echo "{\"path\": \"$COVER\", \"action\": \"add\", \"identifier\": \"cover\", \"x\": \"$x\", \"y\": \"$y\", \"width\": \"$width\", \"height\": \"$height\"}"
  while ! inotifywait -q -q -e modify "$COVER"; do
    # echo "sleeping in cover_init"
    sleep 1
  done
  echo "{\"action\": \"exit\", \"identifier\": \"cover\"}"
  exit 0
} | ueberzugpp layer --silent --no-cache

