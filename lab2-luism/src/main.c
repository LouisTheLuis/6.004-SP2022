#ifdef __x86_64__
#include <stdio.h>
#endif
#include "arrays.h"
#include "helpers.h"

unsigned int factorial(int x)__attribute__ ((weak, alias ("__factorial")));

void sort(int* p, int start, int end)__attribute__ ((weak, alias ("__sort")));

void kth_smallest(int *p)__attribute__ ((weak, alias ("__kth_smallest")));

unsigned int space[1] = {0};

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
        if (factorial != __factorial) {
            retcode = 0;
            int x;
            int correct;
            switch (arg) {
                case 1: x = 1; correct = 1; break;
                case 2: x = 3; correct = 6; break;
                case 3: x = 6; correct = 720; break;
                case 4: x = 10; correct = 3628800; break;
                case 5: x = 12; correct = 479001600; break;
                default: x = 3; break;
            }
          setup_shadow();
          int result = factorial(x);
          print_int(result);
          print_char(':');
          if (space[0] != 0xabababab && x > 1) {
            print_string("you need to use the mul that we give you\n");
            retcode = -1;
          }
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
                case 1: p = a1; t = r1; n = 7; break;
                case 2: p = a2; t = r2; n = 6; break;
                case 3: p = a3; t = r3; n = 10; break;
                case 4: p = a4; t = r4; n = 20; break;
                case 5: p = a5; t = r5; n = 200; break;
                default: p = a1; t = r1; n = 7; break;
            }
          setup_shadow();
          sort(p, 0, n-1);
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
#ifndef DIDIT
          // If not in Didit, run the keyboard-interactive portion
          setup_shadow();
          kth_smallest(p);
          print_char('\n');
#endif
        }
        arg++;
    } while (runOnce == 0 && arg <= NUMTESTS);

  return retcode;
}
