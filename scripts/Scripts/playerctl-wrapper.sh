#!/bin/env zsh

CURPLAYERFILE="/tmp/playerctl-currentplayer"

if [[ "$#" -ne 1 ]]; then
  echo "Usage: $0 <command>" >&2
  exit 1
fi

command=$1

if [[ -e $CURPLAYERFILE &&
  $(playerctl -a metadata -f "{{ playerName }}" | grep $(cat /tmp/playerctl-currentplayer)) ]]
then
  player=$(cat $CURPLAYERFILE)
  playerctl -p $player $command
else
  playerctl $command
fi
exit 0
