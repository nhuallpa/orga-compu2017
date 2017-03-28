	.file	1 "main.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.rdata
	.align	2
	.type	basis_64, @object
	.size	basis_64, 66
basis_64:
	.ascii	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123"
	.ascii	"456789+/=\000"
	.align	2
$LC0:
	.ascii	"encode\000"
	.data
	.align	2
	.type	ENCODE, @object
	.size	ENCODE, 4
ENCODE:
	.word	$LC0
	.rdata
	.align	2
$LC1:
	.ascii	"decode\000"
	.data
	.align	2
	.type	DECODE, @object
	.size	DECODE, 4
DECODE:
	.word	$LC1
	.text
	.align	2
	.ent	bloqueToBase64
bloqueToBase64:
	.frame	$fp,32,$ra		# vars= 16, regs= 2/0, args= 0, extra= 8
	.mask	0x50000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,32
	.cprestore 0
	sw	$fp,28($sp)
	sw	$gp,24($sp)
	move	$fp,$sp
	sw	$a0,32($fp)
	sw	$a1,36($fp)
	sw	$a2,40($fp)
	lw	$v1,36($fp)
	lw	$v0,32($fp)
	lbu	$v0,0($v0)
	srl	$v0,$v0,2
	andi	$v0,$v0,0x00ff
	lbu	$v0,basis_64($v0)
	sb	$v0,0($v1)
	lw	$v0,36($fp)
	addu	$a0,$v0,1
	lw	$v0,32($fp)
	lbu	$v0,0($v0)
	andi	$v0,$v0,0x3
	sll	$v1,$v0,4
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	lbu	$v0,0($v0)
	andi	$v0,$v0,0xf0
	sra	$v0,$v0,4
	or	$v0,$v1,$v0
	lbu	$v0,basis_64($v0)
	sb	$v0,0($a0)
	lw	$v0,36($fp)
	addu	$v0,$v0,2
	sw	$v0,8($fp)
	lw	$v0,40($fp)
	slt	$v0,$v0,2
	bne	$v0,$zero,$L18
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	lbu	$v0,0($v0)
	andi	$v0,$v0,0xf
	sll	$v1,$v0,2
	lw	$v0,32($fp)
	addu	$v0,$v0,2
	lbu	$v0,0($v0)
	andi	$v0,$v0,0xc0
	sra	$v0,$v0,6
	or	$v0,$v1,$v0
	lbu	$v0,basis_64($v0)
	sb	$v0,12($fp)
	b	$L19
$L18:
	li	$v0,61			# 0x3d
	sb	$v0,12($fp)
$L19:
	lbu	$v0,12($fp)
	lw	$v1,8($fp)
	sb	$v0,0($v1)
	lw	$v0,36($fp)
	addu	$v0,$v0,3
	sw	$v0,16($fp)
	lw	$v0,40($fp)
	slt	$v0,$v0,3
	bne	$v0,$zero,$L20
	lw	$v0,32($fp)
	addu	$v0,$v0,2
	lbu	$v0,0($v0)
	andi	$v0,$v0,0x3f
	lbu	$v0,basis_64($v0)
	sb	$v0,20($fp)
	b	$L21
$L20:
	li	$v1,61			# 0x3d
	sb	$v1,20($fp)
$L21:
	lbu	$v1,20($fp)
	lw	$v0,16($fp)
	sb	$v1,0($v0)
	move	$sp,$fp
	lw	$fp,28($sp)
	addu	$sp,$sp,32
	j	$ra
	.end	bloqueToBase64
	.size	bloqueToBase64, .-bloqueToBase64
	.align	2
	.globl	codificar
	.ent	codificar
codificar:
	.frame	$fp,80,$ra		# vars= 40, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,80
	.cprestore 16
	sw	$ra,72($sp)
	sw	$fp,68($sp)
	sw	$gp,64($sp)
	move	$fp,$sp
	sw	$a0,80($fp)
	sw	$a1,84($fp)
	sw	$zero,44($fp)
	sw	$zero,48($fp)
	sb	$zero,24($fp)
	sb	$zero,32($fp)
