#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char const *argv[])
{
	/* code */
	double* points = (double*)calloc(100, sizeof(double)); 

	char funcion[] = {"[0 1] [2 3] [4 5],x*x+x/300-25,0.1"};
	
	char* info = (char*)calloc(2048, sizeof(char)); 

	char* range = (char*)calloc(2048, sizeof(char)); 

	char* function = (char*)calloc(2048, sizeof(char)); 

	char* incr = (char*)calloc(1024, sizeof(char)); 

	int count = 0; 

	char* pch; 
	pch = strtok(funcion, ",");
	while( pch != NULL )
	{
		if (count == 0)
			range = pch; 
		else if (count == 1)
			function = pch; 
		else if( count == 2)
			incr = pch; 
		++count;
		pch = strtok (NULL, ",");

	}	

	printf("%s %s %s\n", range, function, incr);

	extern void calcularPuntos(char*, double*, double, size_t, char*); 
	calcularPuntos("0,1,2,3,4,5,0,0,0,0,0,0,x,x,*,x,300,/,+,25,-,", points, 0.100000000000000000000000000000000000000, strlen(funcion), funcion); 
	
	for(int i = 0; i < 30; ++i )
	{
		printf("%.2lf ", points[i]);
	}

	return 0;
}