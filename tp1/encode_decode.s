
#include <mips/regdef.h>
#include <sys/syscall.h>

66
    +-----------------+
62  |       ra        |
    +-----------------+
58  |       gp        |
    +-----------------+
54  |       fp        |
    +-----------------+
48  |                 |
    +-----------------+
44  |                 |
    +-----------------+
40  |    read_code    |
    +-----------------+
36  |    CHAR_READ    |
    +-----------------+
32  |   fileno_out    |
    +-----------------+
28  |   fileno_in     |
    +-----------------+
24  |      retcode    |
    +-----------------+
20  |        len      |
    +-----------------+
16  |        i        |
    +-----------------+
12  |                 |
    +-----------------+
8   |                 |
    +-----------------+
4   |                 |
    +-----------------+
0   |                 |
    +-----------------+

#define WRITE_STACK_SIZE       40
#define WRITE_RA_POS           62
#define WRITE_GP_POS           58
#define WRITE_FP_POS           54
#define WRITE_FILENO_IN        28
#define WRITE_FILENO_OUT       32

#define VAR_READ_CODE          40  
#define VAR_RETCODE            24
#define VAR_LEN                20
#define VAR_I                  16

#define CHAR_READ              32

#define FLUSH_STACK_SIZE       16
#define FLUSH_GP_POS           12
#define FLUSH_FP_POS           8

#define BUFFER_SIZE            5




    .text
    .align 2
    .globl base64_encode
    .ent base64_encode
base64_encode:
    .frame        $fp, WRITE_STACK_SIZE, ra  
    .set          noreorder
    .cpload       t9
    .set          reorder
    subu          sp, sp, WRITE_STACK_SIZE      
    .cprestore    WRITE_GP_POS
    sw            ra, WRITE_RA_POS(sp)       #save ra      
    sw            $fp, WRITE_FP_POS(sp)      #save fp
    move          $fp, sp
    li            t0, 1
    sw            t0, VAR_READ_CODE($fp)     # read_code = 1
while_read_code:
    lw            t0, VAR_READ_CODE($fp)
    li            t1, 1
    bne           t0, t1, RETURN_CODE        # while (read_code == 1)
    sw            $zero, VAR_LEN($fp)        # len = 0
    lw            t1, VAR_LEN($fp)           # t1<---len
    sw            $zero, VAR_I($fp)          # i = 0
for_entrada:
    lw            t2, VAR_I($fp)             # t2<---i
    li            t3, 3
    bge           t2, t3, aplicar_codificacion  # for (int i =0; i< 3; i++)
    sw            a0, WRITE_FILENO_IN($fp)
    sw            a1, WRITE_FILENO_OUT($fp)
    lw            a0, WRITE_FILENO_IN($fp)
    la            a1, buffer_read
    li            a2, 1
    li            v0, SYS_read                
    syscall                                    #read(fileDescriptorEntrada, byte_read, 1);
    bnez          a3, else_if_uno              # if (read_code == 0)
    lbu           t5, $zero
    la            t6, array_in
    addu          t7, t6, t3                   # t7 <--- *in[i]
    sb            t5, 0(t7)                    # *t7 <--- byte_read
    j             continuar_for
else_if_uno:
    li            t4, 1
    bne           a3, t4, else_error_file_in
    lbu           t5, 0(buffer_read)
    la            t6, array_in
    addu          t7, t6, t3                   # t7 <--- *in[i]
    sb            t5, 0(t7)                    # *t7 <--- byte_read
    j             continuar_for
else_error_file_in:
    li            t4, 1
    sw            t4, VAR_RETCODE($fp)         # retcode = 1
    j             return_codificar
continuar_for:
    lw            t2, VAR_I($fp)               # t2<---i
    addiu         t2, t2, 1
    sw            t2, VAR_I($fp)
    j             for_entrada
aplicar_codificacion:
    lw            t2, VAR_LEN($fp)
    bgtz          t2, aplicar_base64
    j             while_read_code
aplicar_base64:                 
    la            a0, array_in
    la            a1, array_out
    lw            a2, VAR_LEN($fp)
    jal           bloqueToBase64             # VER        
    sw            $zero, VAR_I($fp)          # i = 0
for_salida:
    lw            t2, VAR_I($fp)             # t2<---i
    li            t4, 4
    bge           t2, t4, otro_while         # for (int i =0; i< 3; i++)
    la            a1, array_out
    addu          t5, t4, t2                 # t5 = out[i]   bloque de salida
    lw            a0, WRITE_FILENO_OUT($fp)
    la            a1, t5
    li            a2, 1
    li            v0, SYS_write  
    syscall                                    #write(fileDescriptorSalida, (void*)(&out[i]), 1);
    addiu         t2, t2, 1
    j             for_salida
otro_while:
    j             while_read_code
