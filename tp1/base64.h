#ifndef _BASE64_H
#define _BASE64_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "comparador.h"

#define ERROR_CODIFICANDO  2
#define ERROR_DECODIFICANDO  3

extern const char* errmsg[];

extern int base64_encode(int fileDescriptorEntrada, int fileDescriptorSalida);
extern int decodificar(int infd, int outfd);

#endif


