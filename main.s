;;;-----------------------------------------
;;; Start MC68HC11 gcc assembly output
;;; gcc compiler 3.3.6-m68hc1x-20060122
;;; Command:	\hc11\\lib\gcc-lib\m6811-elf\3.3.6-m68hc1x-20060122\cc1.exe -quiet -iprefix F:\hc11\m6811-elf\bin/../lib/gcc-lib/m6811-elf\3.3.6-m68hc1x-20060122\ -D__GNUC__=3 -D__GNUC_MINOR__=3 -D__GNUC_PATCHLEVEL__=6 -Dmc68hc1x -D__mc68hc1x__ -D__mc68hc1x -D__INT__=32 -Dmc6811 -DMC6811 -Dmc68hc11 main.c -quiet -dumpbase main.c -auxbase main -o main.s
;;; Compiled:	Wed Jun 07 20:40:26 2006
;;; (META)compiled by GNU C version 3.3.2.
;;;-----------------------------------------
	.file	"main.c"
	.mode mlong
	.sect	.text
	.globl	timer
	.type	timer,@function
	.interrupt	timer
timer:
	ldx	*_.frame
	pshx
	ldx	*_.tmp
	pshx
	ldx	*_.z
	pshx
	ldx	*_.xy
	pshx
	sts	*_.frame
	ldab	time+2
	cmpb	#59
	bls	.L1
	clrb
	stab	time+2
	inc	time+1
	ldab	time+1
	cmpb	#59
	bls	.L1
	clrb
	stab	time+1
	inc	time
	ldab	time
	cmpb	#23
	bls	.L1
	clrb
	stab	time
.L1:
	pulx
	stx	*_.xy
	pulx
	stx	*_.z
	pulx
	stx	*_.tmp
	pulx
	stx	*_.frame
	rti
	.size	timer, .-timer
	; extern	_io_ports
	.globl	interrupt_sci
	.type	interrupt_sci,@function
	.interrupt	interrupt_sci
interrupt_sci:
	ldx	*_.frame
	pshx
	ldx	*_.tmp
	pshx
	ldx	*_.z
	pshx
	ldx	*_.xy
	pshx
	tsx
	xgdx
	addd	#-12
	xgdx
	txs
	sts	*_.frame
	ldab	_io_ports+46
	ldx	#0
	clra
	anda	#0
	andb	#32
	ldx	#0
	ldy	*_.frame
	std	3,y
	stx	1,y
	ldx	*_.frame
	ldx	1,x
	cpx	#0
	bne	.L7
	ldy	*_.frame
	ldd	3,y
	cpd	#0
	beq	.L6
.L7:
	ldab	sciRecvTail
	ldy	*_.frame
	clr	7,y
	stab	8,y
	clr	6,y
	clr	5,y
	ldx	#0
	clra
	ldab	sciRecvHead
	subd	#1
	bcc	.L16
	dex
.L16:
	ldy	*_.frame
	std	11,y
	stx	9,y
	ldy	*_.frame
	ldd	5,y
	cpd	9,y
	bne	.L9
	ldy	*_.frame
	ldd	7,y
	cpd	11,y
	beq	.L5
.L9:
	ldab	sciRecvTail
	clra
	pshb
	psha
	pulx
	xgdx
	addd	#SCI_RECV_BUFFER
	xgdx
	ldab	_io_ports+47
	stab	0,x
	inc	sciRecvTail
	ldab	sciRecvTail
	cmpb	#0
	bge	.L5
	clrb
	stab	sciRecvTail
	bra	.L5
.L6:
	ldab	_io_ports+46
	cmpb	#0
	bge	.L5
	ldab	sciSendHead
	cmpb	sciSendTail
	beq	.L13
	ldab	sciSendHead
	clra
	addd	#SCI_SEND_BUFFER
	inc	sciSendHead
	std	*_.tmp
	ldy	*_.tmp
	ldab	0,y
	stab	_io_ports+47
	ldab	sciSendHead
	cmpb	#0
	bge	.L13
	clrb
	stab	sciSendHead
.L13:
	ldab	sciSendHead
	cmpb	sciSendTail
	bne	.L5
	clrb
	stab	sciSendTail
	clrb
	stab	sciSendHead
	ldab	_io_ports+45
	andb	#127
	stab	_io_ports+45
.L5:
	tsx
	xgdx
	addd	#12
	xgdx
	txs
	pulx
	stx	*_.xy
	pulx
	stx	*_.z
	pulx
	stx	*_.tmp
	pulx
	stx	*_.frame
	rti
	.size	interrupt_sci, .-interrupt_sci
	.globl	getc
	.type	getc,@function
getc:
	ldx	*_.frame
	pshx
	des
	sts	*_.frame
	ldab	sciRecvHead
	cmpb	sciRecvTail
	beq	.L18
; Begin inline assembler code
#APP
	sei
; End of inline assembler code
#NO_APP
	ldab	sciRecvHead
	clra
	addd	#SCI_RECV_BUFFER
	inc	sciRecvHead
	pshb
	psha
	pulx
	ldab	0,x
	ldy	*_.frame
	stab	1,y
	ldab	sciRecvHead
	cmpb	#0
	bge	.L19
	clrb
	stab	sciRecvHead
.L19:
; Begin inline assembler code
#APP
	cli
; End of inline assembler code
#NO_APP
	bra	.L20
.L18:
	clrb
	stab	sciRecvTail
	clrb
	stab	sciRecvHead
	clrb
	ldy	*_.frame
	stab	1,y
