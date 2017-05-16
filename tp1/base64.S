#include <mips/regdef.h>
#include <sys/syscall.h>

#########FUNCION DECODE###########

#STATICS VAR DEFINITIONS FUNCTION DECODIFICAR
#define SF_SIZE_DECODIFICAR	  60 
#define SF_DECODIFICAR_GP_POS     44 
#define SF_DECODIFICAR_FP_POS     48
#define SF_DECODIFICAR_RA_POS     52 
 

#STATICS VAR DEFINITIONS FUNCTION READ CHARACTERS
#define SF_SIZE_READCH             8 
#define SF_READCH_GP_POS           0 
#define SF_READCH_FP_POS           4 

#define BUFFER_SIZE	           4  

.data
.align 2
#index:  .byte 1 
buffer: .space 4 
buffer_write: .space 4 

.text
.abicalls
.align 2
.global decodificar 
.ent decodificar

decodificar:
	.frame 	      $fp, SF_SIZE_DECODIFICAR, ra
	.set	      noreorder
	.cpload	      t9
	.set	      reorder
	subu	      sp, sp, SF_SIZE_DECODIFICAR
	sw	      ra, SF_DECODIFICAR_RA_POS(sp)
	#sw	      gp, SF_DECODIFICAR_GP_POS(sp)
	sw	      $fp, SF_DECODIFICAR_FP_POS(sp) 
        .cprestore    SF_DECODIFICAR_GP_POS
	move	      $fp, sp

	sw	      a0, 60($fp)
        sw            a1, 64($fp)

	#LEO LOS 4 PRIMEROS CARACTERES

obtener_enteros:
	jal	      read_characters 
	bnez	      a3,error_lectura
	li	      t0,4 	
	
	blt	      v0,t0,fin_success #Si la long de caracteres leidos es menor que cuatro 

	#Para imprimir por pantalla por stdout
	#move 	      a0, a1
	#la            a1, buffer #cargo la dir de buffer en el reg a1
        #la  	      t1, index
        #lw   	      a2, 0(t1)
	#add  	      a2, a2, t0 
        #li   	      v0, SYS_write
        #syscall        # print values

	la	      t0, buffer # El buffer con los 4 elementos
        sw	      t0, 20($fp)

	lb	      t0, 0(t0) #Leo caracter primera posicion
	move	      a0, t0	
	jal	      search_b64 #Obtengo valorEntero1
	bnez	      a3,error_busqueda
	move	      t1, v0 #Resultado valorEntero 1
	sw	      t1, 24($fp)
	
	lw	      t0, 20($fp)	
	lb	      t0, 1(t0) #Leo el segundo caracter
	move	      a0, t0
	jal	      search_b64	
	bnez	      a3, error_busqueda
	move	      t1, v0 #Resultado valorEntero 2
	sw	      t1, 28($fp)

	lw	      t0, 20($fp)
	lb            t0, 2(t0) #Leo el tercer caracter
        move          a0, t0
        jal           search_b64
        bnez          a3, error_busqueda
        move          t1, v0 #Resultado valorEntero 3
	sw	      t1, 32($fp)	       

	lw	      t0, 20($fp)
	lb            t0, 3(t0) #Leo el cuarto caracter
        move          a0, t0
        jal           search_b64
        bnez          a3, error_busqueda
        move          t4, v0 #Resultado valorEntero 4 
	sw	      t4, 36($fp)

	lw	      t1,24($fp)
	lw	      t2,28($fp)
	lw	      t3,32($fp)
	
	bltz	      t1,fin_decodificar
	li	      t5,63
	bgt	      t1,t5,fin_decodificar

	li	      t5,64	
	bltz          t2,fin_decodificar
        bgt           t2,t5,fin_decodificar
	
	bltz          t3,fin_decodificar
	bgt           t3,t5,fin_decodificar
	
	bltz          t4,fin_decodificar
        bgt           t4,t5,fin_decodificar

	la            t6, buffer_write

	li	      t5,2
        sll 	      s0,t1,t5 #valorEntero1<<2
	li	      t5,4
	srl	      s1,t2,t5 #valorEntero2>>4
	or	      s0,s0,s1 #valorEntero1<<2 | valorEntero2>>4
	sb	      s0, 0(t6)

	li	      t5,4 
	sll	      s0,t2,t5 #valorEntero2<<4
	li	      t5,2
	srl	      s1,t3,t5 #valorEntero3>>2
	or	      s0,s0,s1 #valoreEntero2<<4 | valorEntero3>>2
	sb	      s0, 4(t6)

	li	      t5,6
	sll	      s0,t3,t5 #valorEntero3<<6
	or	      s0,s0,t4 #valorEntero3<<6 | valorEntero4
	sb	      s0, 8(t6)
	
	lw           a0, 64($fp) #pongo en a0 el fd(outfd) 
	li	     t0, 12 	
	move 	     a1, t6
	#la           a1, buffer_write #cargo la dir de buffer en el reg a1
        la           t1, index
        #lw           a2, 0(t1)
        #add          a2, a2, t0
	move         a2, t0
        li           v0, SYS_write
	syscall

	bnez	     a3, error_escritura
	
	lw           a0, 60($fp) #restauro a0 (infd)
        lw           a1, 64($fp) #restauro a1 (outfd)
	j            obtener_enteros
	#j	     fin_decodificar

