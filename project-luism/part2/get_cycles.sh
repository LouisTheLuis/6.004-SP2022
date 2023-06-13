#!/bin/sh
cat /dev/stdin | grep -Eio "Total Cycles = ([0-9]+)" | grep -Eo "([0-9]+)"
