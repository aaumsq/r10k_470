/*
  This test was hand written by Joel VanLaven to put pressure on ROBs
  It generates and stores in order 64 32-bit pseudo-random numbers in 
  16 passes using 64-bit arithmetic.  (i.e. it actually generates 64-bit
  values and only keeps the more random high-order 32 bits).  The constants
  are from Knuth.  To be effective in testing the ROB the mult must take
  a while to execute and the ROB must be "small enough".  Assuming that
  there is any reasonably working form of branch prediction and that the
  Icache works and is large enough, multiple passes should end up going
  into the ROB at the same time increasing the efficacy of the test.  If
  for some reason the ROB is not filling with this test is should be
  easily modifiable to fill the ROB.

  In order to properly pass this test the pseudo-random numbers must be
  the correct numbers.
*/
        data = 0x1000
	      lda	$r0,data
        lda $r1,1
        lda $r2,2
        lda $r3,3
        lda $r4,4
        mulq    $r1,$r2,$r5
        mulq    $r1,$r2,$r6
        mulq    $r1,$r2,$r7
        mulq    $r1,$r2,$r8
        mulq    $r1,$r2,$r9
        mulq    $r1,$r2,$r10
        mulq    $r1,$r2,$r11
        mulq    $r1,$r2,$r12
        mulq    $r1,$r2,$r5
        mulq    $r1,$r2,$r6
        mulq    $r1,$r2,$r7
        mulq    $r1,$r2,$r8
        mulq    $r1,$r2,$r9
        mulq    $r1,$r2,$r10
        mulq    $r1,$r2,$r11
        mulq    $r1,$r2,$r12
	      stq     $r3,0($r0)
	      stq     $r3,8($r0)
	      stq     $r3,16($r0)
	      stq     $r3,24($r0)
        mulq    $r1,$r2,$r17
	      stq     $r3,32($r0)
	      stq     $r3,40($r0)
	      stq     $r3,48($r0)
        mulq    $r1,$r2,$r22
	      stq     $r3,56($r0)
        mulq    $r1,$r2,$r24
	call_pal        0x555