.L20:
	ldy	*_.frame
	ldx	#0
	clra
	ldab	1,y
	ins
	puly
	sty	*_.frame
	rts
	.size	getc, .-getc
	.globl	putc
	.type	putc,@function
putc:
	ldx	*_.frame
	pshx
	tsx
	xgdx
	addd	#-9
	xgdx
	txs
	sts	*_.frame
	ldx	*_.frame
	stab	1,x
; Begin inline assembler code
#APP
	sei
; End of inline assembler code
#NO_APP
	ldab	sciSendHead
	cmpb	sciSendTail
	bne	.L22
	ldab	_io_ports+46
	cmpb	#0
	bge	.L22
	ldy	*_.frame
	ldab	1,y
	stab	_io_ports+47
	bra	.L23
.L22:
	ldab	sciSendTail
	ldy	*_.frame
	clr	4,y
	stab	5,y
	clr	3,y
	clr	2,y
	ldx	#0
	clra
	ldab	sciSendHead
	subd	#1
	bcc	.L27
	dex
.L27:
	ldy	*_.frame
	std	8,y
	stx	6,y
	ldy	*_.frame
	ldd	2,y
	cpd	6,y
	bne	.L25
	ldy	*_.frame
	ldd	4,y
	cpd	8,y
	beq	.L23
.L25:
	ldab	sciSendTail
	clra
	pshb
	psha
	pulx
	xgdx
	addd	#SCI_SEND_BUFFER
	xgdx
	ldy	*_.frame
	ldab	1,y
	stab	0,x
	inc	sciSendTail
	ldab	sciSendTail
	cmpb	#0
	bge	.L23
	clrb
	stab	sciSendTail
.L23:
; Begin inline assembler code
#APP
	cli
; End of inline assembler code
#NO_APP
	ldab	_io_ports+45
	orab	#-128
	stab	_io_ports+45
	tsx
	xgdx
	addd	#9
	xgdx
	txs
	pulx
	stx	*_.frame
	rts
	.size	putc, .-putc
	.globl	strlen
	.type	strlen,@function
strlen:
	ldx	*_.frame
	pshx
	pshx
	pshx
	pshx
	pshx
	sts	*_.frame
	ldx	*_.d1
	pshx
	ldx	*_.d2
	pshx
	ldx	*_.frame
	std	1,x
	ldy	*_.frame
	clr	6,y
	clr	5,y
	clr	4,y
	clr	3,y
.L29:
	ldx	*_.frame
	ldx	5,x
	stx	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldy	*_.frame
	ldd	1,y
	addd	*_.d2
	ldx	*_.frame
	std	7,x
	ldy	*_.frame
	ldy	7,y
	ldab	0,y
	cmpb	#0
	bne	.L31
	bra	.L30
.L31:
	ldy	*_.frame
	ldd	5,y
	ldx	3,y
	addd	#1
	bcc	.L33
	inx	
.L33:
	ldy	*_.frame
	std	5,y
	stx	3,y
	bra	.L29
.L30:
	ldy	*_.frame
	ldd	5,y
	std	*_.d2
	ldd	3,y
	std	*_.d1
	ldd	*_.d2
	ldx	*_.d1
	puly
	sty	*_.d2
	puly
	sty	*_.d1
	puly
	puly
	puly
	puly
	puly
	sty	*_.frame
	rts
	.size	strlen, .-strlen
	.globl	write
	.type	write,@function
write:
	ldx	*_.frame
	pshx
	pshx
	sts	*_.frame
	ldx	*_.frame
	std	1,x
.L35:
	ldy	*_.frame
	ldx	1,y
	ldab	0,x
	cmpb	#0
	bne	.L37
	bra	.L34
.L37:
	ldy	*_.frame
	ldx	1,y
	ldab	0,x
	inx
	ldy	*_.frame
	stx	1,y
	bsr	putc
	bra	.L35
.L34:
	pulx
	pulx
	stx	*_.frame
	rts
	.size	write, .-write
	.section	.rodata
.LC0:
	.string	"# "
	.sect	.text
	.globl	shell_prompt
	.type	shell_prompt,@function
shell_prompt:
	ldx	*_.frame
	pshx
	sts	*_.frame
	ldd	#.LC0
	bsr	write
	pulx
	stx	*_.frame
	rts
	.size	shell_prompt, .-shell_prompt
	.globl	puts
	.type	puts,@function
puts:
	ldx	*_.frame
	pshx
	pshx
	pshx
	pshx
	pshx
	sts	*_.frame
	ldx	*_.d1
	pshx
	ldx	*_.d2
	pshx
	ldx	*_.frame
	std	1,x
	ldy	*_.frame
	clr	6,y
	clr	5,y
	clr	4,y
	clr	3,y
.L40:
	ldx	*_.frame
	ldx	5,x
	stx	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldy	*_.frame
	ldd	1,y
	addd	*_.d2
	ldx	*_.frame
	std	7,x
	ldy	*_.frame
	ldy	7,y
	ldab	0,y
	cmpb	#0
	bne	.L43
	ldab	#13
	bsr	putc
	ldab	#10
	bsr	putc
	bra	.L39
.L43:
	ldx	*_.frame
	ldx	5,x
	stx	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldy	*_.frame
	ldd	1,y
	addd	*_.d2
	pshb
	psha
	pulx
	ldab	0,x
	bsr	putc
	ldy	*_.frame
	ldd	5,y
	ldx	3,y
	addd	#1
	bcc	.L44
	inx	
