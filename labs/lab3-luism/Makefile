TEST_DIR=tests

.INTERMEDIATE: CombDigitalSystemsTemp.ms
CombDigitalSystemsTemp.ms: CombDigitalSystems.ms
	sed "s/+/_PLUS_/g" CombDigitalSystems.ms | sed -e "s/&/_AND_/g" | sed -e "s/|/_OR_/g"| sed -e "s/\^/_XOR_/g" | sed -e "s/~/_NOT_/g" | sed -e "s/?/_QUESTIONMARK_/g"  |sed -e "s/ if/ _IF_/g" |sed -e "s/ for/ _FOR_/g"|sed -e "s/==/_EQUAL_/g"|sed -e "s/-/_SUB_/g" > CombDigitalSystemsTemp.ms

seven_segment_test: CombDigitalSystemsTemp.ms
	msc $(TEST_DIR)/CombDigitalSystemsTest.ms SevenSegmentTest
	mv SevenSegmentTest $@
	mv SevenSegmentTest.so $@.so

population_count_test: CombDigitalSystemsTemp.ms
	msc $(TEST_DIR)/CombDigitalSystemsTest.ms PopulationCountTest
	mv PopulationCountTest $@
	mv PopulationCountTest.so $@.so

is_geq_test: CombDigitalSystemsTemp.ms
	msc $(TEST_DIR)/CombDigitalSystemsTest.ms IsGeqTest
	mv IsGeqTest $@
	mv IsGeqTest.so $@.so

bit_scan_reverse_test: CombDigitalSystemsTemp.ms
	msc $(TEST_DIR)/CombDigitalSystemsTest.ms BitScanReverseTest
	mv BitScanReverseTest $@
	mv BitScanReverseTest.so $@.so

is_power_of_2_test: CombDigitalSystemsTemp.ms
	msc $(TEST_DIR)/CombDigitalSystemsTest.ms IsPowerOf2Test
	mv IsPowerOf2Test $@
	mv IsPowerOf2Test.so $@.so

log_of_power_of_2_test: CombDigitalSystemsTemp.ms
	msc $(TEST_DIR)/CombDigitalSystemsTest.ms LogOfPowerOf2Test
	mv LogOfPowerOf2Test $@
	mv LogOfPowerOf2Test.so $@.so

equal_test: CombDigitalSystemsTemp.ms
	msc $(TEST_DIR)/CombDigitalSystemsTest.ms EqualTest
	mv EqualTest $@
	mv EqualTest.so $@.so

vector_equal_test: CombDigitalSystemsTemp.ms
	msc $(TEST_DIR)/CombDigitalSystemsTest.ms VectorEqualTest
	mv VectorEqualTest $@
	mv VectorEqualTest.so $@.so

test: all
	./test_all.sh

clean:
	rm -f *Temp.ms
	rm -f seven_segment_test seven_segment_test.so
	rm -f population_count_test population_count_test.so
	rm -f is_geq_test is_geq_test.so
	rm -f bit_scan_reverse_test bit_scan_reverse_test.so
	rm -f is_power_of_2_test is_power_of_2_test.so
	rm -f log_of_power_of_2_test log_of_power_of_2_test.so
	rm -f equal_test equal_test.so
	rm -f vector_equal_test vector_equal_test.so

all: bit_scan_reverse_test is_power_of_2_test log_of_power_of_2_test equal_test vector_equal_test seven_segment_test population_count_test is_geq_test 

test: all
	./test_all.sh

.PHONY: seven_segment_test \
		population_count_test \
		is_geq_test \
		bit_scan_reverse_test \
		is_power_of_2_test \
		log_of_power_of_2_test \
		equal_test \
		vector_equal_test \
		test all clean test
.DEFAULT_GOAL := all
