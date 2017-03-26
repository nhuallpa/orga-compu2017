CC=gcc
CFLAGS=-I

tp0: main.c
	$(CC) -Wall -O0 -o tp0 main.c -I.
