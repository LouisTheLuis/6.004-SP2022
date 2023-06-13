#!/bin/bash

LABNUM=Lab3
COMP_FAIL_MSG=" - COMPILE ERROR"

ID_BASE="unit"
ID_MAND="${ID_BASE}/class:Mandatory Tests"
ID_OPT="${ID_BASE}/class:Optional Tests"

function grade_test {
    # Arguments:
    #   $1: Didit class ID
    #   $2: Name of test
    #   $3: Executable to run

    ID_TEST="$1/method:$2()"

    if [ ! -f ./$3 ]; then
	RESULT=aborted
        CAUSE="$LABNUM.$2: FAILED${COMP_FAIL_MSG}"
    else
        temp_out=$(timeout 90s ./$3)
        sim_exit_code=${PIPESTATUS[0]}
        if [ $sim_exit_code -eq 124 ] ; then
	    RESULT=aborted
            CAUSE="$LABNUM.$2: FAILED - SIM TIMEOUT"
        elif [ $sim_exit_code -ne 0 ] ; then
	    RESULT=aborted
            CAUSE="$LABNUM.$2: FAILED - SIM ERROR"
        elif echo "$temp_out" | grep -q FAILED; then
	    RESULT=failed
            CAUSE="$(echo "$temp_out" | grep -e FAILED)"
        elif echo "$temp_out" | grep -q PASSED; then
	    RESULT=successful
            CAUSE="$(echo "$temp_out" | grep -e PASSED)"
        else
	    RESULT=aborted
            CAUSE="$LABNUM.$2: FAILED - UNKNOWN PROBLEM, report to staff"
        fi
    fi

    echo "$CAUSE"
    # Don't send a CAUSE to Didit if we passed the test
    if [[ "$RESULT" == "successful" ]]; then CAUSE=""; fi
}

# Signal start of testing

# Mandatory Tests
grade_test "${ID_MAND}" bit_scan_reverse_test bit_scan_reverse_test
grade_test "${ID_MAND}" is_power_of_2_test is_power_of_2_test
grade_test "${ID_MAND}" log_of_power_of_2_test log_of_power_of_2_test
grade_test "${ID_MAND}" equal_test equal_test
grade_test "${ID_MAND}" vector_equal_test vector_equal_test
grade_test "${ID_MAND}" seven_segment_test seven_segment_test
grade_test "${ID_MAND}" population_count_test population_count_test
grade_test "${ID_MAND}" is_geq_test is_geq_test

# Check discussion_questions.txt
ID_TEST="${ID_MAND}/method:Discussion()"
if [[ `wc -c < ./discussion_questions.txt` -gt 100 ]]; then
    echo "$LABNUM.Discussion: PASSED"
else
    CAUSE="$LABNUM.Discussion: FAILED less than 100 chars in discussion_questions.txt - put your discussion answers into this file"
    echo $CAUSE
fi


# Signal end of testing
## 'true' prevents this script from returning bad status when REPORT_HOST is not set
