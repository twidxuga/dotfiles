#!/bin/env zsh
pic="/tmp/scrot-$(date +%s).png" && scrot -f $pic && gimp -na $pic