.L44:
	ldy	*_.frame
	std	5,y
	stx	3,y
	bra	.L40
.L39:
	pulx
	stx	*_.d2
	pulx
	stx	*_.d1
	pulx
	pulx
	pulx
	pulx
	pulx
	stx	*_.frame
	rts
	.size	puts, .-puts
	.globl	strcmp
	.type	strcmp,@function
strcmp:
	ldx	*_.frame
	pshx
	pshx
	pshx
	sts	*_.frame
	ldx	*_.d1
	pshx
	ldx	*_.d2
	pshx
	ldx	*_.frame
	std	1,x
.L46:
	ldy	*_.frame
	ldx	1,y
	ldab	0,x
	cmpb	#0
	beq	.L47
	ldy	*_.frame
	ldx	1,y
	stx	*_.xy
	ldx	*_.frame
	ldy	9,x
	stx	*_.z
	ldx	*_.xy
	ldab	0,x
	cmpb	0,y
	beq	.L48
	bra	.L47
.L48:
	ldx	*_.frame
	ldd	1,x
	addd	#1
	ldy	*_.frame
	std	1,y
	ldy	*_.frame
	ldd	9,y
	addd	#1
	ldx	*_.frame
	std	9,x
	sty	*_.z
	bra	.L46
.L47:
	ldy	*_.frame
	ldx	1,y
	clra
	ldab	0,x
	ldx	#0
	stx	*_.xy
	ldx	*_.frame
	ldy	9,x
	sty	3,x
	stx	*_.z
	ldx	*_.xy
	stx	*_.xy
	ldx	*_.frame
	ldx	3,x
	xgdy
	ldab	0,x
	xgdy
	sty	*_.d2
	clr	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	stx	*_.z
	ldx	*_.xy
	subd	*_.d2
	xgdx
	sbcb	*_.d1+1
	sbca	_.d1
	xgdx
	puly
	sty	*_.d2
	puly
	sty	*_.d1
	puly
	puly
	puly
	sty	*_.frame
	rts
	.size	strcmp, .-strcmp
	.globl	isspace
	.type	isspace,@function
isspace:
	ldx	*_.frame
	pshx
	pshx
	pshx
	des
	sts	*_.frame
	ldx	*_.frame
	stab	1,x
	ldy	*_.frame
	ldab	1,y
	cmpb	#32
	beq	.L52
	ldy	*_.frame
	ldab	1,y
	cmpb	#9
	beq	.L52
	bra	.L51
.L52:
	ldy	*_.frame
	ldd	#1
	std	4,y
	clra
	clrb
	std	2,y
	bra	.L50
.L51:
	ldx	*_.frame
	clr	5,x
	clr	4,x
	clr	3,x
	clr	2,x
.L50:
	ldy	*_.frame
	ldd	4,y
	ldx	2,y
	puly
	puly
	ins
	puly
	sty	*_.frame
	rts
	.size	isspace, .-isspace
	.globl	isdigit
	.type	isdigit,@function
isdigit:
	ldx	*_.frame
	pshx
	pshx
	pshx
	des
	sts	*_.frame
	ldx	*_.frame
	stab	1,x
	ldy	*_.frame
	ldab	1,y
	cmpb	#47
	bls	.L55
	ldy	*_.frame
	ldab	1,y
	cmpb	#57
	bhi	.L55
	ldy	*_.frame
	ldd	#1
	std	4,y
	clra
	clrb
	std	2,y
	bra	.L54
.L55:
	ldx	*_.frame
	clr	5,x
	clr	4,x
	clr	3,x
	clr	2,x
.L54:
	ldy	*_.frame
	ldd	4,y
	ldx	2,y
	puly
	puly
	ins
	puly
	sty	*_.frame
	rts
	.size	isdigit, .-isdigit
	.globl	atoi
	.type	atoi,@function
atoi:
	ldx	*_.frame
	pshx
	tsx
	xgdx
	addd	#-20
	xgdx
	txs
	sts	*_.frame
	ldx	*_.d1
	pshx
	ldx	*_.d2
	pshx
	ldx	*_.d3
	pshx
	ldx	*_.d4
	pshx
	ldx	*_.frame
	std	1,x
	ldy	*_.frame
	clr	14,y
	clr	13,y
	clr	12,y
	clr	11,y
	ldy	*_.frame
	clr	10,y
	clr	9,y
	clr	8,y
	clr	7,y
	ldx	*_.frame
	clr	6,x
	clr	5,x
	clr	4,x
	clr	3,x
	sty	*_.z
.L58:
	ldy	*_.frame
	ldy	9,y
	sty	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	sty	*_.xy
	ldy	*_.frame
	ldd	1,y
	addd	*_.d2
	pshb
	psha
	pulx
	ldab	0,x
	ldy	*_.xy
	bsr	isspace
	cmpb	#0
	bne	.L60
	bra	.L59
.L60:
	ldy	*_.frame
	ldd	9,y
	ldx	7,y
	addd	#1
	bcc	.L68
	inx	
.L68:
	ldy	*_.frame
	std	9,y
	stx	7,y
	sty	*_.z
	bra	.L58
.L59:
	ldy	*_.frame
	xgdy
	addd	#7
	xgdy
	ldd	2,y
	std	*_.d2
	ldd	0,y
	std	*_.d1
	ldd	*_.d2
	ldx	*_.d1
	std	*_.d4
	clr	*_.d3+1
	clr	*_.d3
	sty	*_.xy
	ldy	*_.frame
	ldd	1,y
	addd	*_.d4
	ldx	*_.frame
	std	19,x
	ldd	*_.d2
	ldx	*_.d1
	addd	#1
	bcc	.L69
	inx	
