SHELL:=/bin/bash

.PHONY: all part1 part2 part3 clean superclean auto-test grade

all: part1 part2 part3

part1:
	-make -C part1

part2:
	-make -C part2

part3:
	-make -C part3

clean:
	make -C part1 clean
	make -C part2 clean
	-make -C part3 clean

superclean:
	make -C part1 clean
	make -C part2 superclean
	-make -C part3 superclean

auto-test:
	@echo > testout
	@./grade "1 2 3" > testout

grade:
	@./grader-mandatory.py testout
