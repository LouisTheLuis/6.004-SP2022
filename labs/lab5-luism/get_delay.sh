#!/bin/bash
set -euo pipefail

# $1 e.g. TBPipelineMath.ms
# $2 e.g. PipelineMath

timeout 70s synth "$1" "$2" -l multisize | grep -E "Critical-path delay:" | grep -Eo "([0-9]+\.?[0-9]*)"