.L69:
	std	*_.d2
	stx	*_.d1
	ldd	*_.d2
	sty	*_.z
	ldy	*_.xy
	std	2,y
	ldd	*_.d1
	std	0,y
	ldy	*_.frame
	ldy	19,y
	ldab	0,y
	cmpb	#45
	bne	.L61
	ldy	*_.frame
	ldd	#1
	std	13,y
	clra
	clrb
	std	11,y
.L61:
	nop
.L62:
	ldy	*_.frame
	ldy	9,y
	sty	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldx	*_.frame
	ldd	1,x
	addd	*_.d2
	sty	*_.z
	ldy	*_.frame
	std	19,y
	ldy	*_.frame
	ldy	19,y
	ldab	0,y
	cmpb	#0
	beq	.L63
	ldy	*_.frame
	ldy	9,y
	sty	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldx	*_.frame
	ldd	1,x
	addd	*_.d2
	sty	*_.z
	std	*_.tmp
	ldy	*_.tmp
	ldab	0,y
	bsr	isdigit
	cmpb	#0
	bne	.L64
	bra	.L63
.L64:
	ldy	*_.frame
	ldd	5,y
	std	*_.d2
	ldd	3,y
	std	*_.d1
	ldd	*_.d2
	ldx	*_.d1
	ldy	#2
	bsr	___ashlsi3
	addd	*_.d2
	xgdx
	adcb	*_.d1+1
	adca	_.d1
	xgdx
	ldy	*_.frame
	std	17,y
	stx	15,y
	sty	*_.z
	ldy	*_.frame
	ldd	17,y
	lsld
	std	17,y
	ldd	15,y
	rolb
	rola
	std	15,y
	ldy	*_.frame
	xgdy
	addd	#7
	xgdy
	ldd	2,y
	std	*_.d2
	ldd	0,y
	std	*_.d1
	ldd	*_.d2
	ldx	*_.d1
	std	*_.d4
	clr	*_.d3+1
	clr	*_.d3
	ldx	*_.frame
	ldd	1,x
	addd	*_.d4
	stx	*_.z
	std	*_.z
	sty	*_.xy
	ldy	*_.z
	ldx	#0
	clra
	ldab	0,y
	ldy	*_.xy
	sty	*_.xy
	ldy	*_.frame
	addd	17,y
	xgdx
	adcb	16,y
	adca	15,y
	xgdx
	subd	#48
	bcc	.L70
	dex
.L70:
	std	*_.d4
	stx	*_.d3
	ldd	*_.d2
	ldx	*_.d1
	addd	#1
	bcc	.L71
	inx	
.L71:
	std	*_.d2
	stx	*_.d1
	ldd	*_.d2
	sty	*_.z
	ldy	*_.xy
	std	2,y
	ldd	*_.d1
	std	0,y
	ldy	*_.frame
	ldd	*_.d4
	std	5,y
	ldd	*_.d3
	std	3,y
	bra	.L62
.L63:
	ldx	*_.frame
	ldx	11,x
	cpx	#0
	bne	.L67
	ldy	*_.frame
	ldd	13,y
	cpd	#0
	beq	.L66
.L67:
	ldy	*_.frame
	ldd	5,y
	std	*_.d2
	ldd	3,y
	std	*_.d1
	clr	*_.d4+1
	clr	*_.d4
	clr	*_.d3+1
	clr	*_.d3
	ldd	*_.d4
	ldx	*_.d3
	subd	*_.d2
	xgdx
	sbcb	*_.d1+1
	sbca	_.d1
	xgdx
	std	*_.d2
	stx	*_.d1
	ldy	*_.frame
	ldd	*_.d2
	std	5,y
	ldd	*_.d1
	std	3,y
.L66:
	ldy	*_.frame
	ldd	5,y
	std	*_.d2
	ldd	3,y
	std	*_.d1
	ldd	*_.d2
	ldx	*_.d1
	puly
	sty	*_.d4
	puly
	sty	*_.d3
	puly
	sty	*_.d2
	puly
	sty	*_.d1
	tsy
	xgdy
	addd	#20
	xgdy
	tys
	puly
	sty	*_.frame
	rts
	.size	atoi, .-atoi
	.globl	itoa
	.type	itoa,@function
itoa:
	ldy	*_.frame
	pshy
	tsy
	xgdy
	addd	#-17
	xgdy
	tys
	sts	*_.frame
	ldy	*_.d1
	pshy
	ldy	*_.d2
	pshy
	ldy	*_.frame
	std	3,y
	stx	1,y
	clrb
	ldy	*_.frame
	stab	5,y
	ldx	*_.frame
	ldx	1,x
	sty	*_.z
	cpx	#0
	bgt	.L73
	ldy	*_.frame
	ldd	1,y
	cpd	#0
	blt	.L74
	ldx	*_.frame
	ldx	3,x
	cpx	#0
	bhs	.L73
.L74:
	ldy	*_.frame
	ldab	5,y
	clr	*_.d2
	stab	*_.d2+1
	clr	*_.d1+1
	clr	*_.d1
	ldy	*_.frame
	ldd	22,y
	ldx	*_.d2
	std	*_.tmp
	xgdx
	addd	*_.tmp
	xgdx
	ldab	#45
	stab	0,x
	ldx	*_.frame
	inc	5,x
	sty	*_.z
	ldy	*_.frame
	ldd	3,y
	ldx	1,y
	bsr	___negsi2
	ldy	*_.frame
	std	3,y
	stx	1,y
	sty	*_.z
