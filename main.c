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
#include <getopt.h>

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

void manejarArgumentosEntrada(int argc, char** argv)
{
	int siguiente_opcion;

    /* Una cadena que lista las opciones cortas validas */
    const char* const op_cortas = "hvioa";

    /* Una estructura de varios arrays describiendo los valores largos */
    const struct option op_largas[] =
	{
      	{ "help",    	no_argument,  		NULL,  'h'},
      	{ "version",    no_argument,  		NULL,  'V'},
		{ "input",     	required_argument,  NULL,  'i'},
		{ "output",    	required_argument,  NULL,  'o'},
		{ "action",    	optional_argument,  NULL,  'a'},
      	{ NULL,      	0,  NULL,   0 }
    };


    while (1) {
        siguiente_opcion = getopt_long (argc, argv, op_cortas, op_largas, NULL);
        if (siguiente_opcion == -1) break;
        switch (siguiente_opcion) {     
            case 'h' :
            
                printf("Usage:\n");
                printf("\ttp0 -h\n");
                printf("\ttp0 -V\n");
                printf("\ttp0 [ options ]\n");
                
                printf("Options:\n");
                printf("\t-V, --version       Print version and quit.\n");
                printf("\t-h, --help          Print this information.\n");
                printf("\t-i, --input         Location of the input file.\n");
                printf("\t-o, --output        Location of the output file.\n");
                printf("\t-a, --action        Program action: encode (default) or decode.\n");
                
                printf("Examples:\n");
                printf("\ttp0 -a encode -i ~/input -o ~/output\n");
                printf("\ttp0 -a encode\n");
                exit(0);
	            break;

            case 'v' :
                printf("Tp0:Version_0.1:Grupo: Nestor Huallpa, Ariel Martinez, Pablo Sivori \n");
                exit(0);
            	break;
            	
            case 'i' :
                printf("Option i\n");
                // TODO tomar el parametro de la opcion.                
              	//if (0 != optarg)
               		//printf(" con argumento %s", optarg);
                exit(0);
            	break;
            	
            case 'o' :
                printf("Option o\n");
                // TODO tomar el parametro de la opcion.
                exit(0);
            	break;
            case 'a' :
                printf("Option a\n");
                // TODO tomar el parametro si lo tiene o no de la opcion.
                exit(0);
            	break;          	
        }
    }

}

int main(int argc, char** argv) {

	manejarArgumentosEntrada(argc, argv);  


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
  
  //TODO se queda loopeando ...
  codificar(codificado, data, n);
  printf("%s%s%s","Valor codificado: ",codificado,"\n");
  unsigned char* decodificado = decodificar(codificado);
  printf("%s%s","Valor decodificado: ",decodificado);
  free(codificado);
  free(decodificado);
  
  return 0;
}

