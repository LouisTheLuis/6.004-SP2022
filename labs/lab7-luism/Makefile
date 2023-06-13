SHELL:=/bin/bash

test_helper: HelperTest.ms CacheHelpers.ms
	timeout 2m msc HelperTest.ms HelperTest
	mv HelperTest $@
	mv HelperTest.so $@.so

debug_DirectMappedMicrotest: DirectMappedCacheTB.ms DirectMappedCache.ms CacheHelpers.ms
	timeout 2m msc DirectMappedCacheTB.ms DirectMappedMicrotest
	mv DirectMappedMicrotest $@
	mv DirectMappedMicrotest.so $@.so

test_DirectMappedMicrotest: DirectMappedCacheTB.ms DirectMappedCache.ms CacheHelpers.ms
	timeout 2m msc DirectMappedCacheTB.ms DirectMappedMicrotestAutograde
	mv DirectMappedMicrotestAutograde $@
	mv DirectMappedMicrotestAutograde.so $@.so

debug_TwoWayMicrotest: TwoWayCacheTB.ms TwoWayCache.ms CacheHelpers.ms
	timeout 2m msc TwoWayCacheTB.ms TwoWayMicrotest
	mv TwoWayMicrotest $@
	mv TwoWayMicrotest.so $@.so

test_TwoWayMicrotest: TwoWayCacheTB.ms TwoWayCache.ms CacheHelpers.ms
	timeout 2m msc TwoWayCacheTB.ms TwoWayMicrotestAutograde
	mv TwoWayMicrotestAutograde $@
	mv TwoWayMicrotestAutograde.so $@.so

debug_DirectMappedBeveren: DirectMappedCacheTB.ms DirectMappedCache.ms CacheHelpers.ms
	timeout 2m msc DirectMappedCacheTB.ms DirectMappedBeveren
	mv DirectMappedBeveren $@
	mv DirectMappedBeveren.so $@.so

test_DirectMappedBeveren: DirectMappedCacheTB.ms DirectMappedCache.ms CacheHelpers.ms
	timeout 2m msc DirectMappedCacheTB.ms DirectMappedBeverenAutograde
	mv DirectMappedBeverenAutograde $@
	mv DirectMappedBeverenAutograde.so $@.so

debug_TwoWayBeveren: TwoWayCacheTB.ms TwoWayCache.ms CacheHelpers.ms
	timeout 2m msc TwoWayCacheTB.ms TwoWayBeveren
	mv TwoWayBeveren $@
	mv TwoWayBeveren.so $@.so

test_TwoWayBeveren: TwoWayCacheTB.ms TwoWayCache.ms CacheHelpers.ms
	timeout 2m msc TwoWayCacheTB.ms TwoWayBeverenAutograde
	mv TwoWayBeverenAutograde $@
	mv TwoWayBeverenAutograde.so $@.so

clean:
	rm -rf *.so *.bo \
	  test_helper \
	  debug_DirectMappedBeveren debug_DirectMappedMicrotest debug_TwoWayBeveren debug_TwoWayMicrotest \
	  test_DirectMappedBeveren test_DirectMappedMicrotest test_TwoWayBeveren test_TwoWayMicrotest

all: test_helper test_DirectMappedMicrotest test_TwoWayMicrotest test_DirectMappedBeveren test_TwoWayBeveren

test: all
	@./test_all

.PHONY: clean all test

.DEFAULT_GOAL := all
