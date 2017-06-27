#include <mips/regdef.h>
#include <sys/syscall.h>

#########FUNCION DECODE###########

#STATICS VAR DEFINITIONS FUNCTION DECODIFICAR
#define SF_SIZE_DECODIFICAR       56 
#define SF_DECODIFICAR_GP_POS     40 
#define SF_DECODIFICAR_FP_POS     44  
#define SF_DECODIFICAR_RA_POS     48 
 

#STATICS VAR DEFINITIONS FUNCTION READ CHARACTERS
#define SF_SIZE_READCH             16
#define SF_READCH_VAR_I            4  
#define SF_READCH_GP_POS           8 
#define SF_READCH_FP_POS           12 

#define BUFFER_SIZE                1  


.text
.abicalls
.align 2
.globl decodificar 
.ent decodificar

decodificar:
	.frame 	      $fp, SF_SIZE_DECODIFICAR, ra
	.set	      noreorder
	.cpload	      t9
	.set	      reorder
	subu	      sp, sp, SF_SIZE_DECODIFICAR
	sw	          ra, SF_DECODIFICAR_RA_POS(sp)
	sw	          $fp, SF_DECODIFICAR_FP_POS(sp) 
    .cprestore    SF_DECODIFICAR_GP_POS
	move	      $fp, sp
	sw	          a0, 56($fp)           #Guardo FD in
    sw            a1, 60($fp)           #Guardo FD out

obtener_enteros:                        #LEO LOS 4 PRIMEROS CARACTERES
	lw	           a0, 56($fp)           
	lw             a1, 60($fp)
    jal            read_characters       # Leemos 4 caracteres
     
    li             t0, 0 
    blt            v0,t0,error_lectura   # Salto si retorno < 0, a informar error
    beqz           v0,fin_success        # Salto si es EOF
    li             t0, 4 
    blt            v0,t0,err_lect_incomp # Salto si 0< retorno < 4, a informar error

    li             t5, 3                 # Cantidad de bytes maximo por bloque de salida
    sw             t5, 16($fp)           # Esta cantidad puede ir de 1 a 3

    la             t0, buffer            # Cargo direccion de buffer con los 4 elementos leidos
    sw             t0, 20($fp)           # Guardo el buffer en stack, y uso el stack

    lb             t0, 0(t0)             #Leo caracter primera posicion
    move           a0, t0     
    jal            search_b64            #Obtengo valorEntero1 (indice) de la tabla base64
    bltz           v0, error_busqueda
    sw             v0, 24($fp)           #Resultado valorEntero 1

    lw             t0, 20($fp)           # Leo el buffer del stack
    lb             t0, 1(t0)             # Leo el segundo caracter
    move           a0, t0
    jal            search_b64            #Obtengo valorEntero1 (indice) de la tabla base64
    bltz           v0, error_busqueda
    move           t1, v0                #Resultado valorEntero 2
    sw             t1, 28($fp)

    lw             t0, 20($fp)
    lb             t0, 2(t0)             #Leo el tercer caracter

    la             t9, basis_64           # levando basis_64
    lb             t6, 64(t9)             # Obtengo el caracter '='
    beq            t0, t6, descontar_uno  # saltar si el caracter leido es =

    move           a0, t0
    jal            search_b64
    bltz           v0, error_busqueda
    move           t1, v0                 #Resultado valorEntero 3
    sw             t1, 32($fp)            
    j              leer_cuarto_byte
descontar_uno:
    lw             t5, 16($fp)           # Leo Contador LEN_OUT de bytes tranformados
    subu           t5, t5, 1             # Resto en uno a LEN_OUT de bytes tranformados
    sw             t5, 16($fp)

leer_cuarto_byte:
    lw             t0, 20($fp)
    lb             t0, 3(t0) #Leo el cuarto caracter

    la             t9, basis_64           # levando basis_64
    lb             t6, 64(t9)             # Obtengo el caracter '='
    beq            t0, t6, descontar_segundo  # saltar si el caracter leido es =

    move           a0, t0
    jal            search_b64
    bltz           v0, error_busqueda
    move           t4, v0 #Resultado valorEntero 4 
    sw             t4, 36($fp)
    j             continuar_deco
