      data = 0x1000        
        lda     $r1,1       #32	203f0001
        lda     $r27,0      #33	237f0000
        lda     $r2,data    #34	205f1000   b1
        ldq    $r4,0($r2)   #35	a4820000
        ldq    $r5,8($r2)   #36	a4a20008   b2
        ldq    $r6,16($r2)  #37	a4c20010
        ldq    $r7,24($r2)  #38	a4e20018   b3
        ldq    $r8,32($r2)  #39	a5020020
        ldq    $r9,40($r2)  #40	a5220028   b4
        ldq    $r10,48($r2) #41	a5420030
        ldq    $r11,56($r2) #42	a5620038   b5
        ldq    $r12,64($r2) #43	a5820040
        ldq    $r13,72($r2) #44	a5a20048   b6
        stq    $r1,0($r2)   #45	b4220000
        stq    $r1,8($r2)   #46	b4220008
        stq    $r1,16($r2)  #47	b4220010
        stq    $r1,24($r2)  #48	b4220018
        stq    $r1,32($r2)  #49	b4220020
        stq    $r1,40($r2)  #50	b4220028
        stq    $r1,48($r2)  #51	b4220030
        stq    $r1,56($r2)  #52	b4220038
        stq    $r1,64($r2)  #53	b4220040
        stq    $r1,72($r2)  #54	b4220048
        addq    $r1,1,$r1   #55	40203401
        addq    $r27,8,$r27 #56	4361141b
        jsr     $r26,($r27) #    6b5b4000
	call_pal        0x555