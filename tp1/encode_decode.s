
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
40  |                 |
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
#define VAR_LEN                20
#define VAR_I                16

#define CHAR_READ              32

#define FLUSH_STACK_SIZE       16
#define FLUSH_GP_POS           12
#define FLUSH_FP_POS           8

#define BUFFER_SIZE            5




.text
.align 5
.globl codificar
.ent codificar
codificar:
    .frame        $fp, WRITE_STACK_SIZE, ra  
    .set          noreorder
    .cpload       t9
    .set          reorder
    .cprestore    WRITE_GP_POS
    subu          sp, sp, WRITE_STACK_SIZE      
    sw            ra, WRITE_RA_POS(sp)       #save ra      
    sw            $fp, WRITE_FP_POS(sp)      #save fp
    move          $fp, $sp
while:
    sw            0, VAR_LEN($fp)            # len = 0
    lw            t1, VAR_LEN($fp)           # t1<---len
    sw            0, VAR_I($fp)              # i = 0
    lw            t2, VAR_I($fp)             # t2<---i
for:
    
    bge           t2, 3, escribir_codificacion
    sw            a0, WRITE_FILENO_IN($fp)
    sw            a1, WRITE_FILENO_OUT($fp)
    lw            a0, WRITE_FILENO_IN($fp)
    lw            a1, CHAR_READ($fp)           
    lw            a2, 1
    li            v0, SYS_read                
    syscall                                    #read
    beqz          a3, return                   
    bltz          a3, error_file_in
    addiu         t0, t0, 1                    #len++
    ############# SEGUIR ACA
escribir_codificacion:

return:
error_file_in:



















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