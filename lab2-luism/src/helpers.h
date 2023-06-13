volatile int x;
volatile int y;
volatile int z;

#ifdef __x86_64__
void print_char(int x) {
    printf("%c", (char) x);
}
void print_string(char* s) {
    printf("%s", s);
}

int load_arg() {
    return 0;
}
#else /* Risc-v */
void print_char(int x);
void violation();
void setup_shadow();
// This is much more complicated than it should be to avoid using
// unimplemented half-word and byte loads.
void print_string(char* s) {
    int *s_intptr = (int*) (~3 & (int) s);
    int word = 0;
    int offset = ((int) s) & 3;
    int cur_char = 0xff & (s_intptr[word] >> (offset << 3));
    while (cur_char != '\0') {
        print_char(cur_char);
        if (offset == 3) {
            word++;
            offset = 0;
        } else {
            offset++;
        }
        cur_char = 0xff & (s_intptr[word] >> (offset << 3));
    }
    return;
}


const int LIMIT = 10;
void print_int(int a) {
    int bases[LIMIT];
    bases[0] = 1;
    int i = 0;
    for (i = 1; i < LIMIT; i++) {
        bases[i] = bases[i - 1] * 10;
    }
    i = 0;
    if (a == 0) {
        print_char('0');
    } else if (a == 0x80000000) {
        print_string("-2147483648");
    } else {
        if (a < 0) {
            print_char('-');
            a = -a;
        }
        int j = LIMIT - 1;
        while (a < bases[j]) j--;
        while (j >= 0) {
            int d = 0;
            while (a >= bases[j]) {
                a -= bases[j];
                d ++;
            }
            print_char('0' + d);
            j--;
        }
    }
}
int load_arg();

void print_error() {
    print_string("You violated calling convention in a function that was called from ");
}
#endif

unsigned int __factorial(int x) {
    return 0;
}

void __sort(int* p, int start, int end) {
    return;
}

void __kth_smallest(int *p) {
    return;
}
