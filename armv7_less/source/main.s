.section .init
.globl _start
_start:

b main

.section .text
main:
	mov sp,#0x8000 // move the stackpointer
	gpioAddr .req r0 // set alias
	ldr gpioAddr,=0x3F200000
	func .req r1
	mov func,#1
	
	/* set gpio pin as an output */
	lsl func,#21 // 21-23 are the bits which are reserved for the function of the gpio pin 17
	str func,[gpioAddr,#4] // GPSEL1 is at the gpioAddr with offset 4
	.unreq func
	.unreq gpioAddr
	
	
	ptrn .req r4
	ldr ptrn,=0b11111110101011000100010001101010 // save the sos morse code as a bit pattern
	seq .req r5
	mov seq,#0 // pattern pointer starts at zero

	loop1$:
		gpioAddr .req r0
		ldr gpioAddr,=0x3F200000
		pin .req r2
		val .req r1
		
		mov pin,#17 // gpio pin 17
		mov val,#1
		
		/* Get the value of the bit where the pointer is at */
		lsl val,seq
		and val,ptrn
		lsr val,seq
		
		/* turn led off or on */
		
		setBit .req r3
		mov setBit,#1
		lsl setBit,pin // get gpio function offset
		
		teq val,#0 //check if the number in val is equal to 0
		streq setBit,[gpioAddr,#0x1C] // if teq is true, val is 0, function turn led on
		strne setBit,[gpioAddr,#0x28] // if teq is false, val is 1, function turn led off
		
		.unreq val
		.unreq pin
		.unreq setBit
		.unreq gpioAddr
		
		/* wait function, delay for time = delayDuration, here 0.25 sec */
		delayDur .req r2 
		timeAddr .req r0
		ldr timeAddr,=0x3F003000
		
		/* clear the the system timer compare 0 */
		clear .req r1
		mov clear,#0
		str clear,[timeAddr,#12]
		.unreq clear
		
		ldr delayDur,=250000
		ldr r1,[timeAddr,#4] // get current time - lower bits
		add delayDur,delayDur,r1 // add the delay duration
		str delayDur,[timeAddr,#12] // store result to the compare register
		
		/* if the system timer counter is equal to the compare register it writes a 1 to the system timer control/status register */
		match .req r1	
		loop2$:
			ldr match,[timeAddr] // load system control and status register
			cmp match,#1
			bne loop2$

		.unreq match
		.unreq delayDur
		
		add seq,#1 // pointer of the pattern goes one up
		cmp seq,#32
		movhi seq,#0 // if the pointer is higher than 32 it goes back to 0
		
		b loop1$ // endless loop