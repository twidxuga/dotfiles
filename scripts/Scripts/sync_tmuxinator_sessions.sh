#!/bin/env zsh
tmuxinator start music --suppress-tmux-version-warning=SUPPRESS-TMUX-VERSION-WARNING &
sleep 0.3
tmuxinator start twid --suppress-tmux-version-warning=SUPPRESS-TMUX-VERSION-WARNING

