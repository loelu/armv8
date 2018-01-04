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
	
	pinNum .req r0
	pinFunc .req r1
	mov pinNum,#25
	mov pinFunc,#0
	bl SetGpioFunction // set gpio pin as an input
	.unreq pinNum
	.unreq pinFunc

	loop$:
		eventNum .req r0
		mov eventNum,#25
		bl EventDetect
		pinVal .req r1
		mov pinVal,eventNum
		.unreq eventNum
		
		pinNum .req r0
		mov pinNum,#17
		bl SetGpio // turn led on or off
		.unreq pinNum
		.unreq pinVal

		delayDur .req r0
		ldr delayDur,=100000
		bl Wait // delay for time = delayDuration, here 0.1 sec
		.unreq delayDur
		
		b loop$ // endless loop