#restar_256:
#	subu 	     s0,s0,t5
#	j	     ra

#	j	      fin_decodificar

#	.ent escribir_caracter
	
#escribir_caracter:
#	.frame	      $fp, SF_SIZE_WRITECH, ra
#	.set	      noreorder
#	.cpload	      t9
#	.set	      reorder
#	subu	      sp, sp, SF_SIZE_WRITECH
#	sw	      $fp, SF_WRITECH_FP_POS(SP) #save fp
#	.cprestore	SF_WRITECH_GP_POS		            	       
#	move	      $fp, sp 			#fp->sp
#	sw	      a0, 8($fp)	#save arg(out fd)
	
	#Para imprimir por pantalla por stdout
        #move         a0, a1
        #la            a1, buffer #cargo la dir de buffer en el reg a1
        #la           t1, index
        #lw           a2, 0(t1)
        #add          a2, a2, t0
        #li           v0, SYS_write
        #syscall        # print values
fin_success:
	li	      v0, 0
	j	      fin_decodificar
error_busqueda:	
	#la	      t0,errmsg
	#addu	      t0,t0,4
	#lw	      v0, 0(t0) #Error, no se encontro el caracter en el vector de basis64
	li	      v0, 1 #Indice 0 donde esta el mensaje de error de busqueda del caracter en el vector de errores
	j	      fin_decodificar
error_lectura:
	#la	      t0,errmsg
	#addu	      t0,t0,4 	      
        #lw	      v0, 0(t0) #Error de lectura
	li 	      v0, 2 #Indice 1 donde esta el mensaje de error de lectura  en el vector de errores
	j 	      fin_decodificar
error_escritura:
	#la	      t0,errmsg
	#addu	      t0,t0,4
	#lw	      v0, 4(t0) #Error de escritura
	li	      v0, 3 #Indice 2 donde esta el mensaje de error de escritura en el vector de errores
fin_decodificar:
	#Destruimos el frame
	lw	      $fp,SF_DECODIFICAR_FP_POS(sp)
	lw	      gp,SF_DECODIFICAR_GP_POS(sp)
	lw	      ra,SF_DECODIFICAR_RA_POS(sp)
	addu	      sp,sp, SF_SIZE_DECODIFICAR
	jr	      ra
	.end 	      decodificar
	.ent read_characters
