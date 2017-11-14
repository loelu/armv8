.section .init
.globl _start
_start:   

ldr r0,=0x20200000
mov r1,#1
lsl r1,#21
str r1,[r0,#4]
mov r1,#1
lsl r1,#17
str r1,[r0,#28]
loop$:
b loop$