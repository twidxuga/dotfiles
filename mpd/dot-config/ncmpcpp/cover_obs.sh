#!/bin/bash

MUSIC_DIR="$HOME/Audio/Music"
COVER="/tmp/album_cover.png"
COVER_SIZE="400"

#path to current song
file="$MUSIC_DIR/$(mpc --format %file% current)"
album="${file%/*}"
#search for cover image
#use embedded image if present, otherwise take it from the current folder
err=$(ffmpeg -loglevel 16 -y -i "$file" -an -vcodec copy $EMB_COVER 2>&1)
if [ "$err" != "" ]; then
  art=$(find "$album"  -maxdepth 1 | grep -m 1 ".*\.\(jpg\|png\|gif\|bmp\)")
else
  art=$EMB_COVER
fi
if [ "$art" = "" ]; then
  art="$HOME/Pictures/default-album-art.png"
fi
#copy and resize image to destination
ffmpeg -loglevel 0 -y -i "$art" -vf "scale=$COVER_SIZE:-1" "$COVER"
