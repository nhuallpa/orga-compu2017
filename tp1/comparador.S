# 
# Funcion busqueda de posicion de caracter en vector basis 64
#

#include <mips/regdef.h>

#define SIZE_SF_SEARCH_B64 8 
#define LOCATE_FP_SF_SEARCH_B64 4 
#define LOCATE_ARG0_SF_SEARCH_B64 8 
#define LOCATE_ARG3_SF_SEARCH_B64 20 
#define RETURN_SUCCESS	0
#define RETURN_ERROR	-1  	

	.text
	.align	2

	.globl  search_b64	
	.ent    search_b64	
search_b64:
	.frame	$fp,SIZE_SF_SEARCH_B64, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp, sp, SIZE_SF_SEARCH_B64 
	.cprestore 0
	sw	$fp, LOCATE_FP_SF_SEARCH_B64(sp)
	move	$fp, sp
	sw	a0, LOCATE_ARG0_SF_SEARCH_B64($fp)

	# Use v0 for the result.
	#
	li	v0, 0 
	li      t2, 66 #Para saber si no esta en el array el caracter buscado 
	la 	t0, basis64
search_loop:
        #la      t1, basis64
        #addu 	t1,t1,t2
        lb	t1,0(t0)
	#sb	$t1,8(sp)
  	#lb	$t1,0(t1)
	beq	a0,t1,search_b64_return
	beq     v0,t2,error_return 
	addi	t0,t0,1 #Avanzo de a 1 word
	addi	v0, v0, 1 
	j	search_loop

search_b64_return:
	li	a3,RETURN_SUCCESS #Success
	sw	a3,20($fp)
	#li	t3,65
	#subu	v0,t3,v0
	j	destroy_frame

error_return:
	li	a3,RETURN_ERROR #Error
	sw	a3,LOCATE_ARG3_SF_SEARCH_B64($fp)
	li	v0,RETURN_ERROR #Error. No se encontro en el array el caracter buscado
	
destroy_frame:
	# Destruimos el frame.
	#
	#addiu 	v0, v0, 2
        #li	v0, 2 
	#li 	a0, 1
        #syscall 
       # move    sp,$fp
	lw	$fp, LOCATE_FP_SF_SEARCH_B64(sp)
	lw	a0, LOCATE_ARG0_SF_SEARCH_B64(sp)
	lw	a3, LOCATE_ARG3_SF_SEARCH_B64(sp)
	addu	sp, sp, SIZE_SF_SEARCH_B64 
	j	fin

fin:
	# Retorno.
	#
	jr	ra
	.end    search_b64	

	.rdata
	.align 	2 

basis64: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
