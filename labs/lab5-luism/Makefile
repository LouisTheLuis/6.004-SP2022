SHELL:=/bin/bash

test_multiply_by_adding: Multipliers.ms
	./findIllegal Multipliers.ms "multiply_by_adding#(4)" 
	msc TBMultiplier.ms MultiplyByAddingTest 
	mv MultiplyByAddingTest $@
	mv MultiplyByAddingTest.so $@.so

test_folded_multiplier: Multipliers.ms
	./findIllegal Multipliers.ms "FoldedMultiplier#(4)"
	msc TBMultiplier.ms FoldedMultiplierTest
	mv FoldedMultiplierTest $@
	mv FoldedMultiplierTest.so $@.so

test_fast_folded_multiplier: Multipliers.ms
	./findIllegal Multipliers.ms "FastFoldedMultiplier#(4)"
	msc TBMultiplier.ms FastFoldedMultiplierTest
	mv FastFoldedMultiplierTest $@
	mv FastFoldedMultiplierTest.so $@.so

test_pipeline_math: TBPipelineMath.ms PipelineMath.ms
	msc TBPipelineMath.ms PipelineMathTest
	mv PipelineMathTest $@
	mv PipelineMathTest.so $@.so

test_sorting_network: SortingNetworks.ms
	./findIllegal SortingNetworks.ms "BitonicSorter8"
	msc TBSortingNetwork.ms BitonicSorterTest
	mv BitonicSorterTest $@
	mv BitonicSorterTest.so $@.so

all: test_multiply_by_adding test_folded_multiplier test_fast_folded_multiplier test_pipeline_math test_sorting_network

clean:
	rm -rf test_multiply_by_adding test_folded_multiplier test_fast_folded_multiplier test_pipeline_math test_sorting_network synthDir* *.bo *synth_out

test: all
	@./test_all

.PHONY: all clean test
.DEFAULT_GOAL := all