$L23:
	lw	$v0,80($fp)
	lhu	$v0,12($v0)
	srl	$v0,$v0,5
	xori	$v0,$v0,0x1
	andi	$v0,$v0,0x1
	bne	$v0,$zero,$L25
	b	$L24
$L25:
	sw	$zero,44($fp)
	sw	$zero,40($fp)
$L26:
	lw	$v0,40($fp)
	slt	$v0,$v0,3
	bne	$v0,$zero,$L29
	b	$L27
$L29:
	lw	$v1,40($fp)
	addu	$v0,$fp,24
	addu	$v0,$v0,$v1
	sw	$v0,52($fp)
	lw	$v1,80($fp)
	lw	$v0,80($fp)
	lw	$v0,4($v0)
	addu	$v0,$v0,-1
	sw	$v0,4($v1)
	bgez	$v0,$L30
	lw	$a0,80($fp)
	la	$t9,__srget
	jal	$ra,$t9
	sb	$v0,56($fp)
	b	$L31
$L30:
	lw	$v0,80($fp)
	lw	$v1,0($v0)
	move	$a0,$v1
	lbu	$a0,0($a0)
	sb	$a0,56($fp)
	addu	$v1,$v1,1
	sw	$v1,0($v0)
$L31:
	lbu	$v1,56($fp)
	lw	$v0,52($fp)
	sb	$v1,0($v0)
	lw	$v0,80($fp)
	lhu	$v0,12($v0)
	srl	$v0,$v0,5
	xori	$v0,$v0,0x1
	andi	$v0,$v0,0x1
	beq	$v0,$zero,$L32
	lw	$v0,44($fp)
	addu	$v0,$v0,1
	sw	$v0,44($fp)
	b	$L28
$L32:
	lw	$v0,40($fp)
	addu	$v1,$fp,24
	addu	$v0,$v1,$v0
	sb	$zero,0($v0)
$L28:
	lw	$v0,40($fp)
	addu	$v0,$v0,1
	sw	$v0,40($fp)
	b	$L26
$L27:
	lw	$v0,44($fp)
	blez	$v0,$L23
	addu	$v0,$fp,32
	addu	$a0,$fp,24
	move	$a1,$v0
	lw	$a2,44($fp)
	la	$t9,bloqueToBase64
	jal	$ra,$t9
	sw	$zero,40($fp)
$L35:
	lw	$v0,40($fp)
	slt	$v0,$v0,4
	bne	$v0,$zero,$L38
	b	$L23
$L38:
	addu	$v1,$fp,32
	lw	$v0,40($fp)
	addu	$v0,$v1,$v0
	lbu	$v0,0($v0)
	move	$a0,$v0
	lw	$a1,84($fp)
	la	$t9,__sputc
	jal	$ra,$t9
	move	$v1,$v0
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L37
	lw	$v0,84($fp)
	lhu	$v0,12($v0)
	srl	$v0,$v0,6
	andi	$v0,$v0,0x1
	beq	$v0,$zero,$L23
	li	$v0,1			# 0x1
	sw	$v0,48($fp)
	b	$L23
$L37:
	lw	$v0,40($fp)
	addu	$v0,$v0,1
	sw	$v0,40($fp)
	b	$L35
$L24:
	lw	$v0,48($fp)
	move	$sp,$fp
	lw	$ra,72($sp)
	lw	$fp,68($sp)
	addu	$sp,$sp,80
	j	$ra
	.end	codificar
	.size	codificar, .-codificar
	.align	2
	.globl	decodificar
	.ent	decodificar