read_characters:    
    	.frame        $fp, SF_SIZE_READCH, ra
    	.set          noreorder
    	.cpload       t9
    	.set          reorder
    	subu          sp, sp, SF_SIZE_READCH      
    	#sw           ra, WRITE_RA_POS(sp)       #save ra      
    	#sw            gp, SF_READCH_GP_POS(sp)       #save gp
    	sw            $fp, SF_READCH_FP_POS(sp)      #save fp
	.cprestore    SF_READCH_GP_POS
	move 	      $fp, sp			 #fp->sp	
	
	sw            a0, 8($fp)                #save arg(infd)
    	sw            a1, 12($fp)                #save arg(outfd)

	#Comienza la lectura del archivo. Leo de a 4 caracteres
	la   a1, buffer 
	li   a2, BUFFER_SIZE   
	li   v0, SYS_read
	syscall            # read from file  

	#bnez  a3, read_characters_return #Devuelve en v0 el codigo de error
	
	#sw    a1, 16($fp) #guarda en la posicion 32 la direccion del buffer
	
	#lw   a0, 12($fp) 
	#la   t0, index
        #lw   a2, 0(t0)
	#add  a2, a2, 5 
	#li   v0, SYS_write
	#syscall             # print values
	
read_characters_return:
        # Destruimos el frame.
	sw	      a3,20($fp) #Guarda el resultado del read
	#lw            ra, WRITE_RA_POS(sp)       #restore ra
    	lw            gp, SF_READCH_GP_POS(sp)       #restore gp
    	lw            $fp, SF_READCH_FP_POS(sp)      #restore fp
        lw 	      a0, 8($fp)
	lw	      a1, 12($fp)	
 
        addu	      sp,sp, SF_SIZE_READCH		      
    	jr            ra
	.end read_characters	

.rdata
.align 2
errmsg: .word msg_error_success, msg_error_busqueda, msg_error_lectura, msg_error_escritura
.align 0
msg_error_success: .asciiz "No hubo errores en la decodificacion."
msg_error_busqueda: .asciiz "Hubo un error en la busqueda del caracter a decodificar."
msg_error_lectura: .asciiz "Hubo un error en la lectura del archivo a decodificar."
msg_error_escritura: .asciiz "Hubo un error en la escritura del archivo para la decodificacion."

#########FIN FUNCION DECODE###########

#########FUNCION ENCODE###########

    .data
    .align 2
buffer_read:      .space 4
    .align	2
array_out:        .space 4
    .align	2
array_in:         .space 3
    .align	2
basis_64:         .byte  'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/','='


    .text
    .align 2
    .globl bloqueToBase64
    .ent bloqueToBase64
bloqueToBase64:
    .frame        $fp, 24, ra
    .set          noreorder
    .cpload       t9
    .set          reorder
    subu          sp, sp, 24
    .cprestore    20
    sw            $fp, 16(sp)
    move          $fp, sp
    sw            a0, 24($fp)         # guardo in
    sw            a1, 28($fp)         # guardo out
    sw            a2, 32($fp)         # guardo len
    lbu           t1, 0(a0)          # Leo in[0]
    srl           t1, t1, 2         # Me quedo con los 6 bits mas significativos de in[0].
    la            t9, basis_64
    addu          t2, t9, t1       # Obtengo direccion basis_64 + indice_caracter
    lbu           t3, 0(t2)         # Lee codificacion basis_64[indice_caracter]
    sb            t3, 0(a1)          # Guardo codificacion en out[0]
    lbu           t1, 0(a0)          # Leo in[0]
    lbu           t2, 1(a0)          # Leo in[1]
    andi          t3, t1, 0x03      # (in[0] & 0x03)     
    sll           t3, t3, 4         # (in[0] & 0x03) << 4
    andi          t4, t2, 0xf0      # (in[1] & 0xf0)
    srl           t4, t4, 4         # (in[1] & 0xf0) >> 4
    or            t4, t4, t3       # Concateno dos bits y seis bits extraidos
    
    la            t9, basis_64
    addu          t5, t9, t4         # Obtengo direccion basis_64 + indice_caracter
    lbu           t6, 0(t5)          # Lee codificacion basis_64[indice_caracter]
    sb            t6, 1(a1)          # Guardo codificacion en out[1]
    lw            t1, 32($fp)        # leo LEN
    li            t2, 1
    ble           t1, t2, menor_igual_2  # Saltar si no cumple len > 1
    lbu           t1, 1(a0)            # Leo in[1]
    lbu           t2, 2(a0)            # Leo in[2]
    andi          t1, t1, 0x0f         # Calculo (in[1] & 0x0f)
    sll           t1, t1, 2            # Calculo en t1 (in[1] & 0x0f) << 2)
    andi          t2, t2, 0xc0
    srl           t2, t2, 6            # ((in[2] & 0xc0) >> 6))
    or            t3, t1, t2           # (((in[1] & 0x0f) << 2) | ((in[2] & 0xc0) >> 6))
    la            t9, basis_64
    addu          t5, t9, t3           # Obtengo direccion basis_64 + indice_caracter
    lbu           t6, 0(t5)            # Lee codificacion basis_64[indice_caracter]
    sb            t6, 2(a1)            # Guardo codificacion en out[2]
    j             siguiente_codigo
