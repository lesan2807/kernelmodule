/* scanf example */
#include <iostream>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

///#include "gnuplot-iostream.h"

void Errores(int numero) {
    switch (numero) {
        case 1:
            printf("Error: \n");
            break;
        case 2:
            printf("Error: \n");
            break;
        case 3:
            printf("Error: \n");
            break;
        case 4:
            printf("Error: \n");
            break;
        case 5:
            printf("Error: \n");
            break;
        case 6:
            printf("Error: \n");
            break;
        case 7:
            printf("Error: \n");
            break;
        case 8:
            printf("Error: \n");
            break;
        case 9:
            printf("Error: \n");
            break; 
        default:
            break;
    }
}
int main ()
{
    char str [80];
    char* puntos;
  int device = open("/dev/vFunctionDev", O_RDWR|O_EXCL);
    int wrt;
    int rd;  
    if(device >= 0) {//Se conecta
        
        printf ("Ingrese los puntos x,y, funcion e incremento \nFormato: x,y,f(x),incremento \n");
        scanf ("%79s",str);
        wrt = write(device, str, strlen(str));
        if(wrt<0) {
                Errores(wrt);
            } else{
            rd = read(device, puntos , sizeof(float));
            }
        
        
    } else{//No se conecta
        printf("El modulo no esta conectado");
    }
    
    
    
  
    
  printf ("%s\n",str);
  //printf ("The sentence entered is %u characters long.\n",(unsigned)strlen(str));
  
  
  return 0;
}