.L73:
	ldx	*_.frame
	ldab	4,x
	ldy	*_.frame
	stab	7,y
.L75:
	ldy	*_.frame
	ldab	8,y
	cmpb	#0
	beq	.L76
	ldy	*_.frame
	ldab	7,y
	cmpb	#0
	bne	.L77
	bra	.L76
.L77:
	ldy	*_.frame
	ldab	7,y
	clr	16,y
	stab	17,y
	ldx	*_.frame
	ldd	16,x
	ldx	#10
	idiv
	xgdx
	ldy	*_.frame
	stx	16,y
	ldx	*_.frame
	ldy	*_.frame
	ldab	17,y
	stab	8,y
	ldy	*_.frame
	clra
	ldab	7,y
	ldx	#10
	idiv
	xgdx
	ldx	*_.frame
	stab	7,x
	sty	*_.z
	ldy	*_.frame
	ldab	5,y
	clr	*_.d2
	stab	*_.d2+1
	clr	*_.d1+1
	clr	*_.d1
	ldy	*_.frame
	ldd	22,y
	addd	*_.d2
	ldx	*_.frame
	std	16,x
	sty	*_.z
	ldy	*_.frame
	ldab	8,y
	addb	#48
	ldy	*_.frame
	ldy	16,y
	stab	0,y
	stx	*_.xy
	ldx	*_.frame
	inc	5,x
	stx	*_.z
	ldx	*_.xy
	bra	.L75
.L76:
	ldy	*_.frame
	ldx	#0
	clra
	ldab	5,y
	ldx	*_.frame
	ldy	22,x
	stx	*_.z
	sty	*_.tmp
	ldx	*_.tmp
	std	*_.tmp
	xgdx
	addd	*_.tmp
	xgdx
	clrb
	stab	0,x
	clrb
	ldx	*_.frame
	stab	6,x
.L79:
	ldy	*_.frame
	ldab	6,y
	std	*_.xy
	ldd	*_.frame
	std	*_.z
	ldd	*_.xy
	pshx
	ldx	*_.z
	cmpb	5,x
	pulx
	blo	.L82
	bra	.L72
.L82:
	ldy	*_.frame
	ldx	#0
	clra
	ldab	6,y
	ldx	*_.frame
	ldy	22,x
	sty	*_.tmp
	addd	*_.tmp
	stx	*_.z
	pshb
	psha
	pulx
	ldab	0,x
	ldy	*_.frame
	stab	9,y
	ldy	*_.frame
	ldx	#0
	clra
	ldab	6,y
	sty	*_.z
	ldx	*_.frame
	ldy	22,x
	stx	*_.z
	sty	*_.tmp
	ldx	*_.tmp
	std	*_.tmp
	xgdx
	addd	*_.tmp
	xgdx
	ldy	*_.frame
	ldab	5,y
	clr	12,y
	stab	13,y
	ldy	*_.frame
	ldab	6,y
	clr	16,y
	stab	17,y
	ldy	*_.frame
	ldd	12,y
	subd	16,y
	std	16,y
	stx	*_.xy
	ldx	*_.frame
	ldx	16,x
	stx	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldy	*_.frame
	ldd	22,y
	addd	*_.d2
	stx	*_.z
	ldx	*_.xy
	std	*_.z
	ldy	*_.z
	ldab	0,y
	stab	0,x
	ldy	*_.frame
	ldab	5,y
	clr	14,y
	stab	15,y
	ldy	*_.frame
	ldab	6,y
	clr	16,y
	stab	17,y
	ldy	*_.frame
	ldd	14,y
	subd	16,y
	std	16,y
	ldy	*_.frame
	ldy	16,y
	sty	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldx	*_.frame
	ldd	22,x
	ldx	*_.d2
	std	*_.tmp
	xgdx
	addd	*_.tmp
	xgdx
	sty	*_.z
	ldy	*_.frame
	ldab	9,y
	stab	0,x
	stx	*_.xy
	ldx	*_.frame
	inc	6,x
	stx	*_.z
	ldx	*_.xy
	bra	.L79
.L72:
	pulx
	stx	*_.d2
	pulx
	stx	*_.d1
	tsx
	xgdx
	addd	#17
	xgdx
	txs
	pulx
	stx	*_.frame
	rts
	.size	itoa, .-itoa
	.globl	vt100_send
	.type	vt100_send,@function
vt100_send:
	ldx	*_.frame
	pshx
	pshx
	sts	*_.frame
	ldx	*_.frame
	std	1,x
	ldab	#27
	bsr	putc
	ldx	*_.frame
	ldd	1,x
	bsr	write
	pulx
	pulx
	stx	*_.frame
	rts
	.size	vt100_send, .-vt100_send
	; extern	print_time
	.section	.rodata
.LC1:
	.string	"help"
.LC2:
	.string	"?"
.LC3:
	.string	"Cruz/OS Help\r\n------------\r\n"
.LC4:
	.string	"help              this message\r\ntime              get the current time\r\ntime <new time>   set the system time"
.LC5:
	.string	"regs              get the values of the system registers\r\nregs <reg> <val>  sets register <reg> to the value <val>"
.LC6:
	.string	"mem <address>     get memory byte at <address>\r\nmem <addr> <val>  set memory byte at <addr> to <val>"
.LC7:
	.string	"reboot            reboot the system\r\nhalt              halt the system\r\n"
