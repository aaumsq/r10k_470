/*
	TEST PROGRAM #3: compute first 16 fibonacci numbers
			 with forwarding and stall conditions in the loop


	long output[16];
	
	void
	main(void)
	{
	  long i, fib;
	
	  output[0] = 1;
	  output[1] = 2;
	  for (i=2; i < 16; i++)
	    output[i] = output[i-1] + output[i-2];
	}
*/
	
	data = 0x1000
	lda     $r3,data      #207f1000
	lda     $r4,data+8    #209f1008
	lda     $r5,data+16   #20bf1010
	lda     $r9,2         #213f0002
	lda     $r1,1         #203f0001
	stq     $r1,0($r3)    #b4230000
	stq	$r1,0($r4)        #b4240000
loop:	ldq     $r1,0($r3)#a4230000
	ldq     $r2,0($r4)    #a4440000
	addq    $r2,$r1,$r2   #40410402
	addq    $r3,0x8,$r3   #40611403
	addq	$r4,0x8,$r4     #40811404
	addq    $r9,0x1,$r9   #41203409
	cmple   $r9,0xf,$r10  #4121fdaa
	stq     $r2,0($r5)    #b4450000
	addq    $r5,0x8,$r5   #40a11405
	bne     $r10,loop     #f55ffff6
	call_pal        0x555 #00000555