decodificar:
	.frame	$fp,64,$ra		# vars= 24, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,64
	.cprestore 16
	sw	$ra,56($sp)
	sw	$fp,52($sp)
	sw	$gp,48($sp)
	move	$fp,$sp
	sw	$a0,64($fp)
	sw	$a1,68($fp)
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	la	$a0,basis_64
	move	$a1,$v0
	la	$t9,strchr
	jal	$ra,$t9
	move	$v1,$v0
	la	$v0,basis_64
	subu	$v0,$v1,$v0
	sw	$v0,24($fp)
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	la	$a0,basis_64
	move	$a1,$v0
	la	$t9,strchr
	jal	$ra,$t9
	move	$v1,$v0
	la	$v0,basis_64
	subu	$v0,$v1,$v0
	sw	$v0,28($fp)
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	la	$a0,basis_64
	move	$a1,$v0
	la	$t9,strchr
	jal	$ra,$t9
	move	$v1,$v0
	la	$v0,basis_64
	subu	$v0,$v1,$v0
	sw	$v0,32($fp)
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	la	$a0,basis_64
	move	$a1,$v0
	la	$t9,strchr
	jal	$ra,$t9
	move	$v1,$v0
	la	$v0,basis_64
	subu	$v0,$v1,$v0
	sw	$v0,36($fp)
$L42:
	lw	$v0,64($fp)
	lhu	$v0,12($v0)
	srl	$v0,$v0,5
	andi	$v0,$v0,0x1
	bne	$v0,$zero,$L43
	lw	$v0,24($fp)
	sltu	$v0,$v0,64
	beq	$v0,$zero,$L43
	lw	$v0,28($fp)
	sltu	$v0,$v0,65
	beq	$v0,$zero,$L43
	lw	$v0,32($fp)
	sltu	$v0,$v0,65
	beq	$v0,$zero,$L43
	lw	$v0,36($fp)
	sltu	$v0,$v0,65
	bne	$v0,$zero,$L44
	b	$L43
$L44:
	lbu	$v0,24($fp)
	sll	$v1,$v0,2
	lw	$v0,28($fp)
	srl	$v0,$v0,4
	or	$v0,$v1,$v0
	sb	$v0,40($fp)
	lbu	$v0,40($fp)
	move	$a0,$v0
	lw	$a1,68($fp)
	la	$t9,fputc
	jal	$ra,$t9
	lw	$v0,32($fp)
	sltu	$v0,$v0,64
	beq	$v0,$zero,$L46
	lbu	$v0,28($fp)
	sll	$v1,$v0,4
	lw	$v0,32($fp)
	srl	$v0,$v0,2
	or	$v0,$v1,$v0
	sb	$v0,41($fp)
	lbu	$v0,41($fp)
	move	$a0,$v0
	lw	$a1,68($fp)
	la	$t9,fputc
	jal	$ra,$t9
	lw	$v0,36($fp)
	sltu	$v0,$v0,64
	beq	$v0,$zero,$L46
	lbu	$v0,32($fp)
	sll	$v0,$v0,6
	move	$v1,$v0
	lbu	$v0,36($fp)
	or	$v0,$v1,$v0
	sb	$v0,42($fp)
	lbu	$v0,42($fp)
	move	$a0,$v0
	lw	$a1,68($fp)
	la	$t9,fputc
	jal	$ra,$t9
