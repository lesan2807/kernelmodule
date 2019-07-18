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

    error2: ; Verifica que haya una variable luego de 'sin', 'cos', 'ln
    	xor r12, r12 ; index 

    	recorreHileraCosSenLn: 
    		mov r14b, byte[rsi+r12]
    		inc r12 
    		cmp r14b, 's'
    		je checkCosSin 
    		cmp r14b, 'c'
    		je checkCosSin 
    		cmp r14b, 'l'
    		je checkLn 
    		cmp r14b, 0 
    		je error3 
    		jmp recorreHileraCosSenLn

    	checkLn: 
    		add r12, 1
    		cmp byte[rsi+r12], 'x'
    		je recorreHileraCosSenLn 
    		cmp byte[rsi+r12], 'y'
    		je recorreHileraCosSenLn 	

		checkCosSin: 
			add r12, 2
    		cmp byte[rsi+r12], 'x'
    		je recorreHileraCosSenLn
    		cmp byte[rsi+r12], 'y'
    		je recorreHileraCosSenLn

		hayError2: 
			mov rax, 2 	

    error3: ; Verifica que no haya */ de más en la función
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
    		je error2 
    		jmp recorreHileraMasMenos

    	hayUnPorOEntre: 
    		inc r13 
    		cmp r13, 6 
    		jg hayError3 
    		jmp recorreHileraPorEntre

		hayError3: 
			mov rax, 3 	

    error4: ; Verifica que no haya dos * o / o + o - contiguos
    	

    error5: 

    error6: 

    error7: 

    error8: 

    error9: 
   
fin: 
    popPila 
	

	

	

	

	

	; Revisa que no haya variables diferentes a 'x' o 'y'

	; Verifica que no haya constantes de mas de 7 digitos

	; Verifica que no haya más de 2 operadores por término

	; verifica los rangos estén bien escritos 

	; verifica que no se pase de la cantidad de doubles máximo	