return_codificar:
    move          sp, $fp
    lw            $fp,  WRITE_FP_POS(sp)
    lw            gp, WRITE_GP_POS(sp)
    addu          sp, sp, WRITE_STACK_SIZE
    j             ra
    .end          codificar

    .data
    .align 2
buffer_read:      .space 4
array_out:        .space 4
array_in:         .space 3
basis_64:         .byte  'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/','='





    +-----------------+
32           len 
    +-----------------+
28           out
    +-----------------+
24           in
    +-----------------+
20  |        gp       |
    +-----------------+
16  |        fp       |
    +-----------------+
12  |                 |
    +-----------------+
8   |                 |
    +-----------------+
4   |                 |
    +-----------------+
0   |                 |
    +-----------------+




    .text
    .align 2
    .globl bloqueToBase64
    .ent bloqueToBase64
bloqueToBase64:
    .frame $fp, 24, ra
    .set          noreorder
    .cpload       t9
    .set          reorder
    subu          sp, sp, 24
    .cprestore    20
    sw            $fp, 16(sp)
    move          $fp, sp
    sw            a0, 24($fp)         # guardo in
    sw            a1, 28($fp)         # guardo out
    sw            a1, 32($fp)         # guardo len
    lbu           $t1, (0)a0          # Leo in[0]
    srl           $t1, $t1, 2         # Me quedo con los 6 bits mas significativos de in[0].
    la            $t9, basis_64
    addu          $t2, $t9, $t1       # Obtengo direccion basis_64 + indice_caracter
    lbu           $t3, 0($t2)         # Lee codificacion basis_64[indice_caracter]
    sb            $t3, 0(a1)          # Guardo codificacion en out[0]
    lbu           $t1, (0)a0          # Leo in[0]
    lbu           $t2, (1)a0          # Leo in[1]
    andi          $t3, $t1, 0x03      # (in[0] & 0x03)     
    sll           $t3, $t3, 4         # (in[0] & 0x03) << 4
    andi          $t4, $t2, 0xf0      # (in[1] & 0xf0)
    srl           $t4, $t4, 4         # (in[1] & 0xf0) >> 4
    or            $t4, $t4, $t3       # Concateno dos bits y seis bits extraidos
    
    la            $t9, basis_64
    addu          $t5, $t9, $t4       # Obtengo direccion basis_64 + indice_caracter
    lbu           $t6, 0($t5)         # Lee codificacion basis_64[indice_caracter]
    sb            $t3, 1(a1)          # Guardo codificacion en out[1]

    lw            $t1, 32($fp)        # leo LEN
    li            $t2, 1
    ble           $t1, $t2, map_igual_2  # Saltar si no cumple len > 1
    lbu           $t1, (1)a0          # Leo in[1]
    lbu           $t2, (2)a0          # Leo in[2]
    andi          $t1, $t1, 0x0f
    sll           $t1, $t1, 2
    andi          $t2, $t2, 0xc0
    srl           $t2, $t2, 6         # ((in[2] & 0xc0) >> 6))
    or            $t3, $t2, $t2       # (((in[1] & 0x0f) << 2) | ((in[2] & 0xc0) >> 6))

    la            $t9, basis_64
    addu          $t5, $t9, $t3       # Obtengo direccion basis_64 + indice_caracter
    lbu           $t6, 0($t5)         # Lee codificacion basis_64[indice_caracter]
    sb            $t6, 2(a1)          # Guardo codificacion en out[2]
    j             siguiente_codigo
map_igual_2:
    la            $t9, basis_64
    lbu           $t6, 64($t9)        # Obtengo el caracter '='
    sb            $t6, 2(a1)          # Guardo codificacion en out[2]
siguiente_codigo:
    lw            $t1, 32($fp)        # leo LEN
    li            $t2, 2
    ble           $t1, $t2, map_igual_3  # Saltar si no cumple len > 2
    lbu           $t2, (2)a0          # Leo in[2]
    andi          $t2, $t2, 0x3f      # Calculo indice = (in[2] & 0x3f)
    la            $t9, basis_64       # Obtengo 1er dir de basis_64
    addu          $t9, $t9, $t2       # Obtengo direccion basis_64[indice]
    lbu           $t6, 0($t9)         # Obtengo codigo basis_64[indice]
    sb            $t6, 3(a1)          # Guardo codificacion en out[3]
    j             retornar_bloqueToBase64
map_igual_3:
    la            $t9, basis_64
    lbu           $t6, 64($t9)        # Obtengo el caracter '='
    sb            $t6, 3(a1)          # Guardo codificacion en out[3]
retornar_bloqueToBase64:
    move          sp, $fp
    lw            $fp, 16(sp)
    lw            gp, 20(sp)
    addiu         sp, sp, 24
    j             ra
    .end          bloqueToBase64









#include <mips/regdef.h>
#include <sys/syscall.h>

