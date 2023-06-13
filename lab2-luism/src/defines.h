#define x0 ONLY_USE_NAMED_REGISTERS;
#define x1 ONLY_USE_NAMED_REGISTERS;
#define x2 ONLY_USE_NAMED_REGISTERS;
#define x3 ONLY_USE_NAMED_REGISTERS;
#define x4 ONLY_USE_NAMED_REGISTERS;
#define x5 ONLY_USE_NAMED_REGISTERS;
#define x6 ONLY_USE_NAMED_REGISTERS;
#define x7 ONLY_USE_NAMED_REGISTERS;
#define x8 ONLY_USE_NAMED_REGISTERS;
#define x9 ONLY_USE_NAMED_REGISTERS;
#define x10 ONLY_USE_NAMED_REGISTERS;
#define x11 ONLY_USE_NAMED_REGISTERS;
#define x12 ONLY_USE_NAMED_REGISTERS;
#define x13 ONLY_USE_NAMED_REGISTERS;
#define x14 ONLY_USE_NAMED_REGISTERS;
#define x15 ONLY_USE_NAMED_REGISTERS;
#define x16 ONLY_USE_NAMED_REGISTERS;
#define x17 ONLY_USE_NAMED_REGISTERS;
#define x18 ONLY_USE_NAMED_REGISTERS;
#define x19 ONLY_USE_NAMED_REGISTERS;
#define x20 ONLY_USE_NAMED_REGISTERS;
#define x21 ONLY_USE_NAMED_REGISTERS;
#define x22 ONLY_USE_NAMED_REGISTERS;
#define x23 ONLY_USE_NAMED_REGISTERS;
#define x24 ONLY_USE_NAMED_REGISTERS;
#define x25 ONLY_USE_NAMED_REGISTERS;
#define x26 ONLY_USE_NAMED_REGISTERS;
#define x27 ONLY_USE_NAMED_REGISTERS;
#define x28 ONLY_USE_NAMED_REGISTERS;
#define x29 ONLY_USE_NAMED_REGISTERS;
#define x30 ONLY_USE_NAMED_REGISTERS;
#define x31 ONLY_USE_NAMED_REGISTERS;

#define fp USE_THE_NAME_s0_INSTEAD_OF_fp;

//#define gp ONLY_USE_THE_a_REGISTERS;
//#define tp ONLY_USE_THE_a_REGISTERS;

#ifndef NO_CHECK

#define push(rs) sw rs, 0(gp); \
addi gp, gp, -4

#define call push(sp); \
push(s0); \
push(s1); \
push(s2); \
push(s3); \
push(s4); \
push(s5); \
push(s6); \
push(s7); \
push(s8); \
push(s9); \
push(s10); \
push(s11); \
jal ra, 

#define popAndCompare(rs) addi gp, gp, 4; \
lw tp, 0(gp); \
bne rs, tp, violation; \

#define ret popAndCompare(s11); \
popAndCompare(s10); \
popAndCompare(s9); \
popAndCompare(s8); \
popAndCompare(s7); \
popAndCompare(s6); \
popAndCompare(s5); \
popAndCompare(s4); \
popAndCompare(s3); \
popAndCompare(s2); \
popAndCompare(s1); \
popAndCompare(s0); \
popAndCompare(sp); \
jalr zero, 0(ra)

#endif