.LC8:
	.string	"reboot"
.LC9:
	.string	"INIT: Please standby as the system reboots..."
.LC10:
	.string	"halt"
.LC11:
	.string	"INIT: System halted."
.LC12:
	.string	"cls"
.LC13:
	.string	"clear"
.LC14:
	.string	"[2J"
.LC15:
	.string	"[0;0H"
.LC16:
	.string	"time"
	.sect	.text
	.globl	shell_exec
	.type	shell_exec,@function
shell_exec:
	ldx	*_.frame
	pshx
	tsx
	xgdx
	addd	#-38
	xgdx
	txs
	sts	*_.frame
	ldx	*_.d1
	pshx
	ldx	*_.d2
	pshx
	ldx	*_.frame
	std	1,x
	ldy	*_.frame
	clr	6,y
	clr	5,y
	clr	4,y
	clr	3,y
	ldx	#.LC1
	pshx
	ldx	*_.frame
	ldd	1,x
	bsr	strcmp
	ins
	ins
	ldy	*_.frame
	std	13,y
	stx	11,y
	ldx	*_.frame
	ldx	11,x
	cpx	#0
	bne	.L87
	ldy	*_.frame
	ldd	13,y
	cpd	#0
	beq	.L86
.L87:
	ldx	#.LC2
	pshx
	ldx	*_.frame
	ldd	1,x
	bsr	strcmp
	ins
	ins
	ldy	*_.frame
	std	17,y
	stx	15,y
	ldx	*_.frame
	ldx	15,x
	cpx	#0
	bne	.L85
	ldy	*_.frame
	ldd	17,y
	cpd	#0
	bne	.L85
.L86:
	ldd	#.LC3
	bsr	puts
	ldd	#.LC4
	bsr	puts
	ldx	*_.frame
	clr	10,x
	clr	9,x
	clr	8,x
	clr	7,x
.L89:
	ldy	*_.frame
	ldd	7,y
	cpd	#0
	blo	.L91
	ldx	*_.frame
	ldx	7,x
	cpx	#0
	bhi	.L90
	ldy	*_.frame
	ldd	9,y
	cpd	#-2
	bls	.L91
	bra	.L90
.L91:
	ldy	*_.frame
	ldd	9,y
	ldx	7,y
	addd	#1
	bcc	.L127
	inx	
.L127:
	ldy	*_.frame
	std	9,y
	stx	7,y
	bra	.L89
.L90:
	ldd	#.LC5
	bsr	puts
	ldx	*_.frame
	clr	10,x
	clr	9,x
	clr	8,x
	clr	7,x
.L94:
	ldy	*_.frame
	ldd	7,y
	cpd	#0
	blo	.L96
	ldx	*_.frame
	ldx	7,x
	cpx	#0
	bhi	.L95
	ldy	*_.frame
	ldd	9,y
	cpd	#-2
	bls	.L96
	bra	.L95
.L96:
	ldy	*_.frame
	ldd	9,y
	ldx	7,y
	addd	#1
	bcc	.L128
	inx	
.L128:
	ldy	*_.frame
	std	9,y
	stx	7,y
	bra	.L94
.L95:
	ldd	#.LC6
	bsr	puts
	ldx	*_.frame
	clr	10,x
	clr	9,x
	clr	8,x
	clr	7,x
.L99:
	ldy	*_.frame
	ldd	7,y
	cpd	#0
	blo	.L101
	ldx	*_.frame
	ldx	7,x
	cpx	#0
	bhi	.L100
	ldy	*_.frame
	ldd	9,y
	cpd	#-2
	bls	.L101
	bra	.L100
.L101:
	ldy	*_.frame
	ldd	9,y
	ldx	7,y
	addd	#1
	bcc	.L129
	inx	
.L129:
	ldy	*_.frame
	std	9,y
	stx	7,y
	bra	.L99
.L100:
	ldd	#.LC7
	bsr	puts
	ldx	*_.frame
	clr	6,x
	clr	5,x
	clr	4,x
	clr	3,x
	bra	.L104
.L85:
	ldx	#.LC8
	pshx
	ldy	*_.frame
	ldd	1,y
	bsr	strcmp
	ins
	ins
	ldy	*_.frame
	std	21,y
	stx	19,y
	ldx	*_.frame
	ldx	19,x
	cpx	#0
	bne	.L105
	ldy	*_.frame
	ldd	21,y
	cpd	#0
	bne	.L105
	ldd	#.LC9
	bsr	puts
	ldx	*_.frame
	clr	10,x
	clr	9,x
	clr	8,x
	clr	7,x
.L107:
	ldy	*_.frame
	ldd	7,y
	cpd	#0
	blo	.L109
	ldx	*_.frame
	ldx	7,x
	cpx	#0
	bhi	.L108
	ldy	*_.frame
	ldd	9,y
	cpd	#-2
	bls	.L109
	bra	.L108
.L109:
	ldy	*_.frame
	ldd	9,y
	ldx	7,y
	addd	#1
	bcc	.L130
	inx	
.L130:
	ldy	*_.frame
	std	9,y
	stx	7,y
	bra	.L107
.L108:
; Begin inline assembler code
#APP
	sei
	jmp _start
; End of inline assembler code
#NO_APP
	bra	.L104
.L105:
	ldx	#.LC10
	pshx
	ldx	*_.frame
	ldd	1,x
	bsr	strcmp
	ins
	ins
	ldy	*_.frame
	std	25,y
	stx	23,y
	ldx	*_.frame
	ldx	23,x
	cpx	#0
	bne	.L113
	ldy	*_.frame
	ldd	25,y
	cpd	#0
	bne	.L113
