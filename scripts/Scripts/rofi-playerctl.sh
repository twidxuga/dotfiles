#!/usr/bin/env zsh
LANG="en_US.utf8"
# Outputs have spaces in them, so let's make \n the IFS
IFS=$'\n'

CURPLAYERFILE="/tmp/playerctl-currentplayer"

# Make script independent on particular implementation of send client
if command -v notify-send > /dev/null 2>&1; then
    SEND="notify-send"
elif command -v dunstify > /dev/null 2>&1; then
    SEND="dunstify"
else
    SEND="/bin/false"
fi

# An option was passed, so let's check it
if [ "$@" ]
then
    # the output from the selection will be the desciption.  Save that for alerts
    player="$*"
    # Try to set the default to the device chosen
    echo $player > $CURPLAYERFILE
    $SEND -t 2000 -r 2 -u low "Player: $player"
    # Workaround for i3bar with i3status
    killall -USR1 i3status
else
    echo -en "\x00prompt\x1fSelect Player\n"
    # Get the list of outputs based on the description, which is what makes sense to a human
    # and is what we want to show in the menu
    for player in $(playerctl -a metadata -f "{{ playerName }}")
    do
        # outputs with cut may have spaces, so use empty xargs to remove them, and output that to the rofi list
        echo $player
    done
fi
