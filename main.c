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

#define ERROR_CODIFICANDO  2
#define ERROR_DECODIFICANDO  3

static const char basis_64[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

static char* ENCODE = "encode";
static char* DECODE = "decode";

typedef struct {
       char* accion;
       char* entrada;
       char* salida;
} Parametro;

/*
 *  Codifica bloques de 3 bytes 8-bit como
 *  4 bytes de 6-bit
 *
 **/
static void bloqueToBase64( unsigned char *in, unsigned char *out, int len )
{
    out[0] = (unsigned char) basis_64[ (int)(in[0] >> 2) ];
    out[1] = (unsigned char) basis_64[ (int)(((in[0] & 0x03) << 4) | ((in[1] & 0xf0) >> 4)) ];
    out[2] = (unsigned char) (len > 1 ? basis_64[ (int)(((in[1] & 0x0f) << 2) | ((in[2] & 0xc0) >> 6)) ] : '=');
    out[3] = (unsigned char) (len > 2 ? basis_64[ (int)(in[2] & 0x3f) ] : '=');
}

int codificar(FILE* archEntrada, FILE* archSalida) {
    unsigned char in[3];
    unsigned char out[4];
    int i, len = 0;
    int retcode = 0;

    *in = (unsigned char) 0;
    *out = (unsigned char) 0;
    while( feof( archEntrada ) == 0 ) {
        len = 0;
        for( i = 0; i < 3; i++ ) {
            in[i] = (unsigned char) getc( archEntrada );

            if (ferror(archEntrada)) {
               perror("Error leyendo archivo de entrada");
               retcode = ERROR_CODIFICANDO;
               return retcode;
            }

            if( feof( archEntrada ) == 0 ) {
                len++;
            }
            else {
                in[i] = (unsigned char) 0;
            }
        }
        if( len > 0 ) {
            bloqueToBase64( in, out, len );
            for( i = 0; i < 4; i++ ) {
                if( putc( (int)(out[i]), archSalida ) == EOF ) {
                    if( ferror( archSalida ) != 0 )      {
                           retcode = 1;
                    }  
                    break;
                }
                }
        }
    }
    
    return retcode;  
} 

int decodificar(FILE* entrada, FILE* salida){
    int retcode = 0;
    unsigned int valorEntero1 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
    if (ferror(entrada)) {
       perror("Error leyendo archivo de entrada");
       retcode = ERROR_DECODIFICANDO;
       return retcode;
    }

    unsigned int valorEntero2 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
    if (ferror(entrada)) {
       perror("Error leyendo archivo de entrada");
       retcode = ERROR_DECODIFICANDO;
       return retcode;
    }
    unsigned int valorEntero3 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
    if (ferror(entrada)) {
       perror("Error leyendo archivo de entrada");
       retcode = ERROR_DECODIFICANDO;
       return retcode;
    }
    unsigned int valorEntero4 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
    if (ferror(entrada)) {
       perror("Error leyendo archivo de entrada");
       retcode = ERROR_DECODIFICANDO;
       return retcode;
    }

    
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
       
    return retcode;
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
	
        int isEntradaArchivo = strcmp(p.entrada,"");
	int isSalidaArchivo = strcmp(p.salida,"");
	FILE* archivoEntrada = (isEntradaArchivo!=0)?fopen(p.entrada, "rb"):stdin; //Si la entrada esta vacia lee stdin (teclado)
	FILE* archivoSalida = (isSalidaArchivo!=0)?fopen ( p.salida, "w" ):stdout; //Si la salida esta vacia escribe stdout (pantalla)

	int returnCode = 0;

	if (archivoEntrada == NULL) {
		fprintf(stderr, "ERROR: NO EXISTE LA ENTRADA.\n");
		exit (1);
	}

	if ( strcmp(p.accion, ENCODE) == 0 )
	{
		/* Codificar entrada */
		returnCode = codificar(archivoEntrada, archivoSalida);
				
	} else if ( strcmp(p.accion, DECODE) == 0 ) {
		
                /* Decodificar entrada */
		returnCode = decodificar(archivoEntrada,archivoSalida);
		
	} else {
		fprintf(stderr, "ERROR: SE DEBE INGRESAR UN ARGUMENTO CORRECTO PARA LA OPCION i.\n");
		exit(1);
	}
	
    /* Cierro los archivos de entrada y salida si no son stdin y stdout */
    if(isEntradaArchivo!=0){
		fclose(archivoEntrada);
	}
	if(isSalidaArchivo!=0){
		fclose 	( archivoSalida );
	}
	
	if(returnCode!=0){ 
	 	exit(1);
	} 
	
	return returnCode;
}

