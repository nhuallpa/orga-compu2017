Compilar en gxemul:

gcc -Wall -O0 -g -o tp1 *.c *.S -D_VERSION_=\"0\"

Debuguear:

gdb --args tp1 -a encode -i /root/envio/test.txt
