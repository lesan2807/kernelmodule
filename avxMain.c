#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char const *argv[])
{
	/* code */
	double* points = (double*)calloc(100, sizeof(double)); 
	char funcion[] = {"[0,1] [2,3] [4,5],x*x+x/300-22,0.1"};
	extern void calcularPuntos(char*, double*, double, size_t, char*); 
	calcularPuntos("0,1,2,3,4,5,0,0,0,0,0,0,x,x,*,x,300,/,+,25,-,", points, 0.100000000000000000000000000000000000000, strlen(funcion), funcion); 
	
	return 0;
}