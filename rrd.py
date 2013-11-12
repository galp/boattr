#!/usr/bin/python

import rrdtool

database_file = "/root/temperatures.rrd"
MIN_TEMP = -100

def read_temperature():
  # open/read/close the file with the temperature; the output is like
  # in the example above.
  tfile = open("/sys/bus/w1/devices/10-0008021eb5ed/w1_slave")
  text = tfile.read()
  tfile.close()

  # split the two lines
  lines = text.split("\n")

  # make sure the crc is valid
  if lines[0].find("YES") > 0:
    # get the 9th (10th) chunk of text and lose the t= bit
    temp = float((lines[1].split(" ")[9])[2:])
    # add a decimal point
    temp /= 1000
    return temp
  return MIN_TEMP-1

current_temp = read_temperature()

if current_temp >= MIN_TEMP:
  rrdtool.update(database_file, "N:%f" % current_temp)
