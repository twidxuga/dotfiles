#!/bin/sh
if [ "$(setxkbmap -query | awk '/layout/{print $2}')" = "gb" ]; then
  setxkbmap -layout pt
else
  setxkbmap -layout gb
fi
