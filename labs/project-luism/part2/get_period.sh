#!/bin/sh
cat /dev/stdin | grep -Eio "has clock period = ([0-9]+\.?[0-9]*) ps" | grep -Eo "([0-9]+\.?[0-9]*)"
