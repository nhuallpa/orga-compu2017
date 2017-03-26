CC=gcc
CFLAGS=-I

default: clean tp0

tp0: main.c
	$(CC) -Wall -O0 -o tp0 main.c -I.

clean: 
	$(RM) tp0
