.globl GetGpioAddress
GetGpioAddress: // return in r0 the gpio address
	ldr r0,=0x3F200000
	mov pc,lr // write adress of next instruction into the pc

.globl SetGpioFunction
SetGpioFunction: // paramater r0 which gpio pin and r1 which function
	pinNum .req r0 // set alias
	pinFunc .req r1
	cmp pinNum,#53 // check if input is correct, so pinNum <= 53 and pinFunc <= 7
	cmpls pinFunc,#7
	movhi pc,lr

	push {lr} // push value of lr on the top of the stack
	mov r2,pinNum
	.unreq pinNum
	pinNum .req r2
	bl GetGpioAddress
	gpioAddr .req r0

	functionLoop$: // get the Adress of the gpio for the function setting of the pin
		cmp pinNum,#9
		subhi pinNum,#10
		addhi gpioAddr,#4
		bhi functionLoop$

	add pinNum, pinNum,lsl #1 // multiplication pinNum x 3
	lsl pinFunc,pinNum
	.unreq pinNum
	str pinFunc,[gpioAddr]
	.unreq pinFunc
	.unreq gpioAddr
	pop {pc} // copy latest stack value into pc, same as mov pc,lr

.globl SetGpio
SetGpio: // parameter r0 which gpio pin and r1 which function (turn led off or on)
	pinNum .req r0
	pinVal .req r1

	cmp pinNum,#53
	cmpls pinVal,#1
	movhi pc,lr
	push {lr}
	mov r2,pinNum
	.unreq pinNum
	pinNum .req r2
	bl GetGpioAddress
	gpioAddr .req r0

	pinBank .req r3
	lsr pinBank,pinNum,#5 // divide pinNum by 32 and store result in pinBank
	lsl pinBank,#2
	add gpioAddr,pinBank // get gpio offset 0 or 1
	.unreq pinBank
	and pinNum,#31
	setBit .req r3
	mov setBit,#1
	lsl setBit,pinNum // get gpio function offset
	.unreq pinNum

	teq pinVal,#0 //check if the number in pinVal is equal to 0
	.unreq pinVal
	streq setBit,[gpioAddr,#0x1C] // if teq is true, pinVal is 0, function turn led on
	strne setBit,[gpioAddr,#0x28] // if teq is false, pinVal is 1, function turn led off
	.unreq setBit
	.unreq gpioAddr
	pop {pc}
	
.globl EventDetect
EventDetect: // parameter r0 which gpio pin, return r0 event detected (0 = no event detected, 1 = event detected)
	eventNum .req r0
	cmp eventNum,#53 // check if input is correct, so eventNum <= 53
	movhi pc,lr

	push {lr} // push value of lr on the top of the stack
	mov r1,eventNum
	.unreq eventNum
	eventNum .req r1
	bl GetGpioAddress
	gpioAddr .req r0

	pinBank .req r3
	lsr pinBank,eventNum,#5 // divide eventNum by 32 and store result in pinBank
	lsl pinBank,#2
	add gpioAddr,pinBank // get gpio offset 0 or 1
	.unreq pinBank
	and eventNum,#31
	setBit .req r3
	mov setBit,#1
	ldr r1,[gpioAddr,#0x34]
	lsl setBit,eventNum // get gpio function offset
	
	and setBit,r1
	lsr setBit,eventNum
	.unreq eventNum
	pinVal .req r0
	mov pinVal,setBit
	.unreq setBit
	.unreq gpioAddr
	.unreq pinVal
	pop {pc}

	
	