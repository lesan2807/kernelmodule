global calcularPuntos

section .data

rangoX dq 0, 0, 0, 0, 0, 0
rangoY dq 0, 0, 0, 0, 0, 0

pointsX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

pointsY dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  

result dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 

begin dq 0.0
end dq 0.0

operand2 dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
operand1 dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

section .bss

section .text

; "funcion 3d: rango de x y rango de y"


; parametros 
; rango, funcion, incremento, 2d o 3d 
; calcularPuntos(char* informacion, double* puntos, double incremento ,int sizeOfMessage, char* message) 
; info db "a,b,c,d,e,f,a2,b2,c2,d2,e2,f2, tipo, funcion"
; rdi - informacion
; rsi - puntos 
; rdx - incremento 
; rcx - sizeOfMessage
; r8 - message 

 

; numero, operador, sin, cos, ln 

calcularPuntos:
	; pila
	push rbp 
	mov rbp, rsp 

	; callee saved 
	push rbx 
	push r12
	push r13
	push r14
	push r15

	; for sacar los números del rango
	mov rbx, 0 ; i 
	mov r12, rdi 
 
	jmp testForRangoX

forRangoX:
	; incrementa contador 
	xor r13, r13

getNumberX: 
	cmp byte [r12], '0'
    jb saveNumberRangeX
    cmp byte [r12], '9'
    ja saveNumberRangeX
    shl r13,1
    mov r14, r13
    shl r13,2
    add r14, r13
    mov r13, r14
    xor r14, r14
    mov r14b, byte [r12]
    and r14b, 0x0F
    add r13, r14
    inc r12
    jmp getNumberX

saveNumberRangeX:
	inc r12
	mov [rangoX+(rbx*8)], r13
	inc rbx
	jmp testForRangoX

forRangoY: 
	xor r13, r13

getNumberY:
	cmp byte [r12], '0'
    jb saveNumberRangeY
    cmp byte [r12], '9'
    ja saveNumberRangeY
    shl r13,1
    mov r14, r13
    shl r13,2
    add r14, r13
    mov r13, r14
    xor r14, r14
    mov r14b, byte [r12]
    and r14b, 0x0F
    add r13, r14
    inc r12
    jmp getNumberY

saveNumberRangeY:
	inc r12
	mov [rangoY+(rbx*8)], r13
	inc rbx
	jmp testForRangoY


calcular2d:
	xor rbx, rbx 
	xor r13, r13 
	jmp testForRangoXi

forRangoXi:
	mov r13, qword[rangoX+(rbx*8)]
	mov qword[begin], r13 
	mov r13, qword[rangoX+(rbx*8)+8]
	mov qword[end], r13 


	add rbx, 2 
	jmp testForRangoXi

testForRangoX:
	cmp rbx, 6 
	jl forRangoX 

	mov rbx, 0 

testForRangoY:
	cmp rbx, 6 
	jl forRangoY	

	mov rbx, 0 

testIf2dOr3d:
	cmp byte[r12], 50
	je calcular2d 

	cmp byte[r12], 51 
	je calcular3d 

testForRangoXi: 
	cmp rbx, 6 
	jl forRangoXi
	jmp fin

calcular3d:


	
fin:

	pop r15
	pop r14
	pop r13
	pop r12 
	pop rbx

	pop rbp
	ret	
