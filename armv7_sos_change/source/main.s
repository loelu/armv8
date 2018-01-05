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
	ldr gpioAddr,=0x3F200000
	mov func,#1
	ldr ptrn,=0b000111000 // save the sos morse code as a bit pattern
	mov pointer,#0 // pattern pointer starts at zero

	/* set gpio pin as an output */
	lsl func,#21 // 21-23 are the bits which are reserved for the function of the gpio pin 17
	str func,[gpioAddr,#4] // GPFSEL1 is at the gpioAddr with offset 4
	
	.unreq func
	.unreq gpioAddr
	
	loop1$:
		/* set alias */
		gpioAddr .req r0
		pin .req r2
		val .req r1
		
		/* initialize the registers */
		ldr gpioAddr,=0x3F200000
		mov pin,#17 // gpio pin 17
		mov val,#1
		
		/* Get the value of the bit where the pointer is at */
		lsl val,pointer
		and val,ptrn
		lsr val,pointer
		
		/* turn led on */	
		func .req r3
		mov func,#1
		lsl func,pin // get gpio function offset
		str func,[gpioAddr,#0x1C] // turn led on
		
		.unreq pin
		.unreq func
		.unreq gpioAddr
		
		/* wait function, delay for time = delayDuration */
		delayDur .req r0
		teq val,#0
		ldreq delayDur,=250000 // delayDuration = 0.25 sec, if val is equal 0
		ldrne delayDur,=750000 // delayDuration = 0.75 sec, if val is not equal 0, val is 1
		.unreq val
		bl Wait // function call
		.unreq delayDur
		
		/* set alias */
		pin .req r2
		func .req r3
		gpioAddr .req r0
		
		/* initialize registers */
		ldr gpioAddr,=0x3F200000
		mov pin,#17 // gpio pin 17
		mov func,#1
		
		/* turn led off */
		lsl func,pin // get gpio function offset
		str func,[gpioAddr,#0x28] // turn led off
		
		/* wait function, delay for time = delayDuration, here 0.25 sec */
		delayDur .req r0
		ldr delayDur,=250000
		bl Wait
		.unreq delayDur
		
		add pointer,#1 // pointer of the pattern goes one up
		cmp pointer,#8
		/* if the pointer is higher than 8 */
		movhi pointer,#0 // pointer goes back to 0
		ldrhi r0,=750000 // delay of 0.75 sec
		blhi Wait
		
		b loop1$ // endless loop

.globl Wait
Wait:
	delayDur .req r2
	mov delayDur,r0
	timeAddr .req r0
	ldr timeAddr,=0x3F003000
	
	/* clear the the system-timer-compare 0 */
	clear .req r1
	mov clear,#0
	str clear,[timeAddr,#12]
	.unreq clear
	
	ldr r1,[timeAddr,#4] // get current time - lower bits
	add delayDur,delayDur,r1 // add the delay duration
	str delayDur,[timeAddr,#12] // store result to the compare register
	
	/* if the system timer counter is equal to the compare register it writes a 1 to the system timer control/status register */
	match .req r1	
	loop3$:
		ldr match,[timeAddr] // load system control/status register
		cmp match,#1
		bne loop3$

	.unreq match
	.unreq delayDur
	.unreq timeAddr
	mov pc,lr // go back to where the function was called