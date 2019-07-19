#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern void calcularPuntos(char*, double*, double); 
extern int verificarErrores(char*, char*, double); 
extern int parser(char*, char*, char*, char*); 


int main(int argc, char const *argv[])
{
	/* code */
	double* points = (double*)calloc(100, sizeof(double)); 

	char loQueRecibi[] = {"[0 1]#[0 1],y*y+x*x,0.1"};
	
	char* info = (char*)calloc(4096, sizeof(char)); 
	char* range = (char*)calloc(2048, sizeof(char)); 
	char* function = (char*)calloc(2048, sizeof(char)); 
	char* incr = (char*)calloc(1024, sizeof(char)); 

	int count = 0; 

	char* pch; 
	pch = strtok(loQueRecibi, ",");
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


	int a = verificarErrores(range, function, strtod(incr, NULL)); 
	int b = -1; 
	if(a == 0)
		b = parser(range, function, incr, info); 

	printf("resultado: %s\nerror: %d\n", info, a);

	// vFunction 
    if(b == 0)
	    calcularPuntos(info, points, 0.1); 
	
	for(int i = 0; i < 30; ++i )
	{
		printf("%.2lf ", points[i]);
	}

	return 0;
}
