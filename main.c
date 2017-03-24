/**
*   6620 - Organizacion del computador 
*   Trabajo Practico 0 
*   Alumnos: 
*           88614 - Nestor Huallpa
*           88573 - Ariel Martinez
*           xxxxx - Pablo Sivori
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static const char basis_64[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

int codificar(char *codificado, const char *data, int tamanio) {
  int i;
  char *p;

  p = codificado;
  for (i = 0; i < tamanio - 2; i += 3) {
    *p++ = basis_64[(data[i] >> 2) & 0x3F];
    *p++ = basis_64[((data[i] & 0x3) << 4) |
                    ((int) (data[i + 1] & 0xF0) >> 4)];
    *p++ = basis_64[((data[i + 1] & 0xF) << 2) |
                    ((int) (data[i + 2] & 0xC0) >> 6)];
    *p++ = basis_64[data[i + 2] & 0x3F];
  }
  if (i < tamanio) {
    *p++ = basis_64[(data[i] >> 2) & 0x3F];
    if (i == (tamanio - 1)) {
        *p++ = basis_64[((data[i] & 0x3) << 4)];
        *p++ = '=';
    }
    else {
        *p++ = basis_64[((data[i] & 0x3) << 4) |
                        ((int) (data[i + 1] & 0xF0) >> 4)];
        *p++ = basis_64[((data[i + 1] & 0xF) << 2)];
    }
    *p++ = '=';
  }

    *p++ = '\0';
    return p - codificado;
}

int main(int argc, char** argv) {

  

  size_t tamanio_buffer = 1000;
  size_t n = 0;
  int c;
  char* data = (char*)malloc(tamanio_buffer);
  char* codificado = (char*)malloc(1500);
  
  fgets(data, tamanio_buffer, stdin);
  n = strlen(data);
  /*FILE *archivoEntrada = fopen("test.txt", "rb");

  while ((c = fgetc(archivoEntrada)) != EOF) 
  {
    if (c != '\n') {
      data[n++] = (char) c;
    }
  }
  */
  
  codificar(codificado, data, n);

  codificado[n]='\0';
  printf("%s", codificado);
 
  return 0;
}

