# Build version
VERSION = 0

# Compiler and env set up
CC=gcc
CFLAGS  = -Wall -O0

# Rules
default: clean bin

bin: 
	$(CC) $(CFLAGS) -o tp1 *.c -D_VERSION_=\"$(VERSION)\"

clean:
	$(RM) tp1
