SHELL:=/bin/bash

test_fullAdder: ALU.ms
	@./findIllegal ALU.ms fullAdder
	@timeout 3m msc Tb.ms Tb_fullAdder
	@mv Tb_fullAdder $@
	@mv Tb_fullAdder.so $@.so

test_rca32: ALU.ms
	@./findIllegal ALU.ms "rca#(32)"
	@timeout 3m msc Tb.ms Tb_rca32
	@mv Tb_rca32 $@
	@mv Tb_rca32.so $@.so

test_addSub32: ALU.ms
	@./findIllegal ALU.ms "addSub#(32)"
	@timeout 3m msc Tb.ms Tb_addSub32
	-@timeout 2m ./check_area 'addSub#(32)' 1.7 'rca#(32)'
	@mv Tb_addSub32 $@
	@mv Tb_addSub32.so $@.so

test_cmp: ALU.ms
	@./findIllegal ALU.ms cmp
	@timeout 3m msc Tb.ms Tb_cmp
	@mv Tb_cmp $@
	@mv Tb_cmp.so $@.so

test_ltu32: ALU.ms
	@./findIllegal ALU.ms ltu32
	@timeout 3m msc Tb.ms Tb_ltu32
	@mv Tb_ltu32 $@
	@mv Tb_ltu32.so $@.so

test_lt32: ALU.ms
	@./findIllegal ALU.ms lt32
	@timeout 3m msc Tb.ms Tb_lt32
	-@timeout 2m ./check_area lt32 1.2 ltu32
	@mv Tb_lt32 $@
	@mv Tb_lt32.so $@.so

test_sr32: ALU.ms
	@./findIllegal ALU.ms sr32
	@timeout 3m msc Tb.ms Tb_sr32
	-@timeout 2m ./check_area sr32 1.2 barrelRShift
	@mv Tb_sr32 $@
	@mv Tb_sr32.so $@.so

test_sll32: ALU.ms
	@./findIllegal ALU.ms sll32
	@timeout 3m msc Tb.ms Tb_sll32
	-@timeout 2m ./check_area sll32 1.2 barrelRShift
	@mv Tb_sll32 $@
	@mv Tb_sll32.so $@.so

test_sft32: ALU.ms
	@./findIllegal ALU.ms sft32
	@timeout 3m msc Tb.ms Tb_sft32
	-@timeout 2m ./check_area sft32 1.9 barrelRShift
	@mv Tb_sft32 $@
	@mv Tb_sft32.so $@.so

test_alu: ALU.ms
	@./findIllegal ALU.ms alu
	@timeout 3m msc Tb.ms Tb_alu
	-@timeout 3m ./check_area alu 1.45 'addSub#(32)' lt32 sft32
	@mv Tb_alu $@
	@mv Tb_alu.so $@.so

test_fastAdd32: ALU.ms
	@rm -f testout_fastAdd32_delay
	@./findIllegal ALU.ms "fastAdd#(32)"
	@timeout 3m msc Tb.ms Tb_fastAdd32
	@mv Tb_fastAdd32 $@
	@mv Tb_fastAdd32.so $@.so

all: test_fullAdder test_rca32 test_addSub32 test_cmp test_ltu32 test_lt32 test_sr32 test_sll32 test_sft32 test_alu test_fastAdd32

test: all
	@./test_all

clean:
	rm -rf Tb_* *.svg *.bo synthDir checkDir

.PHONY: test clean
.DEFAULT_GOAL := all

