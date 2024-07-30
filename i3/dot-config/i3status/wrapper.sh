#!/bin/sh
# shell script to prepend i3status with more stuff
CURPLAYERFILE="/tmp/playerctl-currentplayer"
i3status | while :; do
  read line
  # echo "mystuff | $line" || exit 1
  volume=$(pamixer --get-volume-human)
player=$([[ -e $CURPLAYERFILE ]] && [[ $(playerctl -a metadata -f "{{ playerName }}" | grep $(cat $CURPLAYERFILE)) ]]  && echo "-p $(cat $CURPLAYERFILE)")
  playerinfo=$(playerctl $player metadata --format '[{{ uc(status) }}][{{ playerName }}] - {{ artist }} - {{ album }} - {{ title }}')
  playerinfo=$(echo ${playerinfo:0:120})
  backlight=$(echo $((100 * $(brightnessctl get) / $(brightnessctl max))))
  kblayout=$(setxkbmap -query | awk '/layout/{print $2}')
  caps=$(if [[ $(xset q | grep Caps | awk '{print $4}') == 'on' ]]; then echo "CAPS | "; fi)
  echo "$playerinfo | ${caps}KB $kblayout | VOL $volume | BL $backlight% | $line" || exit 1
done
