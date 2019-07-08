
#include <string.h>

int main(int argc, char const *argv[])
{
	/* code */
	char funcion[] = {"[234,235] [4000,4001] [51001,51002]/x*x+1/0.01/2D"};
	extern void calcularPuntos(char*, double, size_t, char*); 
	calcularPuntos("0,1,0,0,0,0,0,0,0,0,0,0,3x*xx*+,0.01,2", 0.01, strlen(funcion), funcion); 
	
	return 0;
}