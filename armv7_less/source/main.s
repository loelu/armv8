.section .init
.globl _start
_start:

b main

.section .text
main:
	mov sp,#0x8000 // move the stackpointer
	
	/* set alias */
	gpioAddr .req r0
	func .req r1
	ptrn .req r4
	pointer .req r5
	
	/* initialize the registers */
	ldr gpioAddr,=0x3F200000 // base address of the gpio
	mov func,#1
	ldr ptrn,=0b11111110101011000100010001101010 // save the sos morse code as a bit pattern
	mov pointer,#0 // pattern pointer starts at zero
	
	/* set gpio pin as an output */
	lsl func,#21 // 21-23 are the bits which are reserved for the function of the gpio pin 17
	str func,[gpioAddr,#4] // GPFSEL1 is at the gpioAddr with offset 4
	
	.unreq func
	.unreq gpioAddr
	
	
	loop1$:
		/* set alias */
		gpioAddr .req r0
		val .req r1
		pin .req r2
		
		/* initialize the registers */
		ldr gpioAddr,=0x3F200000
		mov val,#1
		mov pin,#17 // gpio pin 17
		
		/* Get the value of the bit where the pointer is at */
		lsl val,pointer
		and val,ptrn
		lsr val,pointer
		
		/* turn led off or on */
		func .req r3
		mov func,#1
		lsl func,pin // get gpio function offset
		
		teq val,#0 //check if the number in val is equal to 0
		streq func,[gpioAddr,#0x1C] // if teq is equal to 0, val is 0, function turn led on
		strne func,[gpioAddr,#0x28] // if teq is not equal to 0, val is 1, function turn led off
		
		.unreq val
		.unreq pin
		.unreq func
		.unreq gpioAddr
		
		/* wait function, delay for time = delayDuration */
		delayDur .req r2 
		timeAddr .req r0
		ldr timeAddr,=0x3F003000
		
		/* clear the the system-timer-compare 0 */
		clear .req r1
		mov clear,#0
		str clear,[timeAddr,#12]
		.unreq clear
		
		ldr delayDur,=250000 // delayDuration = 0.25 sec
		ldr r1,[timeAddr,#4] // get current time - lower bits
		add delayDur,delayDur,r1 // add the delay duration
		str delayDur,[timeAddr,#12] // store result to the compare register
		
		/* if the system timer counter is equal to the compare register it writes a 1 to the system timer control/status register */
		match .req r1	
		loop2$:
			ldr match,[timeAddr] // load system timer control/status register
			cmp match,#1
			bne loop2$

		.unreq match
		.unreq delayDur
		.unreq timeAddr
		
		add pointer,#1 // pointer of the pattern goes one up
		cmp pointer,#31
		movhi pointer,#0 // if the pointer is higher than 31 it goes back to 0
		
		b loop1$ // endless loop