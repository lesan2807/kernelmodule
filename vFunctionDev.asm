global parser

%macro pushPila 0
	push rbp 
	mov rbp, rsp 

	; callee saved 
	push rbx 
	push r12
	push r13
	push r14
	push r15
	push r10
	push r8
%endmacro

%macro popPila 0
	pop r8
	pop r10
	pop r15
	pop r14
	pop r13
	pop r12 
	pop rbx

	pop rbp
	ret	
%endmacro


; %1 label where to jump if successful
; %2 label where to jump if error
; %3 register pointing to mem that contains the number
; %4 register pointing to mem where we want to move the number
%macro readNumber 4
	
	xor rax, rax  
	push r10
	push r8

	mov r8, 0
	;r8 lo uso como contador, si la longitud es 0 hay un error
	%%read: 
		cmp byte [%3], '0'
		jb %%checkIfError
	    	cmp byte [%3], '9'
	    	ja %%checkIfError

		inc r8
		mov r10b, byte [%3]
		mov byte [%4], r10b

		inc %3
		inc %4
		
		jmp %%read

	%%checkIfError:
		cmp r8, 0
		pop r8
		pop r10
		je %2
		jmp %1

%endmacro

; %1 es donde saltar si todo sale bien
; %2 es la siguiente accion si no es basico
; %3 es el label de error
%macro procesarBasico 3

	%%verificarX:
	cmp byte [rsi], 'x'
	jne %%verificarY
	mov byte [rcx], 'x'
	inc rcx
	mov byte [rcx], ','
	inc rcx
	inc rsi
	jmp %1

	%%verificarY:
	cmp byte [rsi], 'y'
	jne %%verificarNum
	mov byte [rcx], 'y'
	inc rcx
	mov byte [rcx], ','
	inc rcx
	inc rsi
	jmp %1

	%%verificarNum:
	cmp byte [rsi], '0'
	jb %2

	cmp byte [rsi], '9'
	ja %2

	readNumber %%comma, %3, rsi, rcx
	%%comma:
	mov byte [rcx], ','
	inc rcx
	jmp %1

%endmacro

; %1 es adonde saltar si no es sen, cos, ln
; %2 es adonde saltar si todo sale bien
%macro desplazarFuncion 2

	%%sen:
	cmp r15, 's'
	jne %%cos
	mov byte [rcx], 's'
	inc rcx
	mov byte [rcx], 'i'
	inc rcx
	mov byte [rcx], 'n'
	inc rcx
	mov byte [rcx], ','
	inc rcx
	jmp %2

	%%cos:
	cmp r15, 'c'
	jne %%ln
	mov byte [rcx], 'c'
	inc rcx
	mov byte [rcx], 'o'
	inc rcx
	mov byte [rcx], 's'
	inc rcx
	mov byte [rcx], ','
	inc rcx
	jmp %2

	%%ln:
	cmp r15, 'l'
	jne %1
	mov byte [rcx], 'l'
	inc rcx
	mov byte [rcx], 'n'
	inc rcx
	mov byte [rcx], ','
	inc rcx
	jmp %2

%endmacro

%macro procesarMultOp 0

	%%while:
		cmp r12, 0
		je pushOperator

		pop r15
		cmp r15, '+'
		je noDesplaza
		cmp r15, '-'
		je noDesplaza

		%%checkDiv:
		cmp r15, '/'
		jne %%checkProd
		mov byte [rcx], '/'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		dec r12
		jmp %%while

		%%checkProd:
		cmp r15, '*'
		jne %%funciones
		mov byte [rcx], '*'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		dec r12
		jmp %%while

		%%funciones:
		desplazarFuncion errorSintaxis, %%continuar	; no debería saltar nunca a error de aqui

		%%continuar:
		dec r12
		jmp %%while

%endmacro

%macro procesarSumOp 0

	%%while:
		cmp r12, 0
		je pushOperator

		pop r15

		%%checkSum:
		cmp r15, '+'
		jne %%checkResta
		mov byte [rcx], '+'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		dec r12
		jmp %%while

		%%checkResta:
		cmp r15, '-'
		jne %%checkDiv
		mov byte [rcx], '-'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		dec r12
		jmp %%while

		%%checkDiv:
		cmp r15, '/'
		jne %%checkProd
		mov byte [rcx], '/'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		dec r12
		jmp %%while

		%%checkProd:
		cmp r15, '*'
		jne %%funciones
		mov byte [rcx], '*'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		dec r12
		jmp %%while

		%%funciones:
		desplazarFuncion errorSintaxis, %%continuar	; no debería saltar nunca a error de aqui

		%%continuar:
		dec r12
		jmp %%while

%endmacro

section .data
section .text

; parser(char* range, char* function, char* inc, char* info)
; rdi - puntero a string que representa rangos
; rsi - puntero a string que representa funcion
; rdx - incremento
; rcx - puntero a string para retornar el resultado

