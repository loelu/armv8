.section .init
.globl _start
_start:

b main

.section .text
main:
	mov sp,#0x8000 // move the stackpointer
	pinNum .req r0
	pinFunc .req r1
	mov pinNum,#17
	mov pinFunc,#1
	bl SetGpioFunction // set gpio pin as an output
	.unreq pinNum
	.unreq pinFunc
	
	ptrn .req r4
	ldr ptrn,=sos
	ldr ptrn,[ptrn]
	seq .req r5
	mov seq,#0

	loop$:
		pinNum .req r0
		mov pinNum,#17
		pinVal .req r1
		mov pinVal,#1
		lsl pinVal,seq
		and pinVal,ptrn
		lsr pinVal,seq
		bl SetGpio // turn led on or off
		.unreq pinNum
		.unreq pinVal

		delayDur .req r0
		ldr delayDur,=250000
		bl Wait // delay for time = delayDuration, here 0.25 sec
		.unreq delayDur
		
		add seq,#1 // pointer of the pattern goes one up
		and seq,#0b11111 // if seq is greater than 31 it will set back to 0
		
		b loop$ // endless loop


.section .data
.align 2
sos:
	.int 0b11111110101011000100010001101010
cat:
	.int 0b11111111100011000101101000101000