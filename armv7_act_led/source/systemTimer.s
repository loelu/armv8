.globl GetTimerAddress
	GetTimerAddress:
	ldr r0,=0x3F003000
	mov pc,lr

.globl GetTimeStamp
	GetTimeStamp:
	push {lr}
	bl GetTimerAddress
	ldrd r0,r1,[r0,#4] // save the 8bit counter in the register r0 and r1
	pop {pc}

	.globl Wait
	Wait: // system timer description is on p. 172
	delayDur .req r2 
	mov delayDur,r0
	push {lr}
	bl GetTimeStamp
	start .req r3
	mov start,r0 // save the waiting-start-time

	loop$:
		bl GetTimeStamp
		elapsed .req r1
		sub elapsed,r0,start // subtract the start-time from the connected new Timestamp
		cmp elapsed,delayDur // if elapsed time is greater than the setted delay duration the loop ends
		.unreq elapsed
		bls loop$

	.unreq delayDur
	.unreq start
	pop {pc}