descontar_segundo:
    lw            t5, 16($fp)           # Leo Contador LEN_OUT de bytes tranform
    subu          t5, t5, 1           # Resto en uno a LEN_OUT de bytes tranfo
    sw            t5, 16($fp)

continuar_deco:
     
    lw            t5, 16($fp)
    la            t6, buffer_write

    li            t1, 3                  # Voy a obtner 3 bytes de salida
    beq           t5,t1,continuar_deco4  # Salto pa decodificar 4 y obtner 3 byte

    li            t1, 2
    beq           t5,t1,continuar_deco3  # Salto pa decodificar 3 y obtner 2 byte

    li            t1, 1                   
    beq           t5,t1,continuar_deco2  # Salto pa decodificar 3 y obtner 2 byte

continuar_deco4:  
    lw            t1,24($fp)
    lw            t2,28($fp)
    lw            t3,32($fp)
    lw            t4,36($fp)

    bltz          t1,fin_decodificar
    li            t5,63
    bgt           t1,t5,fin_decodificar

    li            t5,64
    bltz          t2,fin_decodificar
    bgt           t2,t5,fin_decodificar

    bltz          t3,fin_decodificar
    bgt           t3,t5,fin_decodificar

    bltz          t4,fin_decodificar
    bgt           t4,t5,fin_decodificar

    li            t5,2
    sll           s0,t1,t5 #valorEntero1<<2
    li            t5,4
    srl           s1,t2,t5 #valorEntero2>>4
    or            s0,s0,s1 #valorEntero1<<2 | valorEntero2>>4
    sb            s0, 0(t6)

    li            t5,4
    sll           s0,t2,t5 #valorEntero2<<4
    li            t5,2
    srl           s1,t3,t5 #valorEntero3>>2
    or            s0,s0,s1 #valoreEntero2<<4 | valorEntero3>>2
    sb            s0, 4(t6)

    li            t5,6
    sll           s0,t3,t5 #valorEntero3<<6
    or            s0,s0,t4 #valorEntero3<<6 | valorEntero4
    sb            s0, 8(t6)
    j             escribir_decode

continuar_deco3:     
    lw            t1,24($fp)
    lw            t2,28($fp)
    lw            t3,32($fp)

    bltz          t1,fin_decodificar
    li            t5,63
    bgt           t1,t5,fin_decodificar

    li            t5,64
    bltz          t2,fin_decodificar
    bgt           t2,t5,fin_decodificar

    bltz          t3,fin_decodificar
    bgt           t3,t5,fin_decodificar

    li            t5,2
    sll           s0,t1,t5 #valorEntero1<<2
    li            t5,4
    srl           s1,t2,t5 #valorEntero2>>4
    or            s0,s0,s1 #valorEntero1<<2 | valorEntero2>>4
    sb            s0, 0(t6)

    li            t5,4
    sll           s0,t2,t5 #valorEntero2<<4
    li            t5,2
    srl           s1,t3,t5 #valorEntero3>>2
    or            s0,s0,s1 #valoreEntero2<<4 | valorEntero3>>2
    sb            s0, 4(t6)
    j               escribir_decode

continuar_deco2:
    lw            t1,24($fp)
    lw            t2,28($fp)

    bltz          t1,fin_decodificar
    li            t5,63
    bgt           t1,t5,fin_decodificar

    li            t5,64
    bltz          t2,fin_decodificar
    bgt           t2,t5,fin_decodificar

    li            t5,2
    sll           s0,t1,t5 #valorEntero1<<2
    li            t5,4
    srl           s1,t2,t5 #valorEntero2>>4
    or            s0,s0,s1 #valorEntero1<<2 | valorEntero2>>4
    sb            s0, 0(t6)

escribir_decode:
    la            t6, buffer_write          # Cargamos resultados a escribir
    lw            a0, 60($fp)               # Vamos por el PRIMERO caracter del bloque. Leo fd_out
    move          a1, t6                    # Cargo direccion del word a escribit
    li            a2, 1
    li            v0, SYS_write
    syscall
    bnez           a3, error_escritura

