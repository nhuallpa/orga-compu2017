#include <mips/regdef.h>
#include <sys/syscall.h>

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
    andi          t1, t1, 0x0f
    sll           t1, t1, 2
    andi          t2, t2, 0xc0
    srl           t2, t2, 6            # ((in[2] & 0xc0) >> 6))
    or            t3, t2, t2           # (((in[1] & 0x0f) << 2) | ((in[2] & 0xc0) >> 6))
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
    j             retornar_bloqueToBase64
menor_igual_3:
    la            t9, basis_64
    lbu           t6, 64(t9)        # Obtengo el caracter '='
    sb            t6, 3(a1)          # Guardo codificacion en out[3]
retornar_bloqueToBase64:
    move          sp, $fp
    lw            $fp, 16(sp)
    lw            gp, 20(sp)
    addiu         sp, sp, 24
    j             ra
    .end          bloqueToBase64




#define WRITE_STACK_SIZE       66
#define WRITE_RA_POS           62
#define WRITE_GP_POS           58
#define WRITE_FP_POS           54
#define WRITE_FILENO_IN        28
#define WRITE_FILENO_OUT       32

#define VAR_READ_CODE          40  
#define VAR_RETCODE            24
#define VAR_LEN                20
#define VAR_I                  16


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
    sw            $fp, WRITE_FP_POS(sp)      #save $fp
    move          $fp, sp
    li            t0, 1
    sw            t0, 40(sp)     # read_code 
    sw            zero, 24(sp)     # retcode 
#  while_read_code:
#      lw            t0, VAR_READ_CODE($fp)
#      li            t1, 1
#      bne           t0, t1, return_codificar        # while (read_code == 1)
#      sw            zero, VAR_LEN($fp)        # len = 0
#      lw            t1, VAR_LEN($fp)           # t1<---len
#      sw            zero, VAR_I($fp)          # i = 0
#  for_entrada:
#      lw            t2, VAR_I($fp)             # t2<---i
#      li            t3, 3
#      bge           t2, t3, aplicar_codificacion  # for (int i =0; i< 3; i++)
#      sw            a0, WRITE_FILENO_IN($fp)     # Guardo file descriptor entrada
#      sw            a1, WRITE_FILENO_OUT($fp)    # Guardo file descriptor salida
#      lw            a0, WRITE_FILENO_IN($fp)
#      la            a1, buffer_read
#      li            a2, 1
#      li            v0, SYS_read                
#      syscall                                    #read(fileDescriptorEntrada, byte_read, 1);
#      bnez          a3, else_if_uno              # if (read_code == 0)
#      la            t6, array_in
#      addu          t7, t6, t3                   # t7 <--- *in[i]
#      sb            zero, 0(t7)                    # *t7 <--- byte_read
#      j             continuar_for
#  else_if_uno:
#      li            t4, 1
#      bne           a3, t4, else_error_file_in
#      la            t5, buffer_read
#      lbu           t5, 0(t5)
#      la            t6, array_in
#      addu          t7, t6, t3                   # t7 <--- *in[i]
#      sb            t5, 0(t7)                    # *t7 <--- byte_read
#      j             continuar_for
#  else_error_file_in:
#      li            t4, 1
#      sw            t4, VAR_RETCODE($fp)         # retcode = 1
#      j             return_codificar
#  continuar_for:
#      lw            t2, VAR_I($fp)               # t2<---i
#      addiu         t2, t2, 1
#      sw            t2, VAR_I($fp)
#      j             for_entrada
#  aplicar_codificacion:
#      lw            t2, VAR_LEN($fp)
#      bgtz          t2, mapear_base64
#      j             while_read_code
#  mapear_base64:                 
#      la            a0, array_in
#      la            a1, array_out
#      lw            a2, VAR_LEN($fp)
#      jal           bloqueToBase64             # VER        
#      sw            zero, VAR_I($fp)          # i = 0
#  for_salida:
#      lw            t2, VAR_I($fp)             # t2<---i
#      li            t4, 4
#      bge           t2, t4, otro_while         # for (int i =0; i< 3; i++)
#      la            a1, array_out
#      addu          t5, t4, t2                 # t5 = out[i]   bloque de salida
#      lw            a0, WRITE_FILENO_OUT($fp)
#      move          a1, t5
#      li            a2, 1
#      li            v0, SYS_write  
#      syscall                                    #write(fileDescriptorSalida, (void*)(&out[i]), 1);
#      addiu         t2, t2, 1
#      j             for_salida
#  otro_while:
#      j             while_read_code
return_codificar:
    lw            v0, VAR_RETCODE(sp)
    move          sp, $fp
    lw            $fp,  WRITE_FP_POS(sp)
    lw            gp, WRITE_GP_POS(sp)
    addu          sp, sp, WRITE_STACK_SIZE
    j             ra
    .end          base64_encode

