#!/usr/bin/env python3

import os
import subprocess
import sys
from typing import Any, List, Optional, Tuple
import yaml

def report_to_didit(data: str, endpoint: str) -> None:
    """
    Report data to didit, if the didit environment exists.
    Currently it checks if $REPORT_HOST exists.
    If it does not, do nothing.
    """
    is_unix_socket = True

    # Ensure that endpoint starts with "/"
    if not endpoint.startswith("/"):
        endpoint = "/" + endpoint

    if 'REPORT_HOST' in os.environ:
        socket_args: List[str] = []
        hostname: str = os.environ['REPORT_HOST']
        if is_unix_socket:
            socket_args = ["--unix-socket", "/report-sock"] # Max will update this to use $REPORT_HOST in the future
            hostname = "localhost"

        url = f"http://{hostname}{endpoint}"

        subprocess.check_output([
            "curl",
            "--silent",
        ] + socket_args + [
            "--data", data,
            url
        ])

class DiditTester:
    """
    Runs and reports tests to didit.
    """

    # Base "ID" used in reporting to didit
    BASE_ID: str = "unit"

    # ID for mandatory tests
    MANDATORY_TEST_ID: str = f"{BASE_ID}/class:Mandatory Tests"
    # ID for optional tests
    OPTIONAL_TEST_ID: str = f"{BASE_ID}/class:Optional Tests"

    def __init__(self, lab_id: str, mandatory_tests: List[Tuple[str, Optional[int]]], optional_tests: List[Tuple[str, Optional[int]]]) -> None:
        """
        :param lab_id: Lab ID e.g. "Lab1"
        :param mandatory_tests: A list of tests e.g. [("triangular", 1), ("bubblesort", 1)]
        :param optional_tests: A list of tests e.g. [("triangular", 1), ("bubblesort", 1)]
        """
        assert isinstance(lab_id, str)
        assert isinstance(mandatory_tests, list)
        assert isinstance(optional_tests, list)
        self.lab_id: str = lab_id
        self.mandatory_tests = mandatory_tests
        self.optional_tests = optional_tests
        if len(self.mandatory_tests) == 0:
            raise ValueError("No mandatory tests?")

    def run(self) -> None:
        """
        Run and report all tests.
        """
        # Signal start of testing
        report_to_didit(f"id={self.BASE_ID}", "/started")

        # Check discussion_questions.txt
        discussion_id: str = f"{self.MANDATORY_TEST_ID}/method:Discussion()"
        report_to_didit(f"id={discussion_id}", "/started")
        with open('discussion_questions.txt', 'r', encoding='utf-8') as f:  # pylint: disable=invalid-name
            discussion_questions_contents = str(f.read()).strip()
        cause_prefix: str = f"{self.lab_id}.Discussion"
        if len(discussion_questions_contents) > 100:
            print(f"{cause_prefix}: PASSED")
            report_to_didit(f"id={discussion_id}&cause=", "/finished/successful")
        else:
            cause=f"{cause_prefix}: FAILED less than 100 chars in discussion_questions.txt - put your discussion answers into this file"
            print(cause)
            report_to_didit(f"id={discussion_id}&cause={cause}", "/finished/failed")

        # Mandatory tests
        report_to_didit(f"id={self.MANDATORY_TEST_ID}&description=You must pass all tests in this section before checkoff.", "/started")
        for test_name, test_num in self.mandatory_tests:
            self.grade_test(self.MANDATORY_TEST_ID, test_name, test_num)

        # Optional tests
        if len(self.optional_tests) > 0:
            report_to_didit(f"id={self.OPTIONAL_TEST_ID}&description=To earn full credit for the lab, pass these additional tests.", "/started")
            for test_name, test_num in self.optional_tests:
                self.grade_test(self.OPTIONAL_TEST_ID, test_name, test_num)

        # End mandatory tests
        report_to_didit(f"id={self.MANDATORY_TEST_ID}", "/finished/successful")

        # End optional tests
        if len(self.optional_tests) > 0:
            report_to_didit(f"id={self.OPTIONAL_TEST_ID}", "/finished/successful")

        # Signal end of testing
        report_to_didit(f"id={self.BASE_ID}", "/finished/successful")

    def grade_test(self, class_id: str, test_name: str, test_num: Optional[int]) -> None:
        """
        :param class_id: Didit class ID
        :param test_name: Name of test (also used for .vmh file and test_ script)
        :param test_num: Test number to run (or None to pass in no test number parameter)
        """

        test_binary: str = f"./test_{test_name}"

        # Construct proper ID for this specific test
        test_name_with_num: str = test_name
        if test_num is not None:
            test_name_with_num = test_name_with_num + str(test_num)

        id_test: str = f"{class_id}/method:{test_name_with_num}()"
        report_to_didit(data=f"id={id_test}", endpoint="/started")

        cause_prefix: str = f"{self.lab_id}.{test_name_with_num}"

        # Don't pass test_num if not present
        args = [
            "timeout", "75s", test_binary,
        ] + ([str(test_num)] if test_num is not None else [])

        result: str = ""
        cause: str = ""
        stdout: str = ""
        if not os.path.exists(test_binary):
            result = "aborted"
            cause = f"{self.lab_id}.{class_id}: {test_name_with_num} FAILED COMPILATION ERROR"
        else:
            process = subprocess.run(args, stdout=subprocess.PIPE, check=False, shell=False)
            stdout = process.stdout.decode("utf-8")

            if process.returncode == 124:
                result = "aborted"
                cause = f"FAILED {test_name_with_num} SIM TIMEOUT"
            elif process.returncode != 0:
                result = "aborted"
                cause = f"FAILED {test_name_with_num} SIM ERROR WITH CODE {process.returncode}"
            elif "FAILED" in stdout:
                result = "failed"
                cause = "\n".join(filter(lambda x: "FAILED" in x, stdout.split("\n")))
            elif "PASSED" in stdout:
                result = "successful"
                cause = "\n".join(filter(lambda x: "PASSED" in x, stdout.split("\n")))
                stdout = ""
            else:
                result = "aborted"
                cause = "FAILED - UNKNOWN PROBLEM, report to staff"

        print(cause)

        # Omit cause for passes (for cleaner Didit results)
        if result == "successful":
            cause = ""
        else:
            cause = cause_prefix + ": " + cause
        report_to_didit(f"id={id_test}&cause={cause}&sysout={stdout}", f"/finished/{result}")

def main(argv: List[str]) -> int:
    """
    Main function.
    """

    # Read test_info.yml
    filename = 'test_info.yml'
    if len(argv) >= 2:
        filename = str(argv[1])

    with open(filename, 'r') as f:  # pylint: disable=invalid-name
        data = yaml.safe_load(f)

    lab_id = str(data['lab_id'])
    def test_row(row: List[Any]) -> Tuple[str, Optional[int]]:
        test_num: Optional[int] = None
        if row[1] is not None:
            test_num = int(row[1])
        return (str(row[0]), test_num)

    mandatory_tests: List[Tuple[str, Optional[int]]] = list(map(test_row, data['mandatory_tests']))
    optional_tests: List[Tuple[str, Optional[int]]] = list(map(test_row, data['optional_tests']))

    DiditTester(lab_id, mandatory_tests, optional_tests).run()
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
