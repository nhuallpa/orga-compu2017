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
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

static char* ENCODE = "encode";
static char* DECODE = "decode";

typedef struct {
       char* accion;
       char* entrada;
       char* salida;
} Parametro;

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

int decodificar(FILE* entrada, FILE* salida){
  
    unsigned int valorEntero1 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
    unsigned int valorEntero2 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
    unsigned int valorEntero3 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
    unsigned int valorEntero4 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);

    //printf("%i",valorEntero1); 
    //printf("%i",valorEntero2); 
    //printf("%i",valorEntero3); 
    //printf("%i",valorEntero4); 
    
    while(!feof(entrada)&& 
	 (valorEntero1>=0 && valorEntero1<=63) && (valorEntero2>=0 && valorEntero2<=64) &&
         (valorEntero3>=0 && valorEntero3<=64) && (valorEntero4>=0 && valorEntero4<=64)) {
		        

        		unsigned char valor1= (unsigned char)((valorEntero1 << 2) | (valorEntero2 >> 4)); 
			fputc(valor1, salida);
			if(valorEntero3<64){
        		  	unsigned char valor2= (unsigned char) ((valorEntero2 << 4) | (valorEntero3 >> 2));
				fputc(valor2, salida);
        		        if (valorEntero4 < 64)  {
        		            unsigned char valor3 = (unsigned char) ((valorEntero3 << 6) | valorEntero4);
				    fputc(valor3, salida);
        		        }
			}
			valorEntero1 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
		        valorEntero2 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
			valorEntero3 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
        		valorEntero4 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);

    }
    
    return 0;
}

Parametro manejarArgumentosEntrada(int argc, char** argv)
{
	int siguiente_opcion;
	int option_index;

    /* Una cadena que lista las opciones cortas validas */
    const char* const op_cortas = "hva:i:o:"; /* "hva::i:o:" */

    /* Una estructura de varios arrays describiendo los valores largos */
    const struct option op_largas[] =
	{
      	{ "help",    	no_argument,  		0,  'h'},
      	{ "version",    no_argument,  		0,  'V'},
		{ "action",    	required_argument,  0,  'a'}, /*optional_argument*/
		{ "input",     	required_argument,  0,  'i'},
		{ "output",    	required_argument,  0,  'o'},
      	{ 0, 0, 0, 0 }
    };


	Parametro parametro;
	parametro.accion 	= ENCODE;
	parametro.entrada 	= "";
	parametro.salida 	= ""; 

    while (1)
    {
        siguiente_opcion = getopt_long (argc, argv, op_cortas, op_largas, &option_index);
        
        if (siguiente_opcion == -1) 
        	break;
        
        switch (siguiente_opcion)
        {
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
            	
            case 'a' :
                if ( optarg )
               		parametro.accion = optarg;
            	break;
            	
            case 'i' :
                if ( optarg )
					parametro.entrada = optarg;
            	break;
            	
            case 'o' :
                if ( optarg )
					parametro.salida = optarg;
            	break;
        }
    }
    
    return parametro;

}

int main(int argc, char** argv) {

	Parametro p = manejarArgumentosEntrada(argc, argv);
	
	size_t tamanio_buffer = 1000;
	size_t n = 0;
	char* data = (char*)malloc(tamanio_buffer);
	char* codificado = (char*)malloc(1500);
	
	/* Leer de entrada */
	int isEntradaArchivo = strcmp(p.entrada,"");
	FILE* archivoEntrada = (isEntradaArchivo!=0)?fopen(p.entrada, "rb"):stdin; //Si la entrada esta vacia lee stdin (teclado)

	if (archivoEntrada == NULL) {
		fprintf(stderr, "ERROR: NO EXISTE LA ENTRADA.\n");
		exit (1);
	}

	//int c;
	/*while ((c = fgetc(archivoEntrada)) != EOF) 
	{
		if (c != '\n') {
		  data[n++] = (char) c;
		}
	}*/

	if ( strcmp(p.accion, ENCODE) == 0 )
	{
		printf("Inicia la Codificacion.\n");
		
		/* Codificar entrada */
		codificar(codificado, data, n);
		
		/* Escribir en salida */
		int isSalidaArchivo = strcmp(p.salida,"");
		FILE* archivoSalida = (isSalidaArchivo!=0)?fopen ( p.salida, "w" ):stdout;
		//fprintf(archivoSalida, codificado);
		
		if(isSalidaArchivo!=0){
			fclose 	( archivoSalida );
		}
		
		free	( data );
		free	( codificado );
		
	} else if ( strcmp(p.accion, DECODE) == 0 ) {
		
		printf("Inicia la Decodificacion.\n");
		int isSalidaArchivo = strcmp(p.salida,"");
                FILE* archivoSalida = (isSalidaArchivo!=0)?fopen ( p.salida, "w" ):stdout;
		/* Decodificar entrada */
		decodificar(archivoEntrada,archivoSalida);
		
		/* Escribir en salida */
			
		if(isSalidaArchivo!=0){
			fclose 	( archivoSalida );
		}
		free	( data );
	
		
	} else {
		
		fprintf(stderr, "ERROR: SE DEBE INGRESAR UN ARGUMENTO CORRECTO PARA LA OPCION i.\n");
		free	( data );
		free	( codificado );
		exit(1);
	}
	if(isEntradaArchivo!=0){
		fclose(archivoEntrada);
	}
	
  
  return 0;
}

