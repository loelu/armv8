.globl GetTimerAddress
GetTimerAddress: // return in r0 timer address
	ldr r0,=0x3F003000
	mov pc,lr

.globl GetTimeStamp
GetTimeStamp: // return in r0 and r1 the timestamp
	push {lr}
	bl GetTimerAddress
	ldrd r0,r1,[r0,#4] // save the 8byte counter in the register r0 and r1
	pop {pc}

.globl Wait
Wait: // parameter r0 delay duration
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