#define WRITE_STACK_SIZE       56
#define WRITE_RA_POS           52
#define WRITE_GP_POS           48
#define WRITE_FP_POS           44

#define FLUSH_STACK_SIZE       16
#define FLUSH_GP_POS           12
#define FLUSH_FP_POS           8

#define BUFFER_SIZE            5

.data
.align 2
index:  .word -1
buffer: .space BUFFER_SIZE


.text
.abicalls
.align 2
.global buff_write
.ent buff_write

buff_write:    
    .frame        $fp, WRITE_STACK_SIZE, ra
    .set          noreorder
    .cpload       t9
    .set          reorder
    subu          sp, sp, WRITE_STACK_SIZE      
    sw            ra, WRITE_RA_POS(sp)       #save ra      
    sw            gp, WRITE_GP_POS(sp)       #save gp
    sw            $fp, WRITE_FP_POS(sp)      #save fp
    sw            s6, 40(sp)                 #save s6
    sw            s5, 36(sp)                 #save s5
    sw            s4, 32(sp)                 #save s4
    sw            s3, 28(sp)                 #save s3
    sw            s2, 24(sp)                 #save s2
    sw            s1, 20(sp)                 #save s1
    sw            s0, 16(sp)                 #save s0
    move          $fp, sp                    #fp->sp
    
    sw            a0, 56($fp)                #save arg(fd)
    sw            a1, 60($fp)                #save arg(str)
    sw            a2, 64($fp)                #save arg(size)

    move          s0, a0                     #s0 == fd
    move          s1, a1                     #s1 == str
    move          s2, a2                     #s2 == size

    li            s3, 0                      #s3 == result = 0
    li            s4, 0                      #s4 == i = 0
    la            s5, buffer                 #s5 == *buf
    la            t0, index                  
    lw            s6, 0(t0)                  #s6 == index
    
loop:
    bge          s4, s2, end                # if (i >= size)
    la           t0, index                  
    lw           s6, 0(t0)                  #s6 == index
    add          s6, s6, 1                  #++index    
    la           t0, index                  
    sw           s6, 0(t0)                  #save index
    addu         t0, s1, s4                 #t0 <- *str + i     (str[i])

    lb           t0, 0(t0)                  #t0 <- str[i]
    sb           t0, buffer(s6)             #t0 -> buffer[index]
    
    li           t0, BUFFER_SIZE
    subu         t0, t0, 1                  #buffer_size-1    
    bne         s6, t0, continue      
    move         a0, s0                     #a0 <- fd
    la           t9, buff_flush
    jalr         t9
    move         s3, v0                     #s3 <- result    
    bltz         s3, end

continue:
   
    addu         s4, s4, 1                  #++i
    j            loop

end:
    #finalizacion
    move          v0, s3                     #v0 <- result
    lw            ra, WRITE_RA_POS(sp)       #restore ra
    lw            gp, WRITE_GP_POS(sp)       #restore gp
    lw            $fp, WRITE_FP_POS(sp)      #restore fp 
    lw            s6, 40(sp)                 #restore s6
    lw            s5, 36(sp)                 #restore s5
    lw            s4, 32(sp)                 #restore s4
    lw            s3, 28(sp)                 #restore s3
    lw            s2, 24(sp)                 #restore s2
    lw            s1, 20(sp)                 #restore s1
    lw            s0, 16(sp)                 #restore s0     
    addu          sp, sp, WRITE_STACK_SIZE   #restore sp
    jr            ra
    .end          buff_write




.global buff_flush
.ent buff_flush




buff_flush:    
    .frame        $fp, FLUSH_STACK_SIZE, ra

    subu          sp, sp, FLUSH_STACK_SIZE          
    sw            gp, FLUSH_GP_POS(sp)        #save gp
    sw            $fp, FLUSH_FP_POS(sp)       #save fp
    move          $fp, sp                     #fp->sp

    sw            a0, 16($fp)                 #save fd
    la            a1, buffer                  #a1 <- buffer
    la            t0, index                  
    lw            a2, 0(t0)                   #a2 <- index
    add           a2, a2, 1                   #a2 <- index + 1
    li            v0, SYS_write
    syscall                                   #llamo en sys_write
                                              #en v0 me deja el resultado

    bnez          a3, quit                    #chequeo a3 para ver si
                                              #el syscall se ejecuto bien
    
    li            t0, -1                      #index = -1
    la            t1, index               
    sw            t0, 0(t1)
    #finalizacion
    lw            gp, FLUSH_GP_POS(sp)              #restore gp
    lw            $fp, FLUSH_FP_POS(sp)             #restore fp      
    addu          sp, sp, FLUSH_STACK_SIZE          #restore sp
    jr            ra

quit:
    li            a0, -1
    li            v0, SYS_exit
    syscall
    .end          buff_flush