; Begin inline assembler code
#APP
	sei
; End of inline assembler code
#NO_APP
	ldd	#.LC11
	bsr	puts
.L115:
	bra	.L115
.L113:
	ldx	#.LC12
	pshx
	ldx	*_.frame
	ldd	1,x
	bsr	strcmp
	ins
	ins
	ldy	*_.frame
	std	29,y
	stx	27,y
	ldx	*_.frame
	ldx	27,x
	cpx	#0
	bne	.L121
	ldy	*_.frame
	ldd	29,y
	cpd	#0
	beq	.L120
.L121:
	ldx	#.LC13
	pshx
	ldx	*_.frame
	ldd	1,x
	bsr	strcmp
	ins
	ins
	ldy	*_.frame
	std	33,y
	stx	31,y
	ldx	*_.frame
	ldx	31,x
	cpx	#0
	bne	.L119
	ldy	*_.frame
	ldd	33,y
	cpd	#0
	bne	.L119
.L120:
	ldd	#.LC14
	bsr	vt100_send
	ldd	#.LC15
	bsr	vt100_send
	bra	.L104
.L119:
	ldx	#.LC16
	pshx
	ldx	*_.frame
	ldd	1,x
	bsr	strcmp
	ins
	ins
	ldy	*_.frame
	std	37,y
	stx	35,y
	ldx	*_.frame
	ldx	35,x
	cpx	#0
	bne	.L124
	ldy	*_.frame
	ldd	37,y
	cpd	#0
	bne	.L124
	bsr	print_time
	bra	.L104
.L124:
	ldy	*_.frame
	ldd	#-1
	std	5,y
	ldd	#-1
	std	3,y
.L104:
	ldy	*_.frame
	ldd	5,y
	std	*_.d2
	ldd	3,y
	std	*_.d1
	ldd	*_.d2
	ldx	*_.d1
	puly
	sty	*_.d2
	puly
	sty	*_.d1
	tsy
	xgdy
	addd	#38
	xgdy
	tys
	puly
	sty	*_.frame
	rts
	.size	shell_exec, .-shell_exec
	.section	.rodata
.LC17:
	.string	"\r\n"
.LC18:
	.string	"\r\nhelp reboot halt"
.LC19:
	.string	"[1D"
	.sect	.text
	.globl	readline
	.type	readline,@function
readline:
	ldx	*_.frame
	pshx
	tsx
	xgdx
	addd	#-9
	xgdx
	txs
	sts	*_.frame
	ldx	*_.d1
	pshx
	ldx	*_.d2
	pshx
	ldx	*_.d3
	pshx
	ldx	*_.d4
	pshx
	ldx	*_.frame
	std	1,x
	clra
	clrb
	ldy	*_.frame
	std	8,y
	stx	*_.xy
	ldx	*_.frame
	clr	6,x
	clr	5,x
	clr	4,x
	clr	3,x
	stx	*_.z
	ldx	*_.xy
.L132:
	bsr	getc
	ldx	*_.frame
	stab	7,x
	ldy	*_.frame
	ldab	7,y
	cmpb	#0
	beq	.L132
	ldy	*_.frame
	ldab	7,y
	cmpb	#13
	beq	.L137
	ldy	*_.frame
	ldab	7,y
	cmpb	#10
	beq	.L137
	bra	.L136
.L137:
	ldab	#13
	bsr	putc
	ldab	#10
	bsr	putc
	sty	*_.xy
	ldy	*_.frame
	ldy	5,y
	sty	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldx	*_.frame
	ldd	1,x
	ldx	*_.d2
	std	*_.tmp
	xgdx
	addd	*_.tmp
	xgdx
	clrb
	stab	0,x
	sty	*_.z
	ldy	*_.xy
	bra	.L131
.L136:
	ldy	*_.frame
	ldab	7,y
	cmpb	#3
	bne	.L139
	ldy	*_.frame
	ldx	1,y
	clrb
	stab	0,x
	ldd	#.LC17
	bsr	write
	bra	.L131
.L139:
	ldy	*_.frame
	ldab	7,y
	cmpb	#4
	bne	.L141
	sty	*_.xy
	ldy	*_.frame
	ldy	5,y
	sty	*_.d2
	clr	*_.d1+1
	clr	*_.d1
	ldx	*_.frame
	ldd	1,x
	ldx	*_.d2
	std	*_.tmp
	xgdx
	addd	*_.tmp
	xgdx
	clrb
	stab	0,x
	ldd	#.LC17
	ldy	*_.xy
	bsr	write
	bra	.L131
.L141:
	ldy	*_.frame
	ldab	7,y
	cmpb	#9
	bne	.L143
	ldy	*_.frame
	ldd	8,y
	addd	#1
	ldx	*_.frame
	std	8,x
	sty	*_.z
	cpd	#1
	ble	.L132
	ldd	#.LC18
	bsr	puts
	ldy	*_.frame
	ldx	1,y
	clrb
	stab	0,x
	bra	.L131
.L143:
	ldy	*_.frame
	ldab	7,y
	cmpb	#8
	bne	.L146
	ldd	#.LC19
	bsr	vt100_send
	ldx	*_.frame
	ldx	3,x
	cpx	#0
	blt	.L132
	ldy	*_.frame
	ldd	3,y
	cpd	#0
	bgt	.L148
	ldx	*_.frame
	ldx	5,x
	cpx	#0
	bls	.L132