$L46:
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	la	$a0,basis_64
	move	$a1,$v0
	la	$t9,strchr
	jal	$ra,$t9
	move	$v1,$v0
	la	$v0,basis_64
	subu	$v0,$v1,$v0
	sw	$v0,24($fp)
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	la	$a0,basis_64
	move	$a1,$v0
	la	$t9,strchr
	jal	$ra,$t9
	move	$v1,$v0
	la	$v0,basis_64
	subu	$v0,$v1,$v0
	sw	$v0,28($fp)
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	la	$a0,basis_64
	move	$a1,$v0
	la	$t9,strchr
	jal	$ra,$t9
	move	$v1,$v0
	la	$v0,basis_64
	subu	$v0,$v1,$v0
	sw	$v0,32($fp)
	lw	$a0,64($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	la	$a0,basis_64
	move	$a1,$v0
	la	$t9,strchr
	jal	$ra,$t9
	move	$v1,$v0
	la	$v0,basis_64
	subu	$v0,$v1,$v0
	sw	$v0,36($fp)
	b	$L42
$L43:
	move	$v0,$zero
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	decodificar
	.size	decodificar, .-decodificar
	.rdata
	.align	2
$LC3:
	.ascii	"help\000"
	.align	2
$LC4:
	.ascii	"version\000"
	.align	2
$LC5:
	.ascii	"action\000"
	.align	2
$LC6:
	.ascii	"input\000"
	.align	2
$LC7:
	.ascii	"output\000"
	.data
	.align	2
$LC8:
	.word	$LC3
	.word	0
	.word	0
	.word	104
	.word	$LC4
	.word	0
	.word	0
	.word	86
	.word	$LC5
	.word	1
	.word	0
	.word	97
	.word	$LC6
	.word	1
	.word	0
	.word	105
	.word	$LC7
	.word	1
	.word	0
	.word	111
	.word	0
	.word	0
	.word	0
	.word	0
	.globl	memcpy
	.rdata
	.align	2
$LC2:
	.ascii	"hva:i:o:\000"
	.align	2
$LC9:
	.ascii	"\000"
	.align	2
$LC10:
	.ascii	"Usage:\n\000"
	.align	2
$LC11:
	.ascii	"\ttp0 -h\n\000"
	.align	2
$LC12:
	.ascii	"\ttp0 -V\n\000"
	.align	2
$LC13:
	.ascii	"\ttp0 [ options ]\n\000"
	.align	2
$LC14:
	.ascii	"Options:\n\000"
	.align	2
$LC15:
	.ascii	"\t-V, --version       Print version and quit.\n\000"
	.align	2
$LC16:
	.ascii	"\t-h, --help          Print this information.\n\000"
	.align	2
$LC17:
	.ascii	"\t-i, --input         Location of the input file.\n\000"
	.align	2
$LC18:
	.ascii	"\t-o, --output        Location of the output file.\n\000"
	.align	2
$LC19:
	.ascii	"\t-a, --action        Program action: encode (default) o"
	.ascii	"r decode.\n\000"
	.align	2
$LC20:
	.ascii	"Examples:\n\000"
	.align	2
$LC21:
	.ascii	"\ttp0 -a encode -i ~/input -o ~/output\n\000"
	.align	2
$LC22:
	.ascii	"\ttp0 -a encode\n\000"
	.align	2
$LC23:
	.ascii	"Tp0:Version_0.1:Grupo: Nestor Huallpa, Ariel Martinez, P"
	.ascii	"ablo Sivori \n\000"
	.text
	.align	2
	.globl	manejarArgumentosEntrada
	.ent	manejarArgumentosEntrada
manejarArgumentosEntrada:
	.frame	$fp,184,$ra		# vars= 136, regs= 3/0, args= 24, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,184
	.cprestore 24
	sw	$ra,176($sp)
	sw	$fp,172($sp)
	sw	$gp,168($sp)
	move	$fp,$sp
	sw	$a0,184($fp)
	sw	$a1,188($fp)
	sw	$a2,192($fp)
	la	$v0,$LC2
	sw	$v0,40($fp)
	addu	$v0,$fp,48
	la	$v1,$LC8
	move	$a0,$v0
	move	$a1,$v1
	li	$a2,96			# 0x60
	la	$t9,memcpy
	jal	$ra,$t9
	lw	$v0,ENCODE
	sw	$v0,144($fp)
	la	$v0,$LC9
	sw	$v0,148($fp)
	la	$v0,$LC9
	sw	$v0,152($fp)
$L49:
	addu	$v1,$fp,48
	addu	$v0,$fp,36
	sw	$v0,16($sp)
	lw	$a0,188($fp)
	lw	$a1,192($fp)
	lw	$a2,40($fp)
	move	$a3,$v1
	la	$t9,getopt_long
	jal	$ra,$t9
	sw	$v0,32($fp)
	lw	$v1,32($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L52
	b	$L50
$L52:
	lw	$v0,32($fp)
	addu	$v0,$v0,-97
	sw	$v0,160($fp)
	lw	$v1,160($fp)
	sltu	$v0,$v1,22
	beq	$v0,$zero,$L49
	lw	$v0,160($fp)
	sll	$v1,$v0,2
	la	$v0,$L62
	addu	$v0,$v1,$v0
	lw	$v0,0($v0)
	.cpadd	$v0
	j	$v0
	.rdata
	.align	2
$L62:
	.gpword	$L56
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L54
	.gpword	$L58
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L60
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L49
	.gpword	$L55
	.text
$L54:
	la	$a0,$LC10
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC11
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC12
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC13
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC14
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC15
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC16
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC17
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC18
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC19
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC20
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC21
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC22
	la	$t9,printf
	jal	$ra,$t9
	move	$a0,$zero
	la	$t9,exit
	jal	$ra,$t9
$L55:
	la	$a0,$LC23
	la	$t9,printf
	jal	$ra,$t9
	move	$a0,$zero
	la	$t9,exit
	jal	$ra,$t9
$L56:
	lw	$v0,optarg
	beq	$v0,$zero,$L49
	lw	$v0,optarg
	sw	$v0,144($fp)
	b	$L49
$L58:
	lw	$v0,optarg
	beq	$v0,$zero,$L49
	lw	$v0,optarg
	sw	$v0,148($fp)
	b	$L49
$L60:
	lw	$v0,optarg
	beq	$v0,$zero,$L49
	lw	$v0,optarg
	sw	$v0,152($fp)
	b	$L49
$L50:
	lw	$v0,144($fp)
	lw	$v1,184($fp)
	sw	$v0,0($v1)
	lw	$v0,148($fp)
	lw	$v1,184($fp)
	sw	$v0,4($v1)
	lw	$v0,152($fp)
	lw	$v1,184($fp)
	sw	$v0,8($v1)
	lw	$v0,184($fp)
	move	$sp,$fp
	lw	$ra,176($sp)
	lw	$fp,172($sp)
	addu	$sp,$sp,184
	j	$ra
	.end	manejarArgumentosEntrada
	.size	manejarArgumentosEntrada, .-manejarArgumentosEntrada
	.rdata
	.align	2
$LC24:
	.ascii	"rb\000"
	.align	2
$LC25:
	.ascii	"w\000"
	.align	2
$LC26:
	.ascii	"ERROR: NO EXISTE LA ENTRADA.\n\000"
	.align	2
$LC27:
	.ascii	"ERROR: SE DEBE INGRESAR UN ARGUMENTO CORRECTO PARA LA OP"
	.ascii	"CION i.\n\000"
	.text
	.align	2
	.globl	main
	.ent	main
main:
	.frame	$fp,88,$ra		# vars= 48, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,88
	.cprestore 16
	sw	$ra,80($sp)
	sw	$fp,76($sp)
	sw	$gp,72($sp)
	move	$fp,$sp
	sw	$a0,88($fp)
	sw	$a1,92($fp)
	addu	$a0,$fp,24
	lw	$a1,88($fp)
	lw	$a2,92($fp)
	la	$t9,manejarArgumentosEntrada
	jal	$ra,$t9
	lw	$a0,28($fp)
	la	$a1,$LC9
	la	$t9,strcmp
	jal	$ra,$t9
	sw	$v0,40($fp)
	lw	$a0,32($fp)
	la	$a1,$LC9
	la	$t9,strcmp
	jal	$ra,$t9
	sw	$v0,44($fp)
	lw	$v0,40($fp)
	beq	$v0,$zero,$L65
	lw	$a0,28($fp)
	la	$a1,$LC24
	la	$t9,fopen
	jal	$ra,$t9
	sw	$v0,60($fp)
	b	$L66
$L65:
	la	$v0,__sF
	sw	$v0,60($fp)
$L66:
	lw	$v0,60($fp)
	sw	$v0,48($fp)
	lw	$v0,44($fp)
	beq	$v0,$zero,$L67
	lw	$a0,32($fp)
	la	$a1,$LC25
	la	$t9,fopen
	jal	$ra,$t9
	sw	$v0,64($fp)
	b	$L68
$L67:
	la	$v0,__sF+88
	sw	$v0,64($fp)
$L68:
	lw	$v0,64($fp)
	sw	$v0,52($fp)
	sw	$zero,56($fp)
	lw	$v0,48($fp)
	bne	$v0,$zero,$L69
	la	$a0,__sF+176
	la	$a1,$LC26
	la	$t9,fprintf
	jal	$ra,$t9
	li	$a0,1			# 0x1
	la	$t9,exit
	jal	$ra,$t9
$L69:
	lw	$a0,24($fp)
	lw	$a1,ENCODE
	la	$t9,strcmp
	jal	$ra,$t9
	bne	$v0,$zero,$L70
	lw	$a0,48($fp)
	lw	$a1,52($fp)
	la	$t9,codificar
	jal	$ra,$t9
	sw	$v0,56($fp)
	b	$L71
$L70:
	lw	$a0,24($fp)
	lw	$a1,DECODE
	la	$t9,strcmp
	jal	$ra,$t9
	bne	$v0,$zero,$L72
	lw	$a0,48($fp)
	lw	$a1,52($fp)
	la	$t9,decodificar
	jal	$ra,$t9
	sw	$v0,56($fp)
	b	$L71
$L72:
	la	$a0,__sF+176
	la	$a1,$LC27
	la	$t9,fprintf
	jal	$ra,$t9
	li	$a0,1			# 0x1
	la	$t9,exit
	jal	$ra,$t9
$L71:
	lw	$v0,40($fp)
	beq	$v0,$zero,$L74
	lw	$a0,48($fp)
	la	$t9,fclose
	jal	$ra,$t9
$L74:
	lw	$v0,44($fp)
	beq	$v0,$zero,$L75
	lw	$a0,52($fp)
	la	$t9,fclose
	jal	$ra,$t9
$L75:
	lw	$v0,56($fp)
	beq	$v0,$zero,$L76
	li	$a0,1			# 0x1
	la	$t9,exit
	jal	$ra,$t9
$L76:
	lw	$v0,56($fp)
	move	$sp,$fp
	lw	$ra,80($sp)
	lw	$fp,76($sp)
	addu	$sp,$sp,88
	j	$ra
	.end	main
	.size	main, .-main
	.align	2
	.ent	__sputc
__sputc:
	.frame	$fp,48,$ra		# vars= 8, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,48
	.cprestore 16
	sw	$ra,40($sp)
	sw	$fp,36($sp)
	sw	$gp,32($sp)
	move	$fp,$sp
	sw	$a0,48($fp)
	sw	$a1,52($fp)
	lw	$v1,52($fp)
	lw	$v0,52($fp)
	lw	$v0,8($v0)
	addu	$v0,$v0,-1
	sw	$v0,8($v1)
	bgez	$v0,$L3
	lw	$v0,52($fp)
	lw	$v1,52($fp)
	lw	$a0,8($v0)
	lw	$v0,24($v1)
	slt	$v0,$a0,$v0
	bne	$v0,$zero,$L2
	lb	$v1,48($fp)
	li	$v0,10			# 0xa
	bne	$v1,$v0,$L3
	b	$L2
$L3:
	lw	$a1,52($fp)
	lw	$v1,0($a1)
	lbu	$a0,48($fp)
	move	$v0,$v1
	sb	$a0,0($v0)
	andi	$v0,$a0,0x00ff
	addu	$v1,$v1,1
	sw	$v1,0($a1)
	sw	$v0,24($fp)
	b	$L1
$L2:
	lw	$a0,48($fp)
	lw	$a1,52($fp)
	la	$t9,__swbuf
	jal	$ra,$t9
	sw	$v0,24($fp)
$L1:
	lw	$v0,24($fp)
	move	$sp,$fp
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra
	.end	__sputc
	.size	__sputc, .-__sputc
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