escribir_caracter_dos:

    li            t6, 2 
    lw            t5, 16($fp)           # Leo Contador LEN_OUT de bytes tranformados
    blt           t5, t6, fin_success 
    la            t6, buffer_write          # Cargamos resultados a escribir
    lw            a0, 60($fp)               # Vamos por el SEGUNDO caracter del bloque
    addiu         a1, t6, 4                 # Calculo direccion del siguiente word, para escritura
    li            a2, 1                     # solo imprimimos el primer byte del word
    li            v0, SYS_write
    syscall                              
    bnez          a3, error_escritura

escribir_caracter_tres:    
    
    li            t6, 3 
    lw            t5, 16($fp)           # Leo Contador LEN_OUT de bytes tranformados
    blt           t5, t6, fin_success 

    la            t6, buffer_write          # Cargamos resultados a escribir
    lw            a0, 60($fp)               # Vamos por el TERCER caracter del bloque
    addiu         a1, t6, 8                 # Calculo direccion del siguiente word, para escritura
    li            a2, 1                     # solo imprimimos el primer byte del word
    li            v0, SYS_write
    syscall
    bnez          a3, error_escritura                               
    j            obtener_enteros

fin_success:
    li           v0, 0
    j           fin_decodificar
err_lect_incomp:
    li           v0, 6
    j           fin_decodificar
error_busqueda:     
    li           v0, 1 #Indice 0 donde esta el mensaje de error de busqueda del caracter en el vector de errores
    j           fin_decodificar
error_lectura:
    li           v0, 2 #Indice 1 donde esta el mensaje de error de lectura  en el vector de errores
    j            fin_decodificar
error_escritura:
    li           v0, 3 #Indice 2 donde esta el mensaje de error de escritura en el vector de errores
fin_decodificar:
    move         sp, $fp
    lw           $fp,SF_DECODIFICAR_FP_POS(sp)   #Destruimos el frame
    lw           gp,SF_DECODIFICAR_GP_POS(sp)
    lw           ra,SF_DECODIFICAR_RA_POS(sp)
    addu         sp,sp, SF_SIZE_DECODIFICAR
    jr           ra
    .end         decodificar


    .text
    .abicalls
    .align 2
    .globl read_characters
    .ent read_characters
read_characters:    
     .frame        $fp, SF_SIZE_READCH, ra
     .set          noreorder
     .cpload       t9
     .set          reorder
     subu          sp, sp, SF_SIZE_READCH      
     sw            $fp, SF_READCH_FP_POS(sp)      #save fp
     .cprestore    SF_READCH_GP_POS
     move            $fp, sp                  #fp->sp     
     sw            a0, 16($fp)                     #save arg(infd)
     sw            zero, SF_READCH_VAR_I($fp)     # i=0
for_read_decode:
     la            t0, buffer                # Carga la dir donde guardar
     lw            t1, SF_READCH_VAR_I($fp)       # Cargo i
     addu          t0, t0, t1                     # Obtengo dir de buffer[i]
     lw            a0, 16($fp)
     move          a1, t0                         
     li            a2, BUFFER_SIZE                
     li            v0, SYS_read
     syscall                                      # read from file  
     blez          v0, fin_lectura_deco           # Salto si es menor o igual q 0
     lw            t0, SF_READCH_VAR_I($fp)       # Cargo i
     addiu         t0, t0, 1                      # i++
     sw            t0, SF_READCH_VAR_I($fp)       #Guardo i
     li            t1, 4
     blt           t0, t1, for_read_decode        # Salto si i<4
fin_lectura_deco:
     lw            v0, SF_READCH_VAR_I($fp)       # Cargo i
     move          sp,$fp
     lw            gp, SF_READCH_GP_POS(sp)       #restore gp
     lw            $fp, SF_READCH_FP_POS(sp)      #restore fp
     addu          sp,sp, SF_SIZE_READCH           
     jr            ra
     .end          read_characters     


# 
# Funcion busqueda de posicion de caracter en vector basis 64
#

#define LOCATE_ARG0_SF_SEARCH_B64 16
#define SIZE_SF_SEARCH_B64        16 
#define LOCATE_GP_SF_SEARCH_B64   12 
#define LOCATE_FP_SF_SEARCH_B64   8 
#define VAR_INDEX_TABLE           4 
#define RETURN_SUCCESS  0
#define RETURN_ERROR    -1      

    .text
    .align  2
    .globl      search_b64  
    .ent        search_b64  
