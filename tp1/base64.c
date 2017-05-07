#include "base64.h"


/*
 *  Codifica bloques de 3 bytes 8-bit como
 *  4 bytes de 6-bit
 *
 **/
void bloqueToBase64( unsigned char *in, unsigned char *out, int len )
{
    out[0] = (unsigned char) basis_64[ (int)(in[0] >> 2) ];
    out[1] = (unsigned char) basis_64[ (int)(((in[0] & 0x03) << 4) | ((in[1] & 0xf0) >> 4)) ];
    out[2] = (unsigned char) (len > 1 ? basis_64[ (int)(((in[1] & 0x0f) << 2) | ((in[2] & 0xc0) >> 6)) ] : '=');
    out[3] = (unsigned char) (len > 2 ? basis_64[ (int)(in[2] & 0x3f) ] : '=');
}

int codificar(int fileDescriptorEntrada, int fileDescriptorSalida) {
    unsigned char in[3];
    unsigned char out[4];
    int i, len = 0;
    int retcode = 0;
    
    char char_read;
    void *byte_read = &char_read;
    ssize_t read_code = 1;
    while( read_code == 1 ) {
        len = 0;
        for( i = 0; i < 3; i++ ) {
            read_code = read(fileDescriptorEntrada, byte_read, 1);
            if (read_code == 0) {
              out[i] = (unsigned char) 0;
            } else if (read_code == 1) {
              in[i] = *((unsigned char*)byte_read);
              len++; 
            } else {
              retcode = ERROR_CODIFICANDO;
              return retcode;
            }
        }
        if( len > 0 ) {
            bloqueToBase64( in, out, len );
            for( i = 0; i < 4; i++ ) {
              retcode = write(fileDescriptorSalida, (void*)(&out[i]), 1);
                if( retcode != 1 ) {
                    retcode = ERROR_CODIFICANDO;
                    return retcode;
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
        if (ferror(entrada)) {
           perror("Error leyendo archivo de entrada");
           retcode = ERROR_DECODIFICANDO;
           return retcode;
        }
		valorEntero2 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
        if (ferror(entrada)) {
           perror("Error leyendo archivo de entrada");
           retcode = ERROR_DECODIFICANDO;
           return retcode;
        }
		valorEntero3 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
        if (ferror(entrada)) {
           perror("Error leyendo archivo de entrada");
           retcode = ERROR_DECODIFICANDO;
           return retcode;
        }
        valorEntero4 = (unsigned int) (strchr(basis_64,fgetc(entrada)) - basis_64);
        if (ferror(entrada)) {
           perror("Error leyendo archivo de entrada");
           retcode = ERROR_DECODIFICANDO;
           return retcode;
        }
    }       
    return retcode;
}