parser:
	pushPila

	; procesar intervalos
	; ciclo
	intervalosX:
	mov r8, 3
	revisarIntervalosX:
		dec r8
		cmp byte [rdi], '['
		jne errorSintaxis	; la cadena no empieza con '['

		;la cadena si empieza con '['
		
		inc rdi
		;ver cuál es el siguiente número
		readNumber l1, errorSintaxis, rdi, rcx

		l1:
		mov byte [rcx], ','
		inc rcx
		cmp byte [rdi], ' '
		jne errorSintaxis

		inc rdi
		readNumber l2, errorSintaxis, rdi, rcx

		l2:
		mov byte [rcx], ','
		inc rcx
		cmp byte [rdi], ']'
		jne errorSintaxis

		inc rdi
		cmp byte [rdi], '#'
		je finIntervalosX

		cmp byte [rdi], ' '
		jne errorSintaxis

		inc rdi
		jmp revisarIntervalosX
	;fin de ciclo

	finIntervalosX:
	inc rdi

	llenarCeros:
		cmp r8, 0
		je intervalosY
		
		dec r8
		mov byte [rcx], '0'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		mov byte [rcx], '0'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		jmp llenarCeros

	intervalosY:
	mov r8, 3
	revisarIntervalosY:
		cmp byte [rdi], 0
		je llenarCeros2

		dec r8
		
		cmp byte [rdi], '['
		jne errorSintaxis	; la cadena no empieza con '['

		;la cadena si empieza con '['
		
		inc rdi
		;ver cuál es el siguiente número
		readNumber l3, errorSintaxis, rdi, rcx

		l3:
		mov byte [rcx], ','
		inc rcx
		cmp byte [rdi], ' '
		jne errorSintaxis

		inc rdi
		readNumber l4, errorSintaxis, rdi, rcx

		l4:
		mov byte [rcx], ','
		inc rcx
		cmp byte [rdi], ']'
		jne errorSintaxis

		inc rdi
		cmp byte [rdi], 0
		je finIntervalosY

		cmp byte [rdi], ' '
		jne errorSintaxis

		inc rdi
		jmp revisarIntervalosY
	;fin de ciclo

	finIntervalosY:
	inc rdi

	llenarCeros2:
		cmp r8, 0
		je finIntervalos
		
		dec r8
		mov byte [rcx], '0'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		mov byte [rcx], '0'
		inc rcx
		mov byte [rcx], ','
		inc rcx
		jmp llenarCeros2
		
	finIntervalos:



	mov r12, 0	; contamos cuántos elementos hay en la pila de operadores
	mov r13, 0	; para debugging

	;procesar funcion
	;ciclo
	procesarFuncion:
		inc r13

		;ver si el elemento es un numero o variable
		procesarBasico procesarFuncion, verificarSeno, errorSintaxis

		verificarSeno:
		cmp byte [rsi], 's'
		jne verificarCoseno
		inc rsi
		cmp byte [rsi], 'i'
		jne errorSintaxis
		inc rsi
		cmp byte [rsi], 'n'
		jne errorSintaxis
		inc rsi
		cmp byte [rsi], '('
		jne errorSintaxis
		inc rsi

		; OJO: REVISAR ESTO (¿PUEDO MOVER SOLO UN BYTE A UNA COSA DE 64 BITS?)
		mov r15, 's'
		push r15 		; 's' indica operador seno
		inc r12

		procesarBasico verificarParentesis1, errorSintaxis, errorSintaxis

		verificarParentesis1:
		cmp byte [rsi], ')'
		jne errorSintaxis
		inc rsi
		jmp procesarFuncion


		verificarCoseno:
		cmp byte [rsi], 'c'
		jne verificarLn
		inc rsi
		cmp byte [rsi], 'o'
		jne errorSintaxis
		inc rsi
		cmp byte [rsi], 's'
		jne errorSintaxis
		inc rsi
		cmp byte [rsi], '('
		jne errorSintaxis
		inc rsi

		mov r15, 'c'
		push r15 		; 'c' indica operador coseno
		inc r12

		procesarBasico verificarParentesis2, errorSintaxis, errorSintaxis

		verificarParentesis2:
		cmp byte [rsi], ')'
		jne errorSintaxis
		inc rsi
		jmp procesarFuncion


		verificarLn:
		cmp byte [rsi], 'l'
		jne verificarOperador
		inc rsi
		cmp byte [rsi], 'n'
		jne errorSintaxis
		inc rsi
		cmp byte [rsi], '('
		jne errorSintaxis
		inc rsi

		mov r15, 'l'
		push r15 		; 'l' indica operador ln
		inc r12

		procesarBasico verificarParentesis3, errorSintaxis, errorSintaxis

		verificarParentesis3:
		cmp byte [rsi], ')'
		jne errorSintaxis
		inc rsi
		jmp procesarFuncion



		verificarOperador:
		verificarProducto:
		cmp byte [rsi], '*'
		jne verificarDivision

		procesarMultOp ;si se sale de este ciclo sale directo a movOperador o noDesplaza

		verificarDivision:
		cmp byte [rsi], '/'
		jne verificarSuma

		procesarMultOp

		verificarSuma:
		cmp byte [rsi], '+'
		jne verificarResta

		procesarSumOp

		verificarResta:
		cmp byte [rsi], '-'
		jne verificarFinDeLinea

		procesarSumOp



		noDesplaza:
		push r15

		pushOperator:
		mov r15, 0
		mov r15b, byte [rsi]
		push r15 
		inc r12


		inc rsi
		jmp procesarFuncion


		

		verificarFinDeLinea:
		cmp byte [rsi], 0
		jne errorSintaxis



		cicloFinal:
			cmp r12, 0
			je finDeParsing

			pop r15
			desplazarFuncion opComun, finalDeCicloFinal

			opComun:
			mov byte [rcx], r15b
			inc rcx
			mov byte [rcx], ','
			inc rcx

			finalDeCicloFinal:
			dec r12
			jmp cicloFinal

	; fin de procesarFuncion

	errorSintaxis:

	;desalojo de pila
	desalojo:
		cmp r12, 0
		je errorM

		pop r15
		dec r12
		jmp desalojo

	errorM:
	mov rax, 10

	finDeParsing:

	mov byte [rcx], 0
	
	popPila