search_b64:
    .frame      $fp,SIZE_SF_SEARCH_B64, ra
    .set        noreorder
    .cpload     t9
    .set        reorder
    subu        sp, sp, SIZE_SF_SEARCH_B64 
    .cprestore  LOCATE_GP_SF_SEARCH_B64
    sw          $fp, LOCATE_FP_SF_SEARCH_B64(sp)
    move        $fp, sp
    sw          a0, LOCATE_ARG0_SF_SEARCH_B64($fp)

    li          v0, 0                       # Usamos V0 para el resultado
    sw          zero, VAR_INDEX_TABLE($fp)  # Agrego indice pare recorer tabla
search_loop:
    la          t0, basis_64
    lw          t1, VAR_INDEX_TABLE($fp)    # t1=index
    addu        t1, t0, t1                  # t1=&basis_64[index]
    lb          t5, 0(t1)                   # t1=basis_64[index]
    beq         a0, t5,search_return        # saltar si encontramos el codigo
    lw          t2, VAR_INDEX_TABLE($fp)    # t2=index
    li          t3, 64              # Para saber si no esta en el array el caracter buscado 
    beq         t2, t3,error_return  # Si ya llego al ultimo de  la tabla, no se encuentra el codigo
    lw          t1, VAR_INDEX_TABLE($fp)    # t1=index
    addiu       t1, t1,1                     #Avanzo de a 1 byte
    sw          t1, VAR_INDEX_TABLE($fp)    # guardo t1=index
    j           search_loop
error_return:
    li          v0, RETURN_ERROR                     #Error. No se encontro en el array el caracter buscado
search_return:
    lw          v0, VAR_INDEX_TABLE($fp)    # t1=index
    move        sp, $fp
    lw          $fp, LOCATE_FP_SF_SEARCH_B64(sp)        # Destruimos el frame.
    lw          gp, LOCATE_GP_SF_SEARCH_B64(sp)
    addu        sp, sp, SIZE_SF_SEARCH_B64 
    jr          ra
    .end        search_b64  

#########FIN FUNCION DECODE###########

#########FUNCION ENCODE###########

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
    li            t4, 4                         # Cargo codigo de error
    sw            t4, VAR_RETCODE($fp)          # 
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
    lw            a0, WRITE_FILENO_OUT($fp)
    move          a1, t5
    li            a2, 1
    li            v0, SYS_write  
    syscall                                    #write(fileDescriptorSalida, (void*)(&out[i]), 1);
    bgez          v0, siguiente_escritura
    li            t4, 5                         # Cargo codigo de error
    sw            t4, VAR_RETCODE($fp)          # retcode = 1
    j             return_codificar
siguiente_escritura:
    lw            t2, VAR_I($fp)               # t2<---i
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



    .data
    .align 2
    buffer:           .space 4 
    .align      2
    buffer_write:     .space 4 
    .align      2

    .align      2
    buffer_read:      .space 4
    .align      2
    array_out:        .space 4
    .align      2
    array_in:         .space 3

    .rdata
    .align 2
    .globl errmsg
    errmsg: .word msg_error_success, msg_error_busqueda, msg_error_lectura, msg_error_escritura, msg_error_lectura_codif, msg_error_escritura_codif, msg_error_lect_incomplet
    .align 2
    msg_error_success: .asciiz "No hubo errores en la decodificacion."
    msg_error_busqueda: .asciiz "Hubo un error en la busqueda del caracter a decodificar."
    msg_error_lectura: .asciiz "Hubo un error en la lectura del archivo a decodificar."
    msg_error_escritura: .asciiz "Hubo un error en la escritura del archivo para la decodificacion."
    msg_error_lectura_codif: .asciiz "Hubo un error en la lectura del archivo para codificar."
    msg_error_escritura_codif: .asciiz "Hubo un error en la escritura del archivo cuando codificamos"
    msg_error_lect_incomplet: .asciiz "Lectura incompleta de bloques a decodificar"
    basis_64:         .asciiz  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
