#!/bin/sh

# credit https://github.com/polybar/polybar-scripts/blob/master/polybar-scripts/system-cpu-temppercore/system-cpu-temppercore.sh
sensors | grep Core | awk '{print substr($3, 2, length($3)-5)}' | tr "\\n" " " | sed 's/ /°C  /g' | sed 's/  $//'