.L148:
	ldy	*_.frame
	ldd	5,y
	ldx	3,y
	subd	#1
	bcc	.L150
	dex
.L150:
	ldy	*_.frame
	std	5,y
	stx	3,y
	sty	*_.z
	bra	.L132
.L146:
	ldx	*_.frame
	ldab	7,x
	bsr	putc
	ldy	*_.frame
	iny
	iny
	iny
	ldd	2,y
	std	*_.d2
	ldd	0,y
	std	*_.d1
	ldd	*_.d2
	ldx	*_.d1
	std	*_.d4
	clr	*_.d3+1
	clr	*_.d3
	sty	*_.xy
	ldy	*_.frame
	ldd	1,y
	ldx	*_.d4
	std	*_.tmp
	xgdx
	addd	*_.tmp
	xgdx
	sty	*_.z
	ldy	*_.xy
	sty	*_.xy
	ldy	*_.frame
	ldab	7,y
	stab	0,x
	ldd	*_.d2
	ldx	*_.d1
	addd	#1
	bcc	.L151
	inx	
.L151:
	std	*_.d2
	stx	*_.d1
	ldd	*_.d2
	sty	*_.z
	ldy	*_.xy
	std	2,y
	ldd	*_.d1
	std	0,y
	bra	.L132
.L131:
	pulx
	stx	*_.d4
	pulx
	stx	*_.d3
	pulx
	stx	*_.d2
	pulx
	stx	*_.d1
	tsx
	xgdx
	addd	#9
	xgdx
	txs
	pulx
	stx	*_.frame
	rts
	.size	readline, .-readline
	.section	.rodata
.LC20:
	.string	"7"
.LC21:
	.string	"[22;1H"
.LC22:
	.string	"The current time is undefined!"
.LC23:
	.string	"8"
	.sect	.text
	.globl	print_time
	.type	print_time,@function
print_time:
	ldx	*_.frame
	pshx
	des
	sts	*_.frame
	ldx	*_.frame
	stab	1,x
	ldd	#.LC20
	bsr	vt100_send
	ldd	#.LC21
	bsr	vt100_send
	ldd	#.LC22
	bsr	write
	ldd	#.LC23
	bsr	vt100_send
	ins
	pulx
	stx	*_.frame
	rts
	.size	print_time, .-print_time
	.section	.rodata
.LC24:
	.string	""
.LC25:
	.string	"INIT: Booting Cruz/OS"
.LC26:
	.string	"Cruz/OS 0.1-CURRENT \"Red Dwarf\""
.LC27:
	.string	"(c) 2006 Amir Malik, Regents of the University of California"
.LC28:
	.string	"Portions (c) 2000, 2003 Free Software Foundation, Inc."
	.sect	.text
	.globl	main
	.type	main,@function
main:
	ldx	*_.frame
	pshx
	tsx
	xgdx
	addd	#-281
	xgdx
	txs
	sts	*_.frame
	clrb
	stab	sciRecvTail
	clrb
	stab	sciRecvHead
	clrb
	stab	sciSendTail
	clrb
	stab	sciSendHead
	ldd	#.LC24
	bsr	puts
	ldd	#.LC25
	bsr	puts
	ldd	#.LC26
	bsr	puts
	ldx	*_.frame
	clr	4,x
	clr	3,x
	clr	2,x
	clr	1,x
.L154:
	ldy	*_.frame
	ldd	1,y
	cpd	#0
	blo	.L156
	ldx	*_.frame
	ldx	1,x
	cpx	#0
	bhi	.L155
	ldy	*_.frame
	ldd	3,y
	cpd	#-2
	bls	.L156
	bra	.L155
.L156:
	ldy	*_.frame
	ldd	3,y
	ldx	1,y
	addd	#1
	bcc	.L179
	inx	
.L179:
	ldy	*_.frame
	std	3,y
	stx	1,y
	bra	.L154
.L155:
	ldd	#.LC27
	bsr	puts
	ldd	#.LC28
	bsr	puts
	ldx	*_.frame
	clr	4,x
	clr	3,x
	clr	2,x
	clr	1,x
.L159:
	ldy	*_.frame
	ldd	1,y
	cpd	#0
	blo	.L161
	ldx	*_.frame
	ldx	1,x
	cpx	#0
	bhi	.L160
	ldy	*_.frame
	ldd	3,y
	cpd	#-2
	bls	.L161
	bra	.L160
.L161:
	ldy	*_.frame
	ldd	3,y
	ldx	1,y
	addd	#1
	bcc	.L180
	inx	
.L180:
	ldy	*_.frame
	std	3,y
	stx	1,y
	bra	.L159
.L160:
	ldd	#.LC24
	bsr	puts
	ldd	#.LC24
	bsr	puts
	ldd	*_.frame
	addd	#270
	pshb
	psha
	ldd	#123
	ldx	#0
	bsr	itoa
	ins
	ins
	ldd	*_.frame
	addd	#270
	bsr	puts
.L164:
	bra	.L164
	.size	main, .-main
	.comm	SCI_RECV_BUFFER,128,1
	.comm	SCI_SEND_BUFFER,128,1
	.comm	sciRecvHead,1,1
	.comm	sciRecvTail,1,1
	.comm	sciSendHead,1,1
	.comm	sciSendTail,1,1
	.comm	curtime,1,1
	.comm	time,3,1
	.ident	"GCC: (GNU) 3.3.6-m68hc1x-20060122"
