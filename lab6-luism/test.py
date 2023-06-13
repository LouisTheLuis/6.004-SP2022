#!/usr/bin/env python3
import subprocess, glob, sys, itertools, argparse, collections
from typing import List, Dict, Optional, Callable
import os.path

def green(text: str) -> str:
    if sys.stdout.isatty():
        return "\x1b[32m{}\x1b[0m".format(text)
    else:
        return text
def red(text: str) -> str:
    if sys.stdout.isatty():
        return "\x1b[31m{}\x1b[0m".format(text)
    else:
        return text
def bold(text: str) -> str:
    if sys.stdout.isatty():
        return "\x1b[1m{}\x1b[0m".format(text)
    else:
        return text

def extensionless_basename(filename: str) -> str:
    filename = os.path.basename(filename)
    if "." in filename:
        filename = filename[:filename.index(".")]
    return filename

def get_dump_lines(text: str) -> List[str]:
    ret = []
    go = False
    for line in text.split("\n"):
        if "Dumping the state" in line:
            go = True
        if go:
            ret.append(line.strip())
    return ret

def run_test(processor: str, folder: str, test: str, timeout: Optional[int], do_print: bool) -> str:
    if do_print:
        print(bold("Running {}:".format(test)), end=" ")

    try: os.remove("mem.vmh")
    except IOError: pass
    os.symlink(os.path.join("sw", "build", folder, test + ".vmh"), "mem.vmh")

    result = subprocess.run([os.path.join(".", processor)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
    stdout = result.stdout.decode("utf-8", errors="replace")

    os.makedirs(os.path.join("test_out", folder), exist_ok=True)
    with open(os.path.join("test_out", folder, "{}.out".format(test)), "wb") as outfile:
        outfile.write(result.stdout)

    return stdout

def compare_print_microtest_dump(microtest: str, stdout: str, show_all: bool, hide_all: bool) -> bool:
    real_lines = get_dump_lines(stdout)

    try:
        with open("sw/microtests/{}.expected".format(microtest)) as infile:
            expected_lines = [line.strip() for line in infile.read().split("\n")]
    except IOError:
        print(red("No expected output found! Something is wrong, contact course staff."))
        expected_lines = []

    passed = True
    display_lines: List[str] = []
    for real, expected in itertools.zip_longest(real_lines, expected_lines):
        if real == expected:
            # Some lines that are just text are rather silly to mark as OK.  So
            # only print the lines with a "=" in them, which are the lines with
            # the register values we really care about.
            if "=" in real:
                display_lines.append("{} {}".format(real, green("\u2713 OK")))
            else:
                display_lines.append(real)
        else:
            display_lines.append("{} {}".format(real, red("\u2717 EXPECTED " + str(expected))))
            passed = False

    if (show_all or not passed) and not hide_all:
        print()
        for line in display_lines:
            print("  " + line)

        try:
            assembly_filename = os.path.join("sw", "microtests", microtest + ".S")
            print("  Description of test {} (from {}):".format(microtest, assembly_filename))
            with open(assembly_filename) as infile:
                for line in infile:
                    if line.startswith("//"):
                        print("  " + line.strip())
                    else:
                        break
        except IOError:
            print(red("Assembly source not found! Something is wrong, contact course staff."))

    return passed

def main():
    parser = argparse.ArgumentParser(description='Run tests for Lab 6.')
    # parser.add_argument('processor', type=str, nargs='?', help='which processor(s) to test')
    parser.add_argument('tests', type=str, nargs='?', help='which test(s) to run')
    parser.add_argument('--show-all', action='store_true', help='Show output even for passing tests')
    parser.add_argument('--didit', action='store_true', help='Didit output')
    parser.add_argument('--timeout', metavar='N', type=int, nargs='?', help='Make tests time out after N seconds')

    args = parser.parse_args()

    stdout_for_make = subprocess.DEVNULL if args.didit else 1
    subprocess.run(["make", "-C", "sw"], stdout=stdout_for_make, stderr=2)

    # if args.processor:
    #     response = args.processor
    # else:
    #     print("What processor do you want to test?")
    #     print("1) SingleCycle")
    #     print("2) MultiCycle")
    #     print("3) SingleCycle and MultiCycle")
    #     response = input()

    # if response == "1":
    #     processors = ["ProcSingleCycle"]
    # elif response == "2":
    #     processors = ["ProcMultiCycle"]
    # elif response == "3":
    #     processors = ["ProcSingleCycle", "ProcMultiCycle"]
    # else:
    #     print("FAILED Unexpected response:", response)
    #     sys.exit(1)
    processors = ["Processor"]

    for processor in processors:
        if not os.path.isfile(processor):
            print("FAILURE File", processor, "does not exist. Did you run `make Processor`?")
            sys.exit(1)
        if not os.access(processor, os.X_OK):
            print("FAILED File", processor, "exists but is not executable. This shouldn't happen but you might be able to fix it by running `chmod u+x " + processor + "`.")
            sys.exit(1)

    printed_choices: List[str] = []

    def collect_test_dict(folder, readable_name, key_all) -> Dict[str, List[str]]:
        ret = collections.defaultdict(list)
        ret[key_all] = []
        for test in sorted(glob.glob(os.path.join(".", "sw", "build", folder, "*.vmh"))):
            test = extensionless_basename(test)
            ret[test].append(test)
            if readable_name:
                printed_choices.append("{}) {} {}".format(test, readable_name, test))
            ret[key_all].append(test)
        return ret

    microtest_dict: Dict[str, List[str]] = collections.defaultdict(list)

    for microtest in sorted(glob.glob("./sw/build/microtests/*.vmh")):
        # parse "./sw/build/microtests/01_lui.vmh" into "01_lui"
        microtest = os.path.basename(microtest)
        assert "_" in microtest, "Unexpected microtest file name " + microtest

        # get the "01" part
        prefix = microtest[:microtest.index("_")]
        microtest_dict[prefix].append(microtest)
        # let people type "1" instead of "01"
        if prefix.startswith("0"):
            microtest_dict[prefix[1:]].append(microtest)
            printed_choices.append("{}) microtest {}".format(prefix[1:], microtest))
        else:
            printed_choices.append("{}) microtest {}".format(prefix, microtest))

        # let people type "05" for all of "05a", "05b", "05c", etc.
        if prefix[-1].isalpha():
            microtest_dict[prefix[:-1]].append(microtest)
        # combine the above
        if prefix.startswith("0") and prefix[-1].isalpha():
            microtest_dict[prefix[1:-1]].append(microtest)

        microtest_dict["a"].append(microtest)
        microtest_dict["all"].append(microtest)

    printed_choices.append("a) all microtests")

    fullasmtest_dict = collect_test_dict("fullasmtests", "full asm test", "f")
    printed_choices.append("f) full asm tests")

    quicksort_dict = collect_test_dict("quicksort", None, "q")
    printed_choices.append("q) quicksort (from lab 2)")

    if args.tests:
        response = args.tests
    elif args.didit:
        print("FAILED test.py missing test argument!")
        sys.exit(1)
    else:
        print("Which tests would you like to run?")
        print("1) microtest 01_lui")
        print("2) microtest 02_addi")
        print("3) microtest 03_add")
        print("4) microtest 04_bne")
        print("5) microtest 05a_jal, 05b_jal")
        print("6) microtest 06_auipc")
        print("7) microtest 07a_lw, 07b_lw")
        print("8) microtest 08a_sw, 08b_sw")
        print("9) microtest 09a_jalr, 09b_jalr, 09c_jalr")
        print("a) all microtests")
        print("f) full asm tests")
        print("q) quicksort (from lab 2)")
        print("Hit ENTER for more choices.")
        response = input()

        while response == "":
            for line in printed_choices:
                print(line)
            print("You can also specify multiple comma-separated tests.")

            response = input()

    microtests = []
    fullasmtests = []
    quicksorttests = []

    for token in response.split(","):
        token = token.strip()
        if token in microtest_dict:
            microtests.extend(microtest_dict[token])
        elif token in fullasmtest_dict:
            fullasmtests.extend(fullasmtest_dict[token])
        elif token in quicksort_dict:
            quicksorttests.extend(quicksort_dict[token])
        else:
            print("FAILED Unexpected response", response)
            sys.exit(1)

    passed_tests = []
    failed_tests = []

    def record_passed_or_failed(processor: str, test: str, passed: bool) -> None:
        if passed:
            if not args.didit:
                print(green("{}: PASSED".format(test)))
            passed_tests.append(test)
        else:
            if not args.didit:
                print(red("{}: FAILED".format(test)))
            failed_tests.append(test)

    def run_tests(processor: str, folder: str, readable_name: str, tests: List[str], checker: Callable[[str, str], bool]) -> None:
        if tests:
            if not args.didit:
                print(bold("Running {} {}".format(len(tests),
                    readable_name + "s" if len(tests) != 1 else readable_name)))

            for test in tests:
                test = extensionless_basename(test)
                try:
                    stdout = run_test(processor, folder, test, timeout=args.timeout, do_print=not args.didit)
                    passed = checker(test, stdout)
                except subprocess.TimeoutExpired:
                    print(red("{} timed out after {} seconds!".format(test, args.timeout)))
                    passed = False

                record_passed_or_failed(processor, test, passed)

    def check_microtest(test: str, stdout: str) -> bool:
        return compare_print_microtest_dump(test, stdout, show_all=args.show_all, hide_all=args.didit)

    def check_regular_test(_: str, stdout: str) -> bool:
        return ("PASSED" in stdout and
                "FAILED" not in stdout and
                "Dumping the" not in stdout)

    for processor in processors:
        run_tests(processor, "microtests",   "microtest",      microtests,     check_microtest)
        run_tests(processor, "fullasmtests", "full asm test",  fullasmtests,   check_regular_test)
        run_tests(processor, "quicksort",    "quicksort test", quicksorttests, check_regular_test)

    if not args.didit:
        print()
    final_messages = []
    if passed_tests:
        if args.didit:
            print(green("PASSED {} test{}".format(
                len(passed_tests),
                "s" if len(passed_tests) != 1 else "")))
        else:
            print(green("PASSED {} test{}: {}".format(
                len(passed_tests),
                "s" if len(passed_tests) != 1 else "",
                ", ".join(passed_tests))))
    if failed_tests:
        if args.didit:
            print(red("FAILED {} test{} starting with {}".format(
                len(failed_tests),
                "s" if len(failed_tests) != 1 else "",
                failed_tests[0])))
        else:
            print(red("FAILED {} test{}: {}".format(
                len(failed_tests),
                "s" if len(failed_tests) != 1 else "",
                ", ".join(failed_tests))))
        sys.exit(1)
    if not passed_tests and not failed_tests:
        print(red("FAILED No tests found! Is everything compiled?"))
        sys.exit(1)

if __name__ == "__main__":
    main()
