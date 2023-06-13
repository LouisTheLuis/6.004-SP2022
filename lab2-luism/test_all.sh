#!/bin/bash

LABNUM=Lab2

ID_BASE="unit"
ID_MAND="${ID_BASE}/class:Mandatory Tests"
ID_OPT="${ID_BASE}/class:Optional Tests"

function grade_test {
    # Arguments:
    #   $1: Didit class ID
    #   $2: Name of test (also used for .vmh file and test_ script)
    #   $3: Test number to run

    # Construct proper ID for this specific test
    ID_TEST="$1/method:$2$3()"

    if [[ ! -f ./$2.vmh ]]; then
	RESULT=aborted
        CAUSE="$LABNUM.$1: FAILED COMPILATION ERROR"
    else
        #local temp_out=$(timeout 30s rv_sim $2 $3)
        temp_out=$(timeout 30s ./test_$2 $3)
        sim_exit_code=${PIPESTATUS[0]}
        if [ $sim_exit_code -eq 124 ] ; then
	    RESULT=aborted
            CAUSE="$LABNUM.$2$3: FAILED SIM TIMEOUT"
	    STDOUT=$temp_out
        elif [ $sim_exit_code -ne 0 ] ; then
	    RESULT=aborted
            CAUSE="$LABNUM.$2$3: FAILED SIM ERROR"
	    STDOUT=$temp_out
        elif echo "$temp_out" | grep -q FAILED; then
	    RESULT=failed
            CAUSE="$(echo "$temp_out" | grep $LABNUM | grep FAILED)"	    
	    STDOUT=$temp_out
        elif echo "$temp_out" | grep -q PASSED; then
	    RESULT=successful
            CAUSE="$(echo "$temp_out" | grep $LABNUM | grep PASSED)"	    
	    STDOUT=""
        else
	    RESULT=aborted
            CAUSE="$LABNUM.$2$3: FAILED - UNKNOWN PROBLEM, report to staff"
	    STDOUT=$temp_out
        fi
    fi

    echo $CAUSE
    # Omit cause for passes (for cleaner Didit results)
    if [[ $RESULT == "successful" ]]; then CAUSE=""; fi
}

# Signal start of testing

# Mandatory Tests
grade_test "${ID_MAND}" factorial 1
grade_test "${ID_MAND}" factorial 2
grade_test "${ID_MAND}" factorial 3
grade_test "${ID_MAND}" factorial 4
grade_test "${ID_MAND}" factorial 5
grade_test "${ID_MAND}" quicksort 1
grade_test "${ID_MAND}" quicksort 2
grade_test "${ID_MAND}" quicksort 3
grade_test "${ID_MAND}" quicksort 4
grade_test "${ID_MAND}" quicksort 5

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
