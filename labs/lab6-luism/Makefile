SHELL:=/bin/bash

.PHONY: all clean superclean test

all: test_decode test_execute Processor

Processor: Processor.ms Decode.ms Execute.ms ALU.ms
	msc $< $@

test_decode: DecodeTB.ms Decode.ms
	msc DecodeTB.ms DecodeTB
	mv DecodeTB $@
	mv DecodeTB.so $@.so

test_execute: ExecuteTB.ms Execute.ms ALU.ms
	msc ExecuteTB.ms ExecuteTB
	mv ExecuteTB $@
	mv ExecuteTB.so $@.so

prog_test: Processor
	./test.py $(word 2, $(MAKECMDGOALS))

# ignore missing targets
%:
	@:

clean:
	rm -rf *.v *.bo *.ba *.cxx *.o *.h *.so mem.vmh
	rm -rf test_out
	rm -rf Processor DecodeTB ExecuteTB

superclean: clean
	make -C sw clean

test: all
	./test_all

