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
	ldr ptrn,=0b000111000 // save the sos morse code as a bit pattern
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
		
		/* turn led on */	
		setBit .req r3
		mov setBit,#1
		lsl setBit,pin // get gpio function offset
		str setBit,[gpioAddr,#0x1C] // turn led on
		
		.unreq pin
		.unreq setBit
		.unreq gpioAddr
		
		/* wait function, delay for time = delayDuration */
		delayDur .req r0
		teq val,#0
		ldreq delayDur,=250000
		ldrne delayDur,=750000
		.unreq val
		bl Wait
		.unreq delayDur
		
		pin .req r2
		val .req r1
		gpioAddr .req r0
		ldr gpioAddr,=0x3F200000
		
		mov pin,#17 // gpio pin 17
		setBit .req r3
		mov setBit,#1
		lsl setBit,pin // get gpio function offset
		str setBit,[gpioAddr,#0x28] // turn led off
		
		/* wait function, delay for time = delayDuration, here 0.25 sec */
		delayDur .req r0
		ldr delayDur,=250000
		bl Wait
		.unreq delayDur
		
		add seq,#1 // pointer of the pattern goes one up
		cmp seq,#8
		/* if the pointer is higher than 9 */
		movhi seq,#0 // pointer goes back to 0
		ldrhi r0,=750000 // delay of 0.75 sec
		blhi Wait
		
		b loop1$ // endless loop

.globl Wait
Wait:
	delayDur .req r2
	mov delayDur,r0
	timeAddr .req r0
	ldr timeAddr,=0x3F003000
	
	/* clear the the system timer compare 0 */
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
		ldr match,[timeAddr] // load system control and status register
		cmp match,#1
		bne loop3$

	.unreq match
	.unreq delayDur
	.unreq timeAddr
	mov pc,lr