#!/bin/zsh

# Enque all songs in mpd
c=$(mpc playlist | wc -l) 
mpc add $@ && mpc play $((c + 1))
