#ifdef __x86_64__
#include <stdio.h>
#endif
#include "arrays.h"
#include "helpers.h"

unsigned int collatz(int x)__attribute__ ((weak, alias ("__collatz")));

unsigned int maximum(int* p, int n)__attribute__ ((weak, alias ("__maximum")));

unsigned int triangular(int x)__attribute__ ((weak, alias ("__triangular")));

void sort(int* p, int n)__attribute__ ((weak, alias ("__sort")));

const int NUMTESTS = 5;
int main(int argc, char* argv[]) {
    int retcode = -1;
    int arg = load_arg();
    int runOnce;
    if (arg < 1 || arg > NUMTESTS) {
        arg = 1;
        runOnce = 0;
    } else {
        runOnce = 1;
    }
    do {
        if (collatz != __collatz) {
            retcode = 0;
            int x;
            int correct;
            switch (arg) {
                case 1: x = 3; correct = 10; break;
                case 2: x = 6; correct = 3; break;
                case 3: x = 10; correct = 5; break;
                case 4: x = 25; correct = 76; break;
                case 5: x = 100; correct = 50; break;
                default: x = 3; break;
            }
          int result = collatz(x);
          print_int(result);
          print_char(':');
          if (result != correct) {
            print_string("Failed\n");
            retcode = -1;
          } else {
            print_string("Passed\n");
          }
        }
        if (maximum != __maximum) {
            retcode = 0;
            int *p, *t;
            int n;
            switch (arg) {
                case 1: p = array1; t = result1; n = 7; break;
                case 2: p = array2; t = result2; n = 6; break;
                case 3: p = array3; t = result3; n = 10; break;
                case 4: p = array4; t = result4; n = 20; break;
                case 5: p = array5; t = result5; n = 200; break;
                default: p = array1; t = result1; n = 7; break;
            }
          int result = maximum(p, n);
          print_int(result);
          print_char(':');
          if (result != t[n-1]) {
            print_string("Failed\n");
            retcode = -1;
          } else {
            print_string("Passed\n");
          }
        }


        if (triangular != __triangular) {
            retcode = 0;
            int x;
            int correct;
            switch (arg) {
                case 1: x = 3; correct = 6; break;
                case 2: x = 6; correct = 21; break;
                case 3: x = 10; correct = 55; break;
                case 4: x = 25; correct = 325; break;
                case 5: x = 100; correct = 5050; break;
                default: x = 3; break;
            }
          int result = triangular(x);
          print_int(result);
          print_char(':');
          if (result != correct) {
            print_string("Failed\n");
            retcode = -1;
          } else {
            print_string("Passed\n");
          }
        }

        if (sort != __sort) {
            retcode = 0;
            int *p, *t;
            int n;
            switch (arg) {
                case 1: p = array1; t = result1; n = 7; break;
                case 2: p = array2; t = result2; n = 6; break;
                case 3: p = array3; t = result3; n = 10; break;
                case 4: p = array4; t = result4; n = 20; break;
                case 5: p = array5; t = result5; n = 200; break;
                default: p = array1; t = result1; n = 7; break;
            }
          sort(p, n);
          for (int i = 0; i < n; i++) {
            print_int(p[i]);
            print_char(',');
          }
          print_char('\n');
          for (int i = 0; i < n; i++) {
            if (p[i] == t[i])
                print_char('g');
            else {
                print_char('b');
                retcode = -1;
            }
          }
          print_char('\n');
        }
        arg++;
    } while (runOnce == 0 && arg <= NUMTESTS);

  return retcode;
}
