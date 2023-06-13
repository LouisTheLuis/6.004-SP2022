#!/bin/sh
rv_sim sort_bench --auto | grep -E "Executed Instrs " | sed  's/||.*//g' | grep -Eo "([0-9]+)"
