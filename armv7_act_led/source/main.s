.section .init
.globl _start
_start:

b main

.section .text
main:
	mov sp,#0x8000 // move the stackpointer
	pinNum .req r0
	pinFunc .req r1
	mov pinNum,#47
	mov pinFunc,#1
	bl SetGpioFunction // set gpio pin as an output
	.unreq pinNum
	.unreq pinFunc

	loop$:
		pinNum .req r0
		pinVal .req r1
		mov pinNum,#47
		mov pinVal,#0
		bl SetGpio // turn led on
		.unreq pinNum
		.unreq pinVal

		delayDur .req r0
		ldr delayDur,=100000
		bl Wait // delay for time = delayDuration
		.unreq delayDur

		pinNum .req r0
		pinVal .req r1
		mov pinNum,#47
		mov pinVal,#1
		bl SetGpio // turn led off
		.unreq pinNum
		.unreq pinVal

		delayDur .req r0
		ldr delayDur,=100000
		bl Wait // delay for time = delayDuration
		.unreq delayDur

		b loop$ // endless loop
