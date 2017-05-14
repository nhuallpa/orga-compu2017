#ifndef _BASE64_H
#define _BASE64_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define ERROR_CODIFICANDO  2
#define ERROR_DECODIFICANDO  3

static const char basis_64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

/*extern const char* errmsg[];*/

extern int base64_encode(int fileDescriptorEntrada, int fileDescriptorSalida);
int decodificar(FILE* entrada, FILE* salida);

#endif