menor_igual_2:
    la            t9, basis_64
    lbu           t6, 64(t9)           # Obtengo el caracter '='
    sb            t6, 2(a1)            # Guardo codificacion en out[2]
siguiente_codigo:
    lw            t1, 32($fp)          # leo LEN
    li            t2, 2
    ble           t1, t2, menor_igual_3  # Saltar si no cumple len > 2
    lbu           t2, 2(a0)            # Leo in[2]
    andi          t2, t2, 0x3f         # Calculo indice = (in[2] & 0x3f)
    la            t9, basis_64         # Obtengo 1er dir de basis_64
    addu          t9, t9, t2           # Obtengo direccion basis_64[indice]
    lbu           t6, 0(t9)            # Obtengo codigo basis_64[indice]
    sb            t6, 3(a1)            # Guardo codificacion en out[3]
    j             retornar_transform
menor_igual_3:
    la            t9, basis_64
    lbu           t6, 64(t9)        # Obtengo el caracter '='
    sb            t6, 3(a1)          # Guardo codificacion en out[3]
retornar_transform:
    move          sp, $fp
    lw            $fp, 16(sp)
    lw            gp, 20(sp)
    addiu         sp, sp, 24
    jr             ra
    .end          bloqueToBase64




#define ENCODE_STACK_SIZE       64
#define ENCODE_VAR_RA           60
#define ENCODE_VAR_GP           56
#define ENCODE_VAR_FP           52
#define WRITE_FILENO_IN         28
#define WRITE_FILENO_OUT        32

#define VAR_READ_CODE          40  
#define VAR_RETCODE            24
#define VAR_LEN                20
#define VAR_I                  16


    .text
    .align 2
    .globl base64_encode
    .ent base64_encode
base64_encode:
    .frame        $fp, ENCODE_STACK_SIZE, ra  
    .set          noreorder
    .cpload       t9
    .set          reorder
    subu          sp, sp, ENCODE_STACK_SIZE      
    .cprestore    ENCODE_VAR_GP
    sw            ra, ENCODE_VAR_RA(sp)       #save ra      
    sw            $fp, ENCODE_VAR_FP(sp)      #save $fp
    move          $fp, sp
    li            t0, 1
    sw            t0, VAR_READ_CODE(sp)     # read_code 
    sw            zero, VAR_RETCODE(sp)     # retcode 
    sw            a0, WRITE_FILENO_IN($fp)     # Guardo file descriptor entrada
    sw            a1, WRITE_FILENO_OUT($fp)    # Guardo file descriptor salida
while_read_code:
    lw            t0, VAR_READ_CODE($fp)        # Leemos codigo retorno de read
    li            t1, 1                         # Se lee de 1 byte
    bne           t0, t1, return_codificar      # Mientras se lea un byte - while (read_code == 1)  
    sw            zero, VAR_LEN($fp)            # len = 0
    lw            t1, VAR_LEN($fp)              # t1<---len
    sw            zero, VAR_I($fp)              # Incializamos i = 0 para leer arch entrada

