global verificarErrores 

%macro pushPila 0
	push rbp 
	mov rbp, rsp 

	; callee saved 
	push rbx 
	push r12
	push r13
	push r14
	push r15
%endmacro

%macro popPila 0
	pop r15
	pop r14
	pop r13
	pop r12 
	pop rbx

	pop rbp
	ret	
%endmacro


section .data 

numeros db '0123456789', 0 

section .text 

; int verificarErrores(char* range, char* function, double incremento )

; rdi : range 
; rsi function 
; rdx incremento

verificarErrores: 
	
  	pushPila 

    xor rax, rax ; code of return 
    xor rbx, rbx ; index 

    error1: ; Verifica que no haya más de 2 signos + o - en la funcion

    	xor r12, r12 ; index 
    	xor r13, r13 ; cantidad de + o - 

    	recorreHileraMasMenos: 
    		mov r14b, byte[rsi+r12]
    		inc r12 
    		cmp r14b, '+'
    		je hayUnMasOMenos
    		cmp r14b, '-'
    		je hayUnMasOMenos 
    		cmp r14b, 0 ; llega al final de la cadena ya termina de verificar este error y pasa al siguiente 
    		je error2 
    		jmp recorreHileraMasMenos

    	hayUnMasOMenos: 
    		inc r13 
    		cmp r13, 3 
    		je hayError1
    		jmp recorreHileraMasMenos

		hayError1: 
			mov rax, 1 

    error2: ; Verifica que no haya */ de más en la función
    	xor r12, r12 ; index 
		xor r13, r13 ; cantidad de / y * en la function 

		recorreHileraPorEntre: 
			mov r14b, byte[rsi+r12]
    		inc r12 
    		cmp r14b, '+'
    		je hayUnPorOEntre
    		cmp r14b, '-'
    		je hayUnPorOEntre 
    		cmp r14b, 0 ; llega al final de la cadena ya termina de verificar este error y pasa al siguiente 
    		je error3 
    		jmp recorreHileraPorEntre

    	hayUnPorOEntre: 
    		inc r13 
    		cmp r13, 6 
    		jg hayError2 
    		jmp recorreHileraPorEntre

		hayError2: 
			mov rax, 2 	

    error3: ; Verifica que no haya dos * o / o + o - contiguos

    	xor r12, r12 ; index 
    	xor r13, r13 ; temporalIndex 

    	recorreHileraOperador: 
    	mov r13, r12 
    	mov r14b, byte[rsi+r12] 
    	inc r12 
    	cmp r14b, '*'
    	je isOperator
    	cmp r14b, '/'
    	je isOperator
    	cmp r14b, '+'
    	je isOperator
    	cmp r14b, '-'
    	je isOperator
    	cmp r14b, 0 
    	je error4
    	jmp recorreHileraOperador

    	isOperator: 
    		mov r14b, byte[rsi+r13-1] ; anterior al actual 
    		cmp r14b, '*'
    		je hayError3
    		cmp r14b, '/'
    		je hayError3
    		cmp r14b, '+'
    		je hayError3
    		cmp r14b, '-'
    		je hayError3 

			mov r14b, byte[rsi+r13+1] ; posterior al actual 
    		cmp r14b, '*'
    		je hayError3
    		cmp r14b, '/'
    		je hayError3
    		cmp r14b, '+'
    		je hayError3
    		cmp r14b, '-'
    		je hayError3 

    		jmp recorreHileraOperador

    	hayError3: 
    		mov rax, 3	

    error4: ; Revisa que no haya variables diferentes a 'x' o 'y' 

    	xor r12, r12 
		recorreHileraXoY:
			mov r14b, byte[rsi+r12]
			inc r12
			cmp r14b, 0
			je error6

			cmp r14b, '*'
    		je recorreHileraXoY
    		cmp r14b, '/'
    		je recorreHileraXoY
    		cmp r14b, '+'
    		je recorreHileraXoY
    		cmp r14b, '-'
    		je recorreHileraXoY 

    		checkIfConstante1: 
    			xor r9, r9 ; index = 0

    			recorrerConstantes1: 
    				mov r10b, byte[numeros+r9]
    				inc r9 
    				cmp r14b, r10b 
    				je recorreHileraXoY
    				cmp r10b, 0 
    				je checkIfOperando
    				jmp recorrerConstantes1

    		checkIfOperando: ; check if sin, cos, ln, x or y 
  
    			cmp r14b, 's'
    			add r12, 2 
    			je recorreHileraXoY 
    			cmp r14b, 'c'
    			add r12, 2 
    			je recorreHileraXoY 
    			cmp r14b, 'l'
    			inc r12 
    			je recorreHileraXoY 
    			cmp r14b, '('
    			je recorreHileraXoY
    			cmp r14b, ')'
    			je recorreHileraXoY
    			cmp r14b, 'x'
    			je recorreHileraXoY
    			cmp r14b, 'y'
    			je recorreHileraXoY



		hayError4:
			mov rax, 4


    error5: ; Verifica que no haya constantes de mas de 7 digitos
    	xor r12, r12 ; index 
    	xor r13, r13 ; count = 0, cantidad de digitos

    	recorreHileraConst:
    		mov r14b, byte[rsi+r12]
    		inc r12 
    		cmp r14b, 0
    		je error6

    		checkIfConstante: 
    			xor r9, r9 ; index = 0

    			recorrerConstantes: 
    				mov r10b, byte[numeros+r9]
    				inc r9 
    				cmp r14b, '0'
    				jb verificarError 
    				cmp r14b, '9'
    				ja verificarError
					inc r13 
    				cmp r10b, 0 
    				je verificarError
    				jmp recorrerConstantes

			verificarError:

				cmp r13, 7 
				je hayError5 
				jmp recorreHileraConst

		hayError5:
			mov rax, 5		


    error6: ; Verifica que no haya más de 2 operadores (*/) por término

    	xor r12, r12 ; index 
    	xor r13, r13 ; count 

    	recorreHilera2Op: 
    		mov r14b, byte[rsi+r12]
    		inc r12
    		cmp r14b, '*'
    		je esMulODiv 
    		cmp r14b, '/'
    		je esMulODiv
    		cmp r14b, '+'
    		je esSumoRes
    		cmp r14b, '-'
    		je esSumoRes
    		cmp r14b, 0 
    		je error7 
    		jmp recorreHilera2Op

    	esMulODiv:
    		inc r13 
    		cmp r13, 3
    		je hayError6
    		jmp recorreHilera2Op 

    	esSumoRes: 
    		xor r13, r13 
    		jmp recorreHilera2Op	

		hayError6:
			mov rax, 6	

    error7: ; Verifica que siempre venga al menos un rango para ‘x’
    	xor r12, r12
    	mov r12, 1 
    verificarPrimerRango: 	
    	mov r14b, byte[rdi+r12]
    	cmp r14b, '0'
		jb verificarPrimero 
		cmp r14b, '9'
		ja verificarPrimero 
		inc r12 
		cmp r14b, ']'
		je fin 
		jmp verificarPrimerRango

	verificarPrimero:
		cmp r14b, ' '
		jne hayError7 
		jmp verificarPrimerRango


	hayError7:
		mov rax, 7 	

   
fin: 
    popPila 
	
	

	

	

	

	
