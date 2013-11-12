#!/bin/sh

rrdtool graph /root/temp.png \
  --start now-1d --end now \
  --width=640 --height=480 \
  --step=60 -v degreesC \
  DEF:temp1=/root/temperatures.rrd:degreesC:LAST \
  LINE1:temp1#008000:"temp"