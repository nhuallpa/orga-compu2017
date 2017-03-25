/**
*   6620 - Organizacion del computador 
*   Trabajo Practico 0 
*   Alumnos: 
*           88614 - Nestor Huallpa
*           88573 - Ariel Martinez
*           84026 - Pablo Sivori
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

unsigned char* decodificar(const char *msg_b64){

    int length_msg_b64 = strlen(msg_b64); 
    int size_bytes_sin_padding = (length_msg_b64 * 3) / 4;
    char* ptr_idx = strstr(msg_b64,"=");
    int idx_symbol_equal = (ptr_idx)?ptr_idx-msg_b64:0;
    int count_equals = (idx_symbol_equal!=0)?length_msg_b64 - idx_symbol_equal:0;
    int size_decode_msg = size_bytes_sin_padding - count_equals;

    unsigned char* decode_msg = malloc(size_decode_msg*sizeof(char));
    int* idx = malloc(4*sizeof(int));    
    int idx_decode_msg = 0;
    int i=0;

    for(;i<length_msg_b64;i=i+4){
               
        idx[0] = strchr(basis_64,msg_b64[i]) - basis_64;
	idx[1] = strchr(basis_64,msg_b64[i+1]) - basis_64;
	idx[2] = strchr(basis_64,msg_b64[i+2]) - basis_64;
        idx[3] = strchr(basis_64,msg_b64[i+3]) - basis_64;

        decode_msg[idx_decode_msg++] = (unsigned char)((idx[0] << 2) | (idx[1] >> 4)); 
	//printf("Valor %i%s%i%s",i,": ",idx[i],"\n");
        //printf("Valor %i%s%i%s",i+1,": ",idx[i+1],"\n");
	if(idx[2]<64){
                //printf("Valor %i%s%i%s",i+2,": ",idx[i+2],"\n");
                decode_msg[idx_decode_msg++] = (unsigned char) ((idx[1] << 4) | (idx[2] >> 2));
                if (idx[3] < 64)  {
                    //printf("Valor %i%s%i%s",i+3,": ",idx[i+3],"\n");
                    decode_msg[idx_decode_msg++] = (unsigned char) ((idx[2] << 6) | idx[3]);
                }
	}
	
    }
    
    free(idx);	
    return decode_msg;
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
  printf("%s%s%s","Valor codificado: ",codificado,"\n");
  unsigned char* decodificado = decodificar(codificado);
  printf("%s%s","Valor decodificado: ",decodificado);
  free(codificado);
  free(decodificado);
  return 0;
}

