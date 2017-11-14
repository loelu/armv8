.section .init
.globl _start
_start:   

ldr r0,=0x3F200000
mov r1,#1
lsl r1,#21
str r1,[r0,#4]

loop$:	  
mov r1,#1
lsl r1,#17
str r1,[r0,#28]

mov r2,#0x3F0000
wait1$:
sub r2,#1
cmp r2,#0
bne wait1$

mov r1,#1
lsl r1,#17
str r1,[r0,#40]

mov r2,#0x3F0000
wait2$:
sub r2,#1
cmp r2,#0
bne wait2$

b loop$