for_entrada:
    lw            t2, VAR_I($fp)                # Loop for para lectura
    li            t3, 3                         # Leemos hasta 3 bytes
    bge           t2, t3, aplicar_codificacion  # Si ya leimos 3, salto a aplicar_codificacion
    lw            a0, WRITE_FILENO_IN($fp)      # Cargamos parametro 1 file descriptor entrada
    la            a1, buffer_read               # Cargamos direccion del buffer de lectura
    li            a2, 1                         # Cargamos longitud de lectura
    li            v0, SYS_read                  # Cargamos syscall READ
    syscall                                     # Seria read(fileDescriptorEntrada, byte_read, 1);
    bnez          v0, else_if_uno               # Si v0 es cero continuo, sino salto a 'else_if_uno'
    la            t6, array_in                  # v0 fue cero, o sea que no leyo nada
    lw            t2, VAR_I($fp)                # Tomo valor de I
    addu          t7, t6, t2                    # Calculo direccion de in[i]
    sb            zero, 0(t7)                   # Guardo cero en in[i]
    sw            zero, VAR_READ_CODE($fp)      # Actualizamos codigo retorno de read
    j             continuar_for                 # vemos si continuamos
else_if_uno:
    li            t4, 1                         # Vemos si leimos 1 byte
    bne           v0, t4, else_error_file_in    # Si no leimos 1 byte, salto por q dio error
    la            t5, buffer_read               # Cargo la direccion del buffer de lectura
    lbu           t5, 0(t5)                     # Obtengo el byte leido en t5
    la            t6, array_in                  # Cargo la direccion del BLOQUE in[]
    lw            t2, VAR_I($fp)                # Tomo valor de I
    addu          t7, t6, t2                    # Calculo direccion de in[i]
    sb            t5, 0(t7)                     # Guardo el dato t5 en in[i]
    lw            t2, VAR_LEN($fp)              # Leo LEN
    add           t2, t2, 1                     # Actualizo LEN++
    sw            t2, VAR_LEN($fp)              # Guardo LEN
    j             continuar_for                 # Siguiente iteracion
else_error_file_in:
    li            t4, 1                         # Cargo codigo de error
    sw            t4, VAR_RETCODE($fp)          # retcode = 1
    j             return_codificar
continuar_for:
    lw            t2, VAR_I($fp)               # t2<---i
    addiu         t2, t2, 1                    # i++ para el for de lectura
    sw            t2, VAR_I($fp)               # Guardo i++
    j             for_entrada


aplicar_codificacion:
    lw            t2, VAR_LEN($fp)             # Obtenemos cuanto vale len
    bgtz          t2, mapear_base64            # if len > 0 codificar
    j             while_read_code
mapear_base64:                 
    la            a0, array_in
    la            a1, array_out
    lw            a2, VAR_LEN($fp)
    jal           bloqueToBase64               # Llamamo a bloqueToBase64
    sw            zero, VAR_I($fp)             # i = 0
for_salida:
    lw            t2, VAR_I($fp)               # t2<---i
    li            t4, 4
    bge           t2, t4, otro_while           # Itererar para escribir en file desc salida
    la            t3, array_out                # Leo direccion de 'array_out'
    addu          t5, t3, t2                   # t5 = out[i]   bloque de salida
    lbu           t7, 0(t5)                    # ?????????
    lw            a0, WRITE_FILENO_OUT($fp)
    move          a1, t5
    li            a2, 1
    li            v0, SYS_write  
    syscall                                    #write(fileDescriptorSalida, (void*)(&out[i]), 1);
    addiu         t2, t2, 1
    sw            t2, VAR_I($fp)
    j             for_salida
otro_while:                                    # Itero la siguiente terna de bytes
    j             while_read_code
return_codificar:
    lw            v0, VAR_RETCODE(sp)          # Liberamos el stack frame
    move          sp, $fp
    lw            $fp,  ENCODE_VAR_FP(sp)
    lw            gp, ENCODE_VAR_GP(sp)
    lw            ra, ENCODE_VAR_RA(sp)        
    addu          sp, sp, ENCODE_STACK_SIZE 
    jr             ra
    .end          base64_encode

#########FIN FUNCION ENCODE###########

