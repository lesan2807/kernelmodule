global calcularPuntos

section .data



charToken: db "     " , 0 

rangoX dq 0, 0, 0, 0, 0, 0
rangoY dq 0, 0, 0, 0, 0, 0

pointsX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

pointsY dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  

result dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 

begin dq 0.0
end dq 0.0

operand2 dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
operand1 dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

sinX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
cosX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
lnX dq 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0


section .bss

section .text

; "funcion 3d: rango de x y rango de y"


; parametros 
; rango, funcion, incremento, 2d o 3d 
; calcularPuntos(char* informacion, double* puntos, double incremento ,int sizeOfMessage, char* message) 
; info db "a,b,c,d,e,f,a2,b2,c2,d2,e2,f2, tipo, funcion"
; rdi - informacion
; rsi - puntos 
; xmm0 - incremento 
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

calcular3d:

calcular2d:
	inc r12 
	xor rbx, rbx 
	xor r13, r13 
	xorpd xmm1, xmm1
	xorpd xmm2, xmm2
	jmp testForRangoXi

forRangoXi:
	mov r13, qword[rangoX+(rbx*8)]
	mov qword[begin], r13 
	mov r13, qword[rangoX+(rbx*8)+8]
	mov qword[end], r13 

	cvtsi2sd xmm1, [begin]
	cvtsi2sd xmm2, [end]

	jmp conditionWhileBeginEndX 

whileBeginEndX: 
	xor r13, r13 
	jmp testForFill8X 

forFill8X:
	ucomisd xmm1, xmm2 	
	jae putCero 

	movsd qword[pointsX+(r13*8)], xmm1 
	addsd xmm1, xmm0 
	jmp  finForFill8X

putCero:
	xorpd xmm3, xmm3
	movsd qword[pointsX+(r13*8)], xmm3

finForFill8X:
	inc r13
	jmp testForFill8X

conditionWhileBeginEndX:
	ucomisd xmm1, xmm2 
	jb whileBeginEndX

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

testForFill8X:
	cmp r13, 8 
	jl forFill8X 

shuntingYardX: 
	xor r15, r15 ; contador del token 
	xor r14, r14 
	; for each token 
checkIfTokenX: 
	inc r12 
	cmp byte[r12], 44
	je checkWhatToDo
	mov r14b, byte[r12] 
	mov [charToken+r15], r14b
	inc r15
	jmp checkIfTokenX

itIsAnX:
	mov r15, 7 
forPushOperator:	
	cmp r15, -1 
	je endOfShuntingYard 
	push qword[pointsX+r15*8]
	dec r15	
	jmp forPushOperator

itIsSinX: 
	mov r15, 7
forCalculateSinX:
	cmp r15, -1 
	je endOfShuntingYard 
	fld qword[pointsX+r15*8]
	fsin 	
	fstp qword[sinX+r15*8]
	push qword[sinX+r15*8]
	dec r15 
	jmp forCalculateSinX

itIsCosX: 
	mov r15, 7
forCalculateCosX:
	cmp r15, -1 
	je endOfShuntingYard 
	fld qword[pointsX+r15*8]
	fcos 	
	fstp qword[cosX+r15*8]
	push qword[cosX+r15*8]
	dec r15 
	jmp forCalculateCosX

itIsLnX: 
	mov r15, 7
forCalculateLnX:
	cmp r15, -1 
	je endOfShuntingYard 
	
	fld1
	fldl2e  
	fdivp st1, st0 ; 1/log2(e) 
	
	fld qword[pointsX+r15*8]
	fyl2x
	
	fstp qword[ln+r15*8]
	push qword[ln+r15*8]
	dec r15 
	jmp forCalculatelnX

itIsSum:
	

	jmp checkWhatToDo

itIsResta: 
	jmp checkWhatToDo

itIsMul: 
	jmp checkWhatToDo

itIsDiv: 
	jmp checkWhatToDo

broadcastNum: 
	jmp checkWhatToDo

checkWhatToDo:
	; switch gigante de si es operador o si es operando

	cmp byte[charToken], 'x'
	je itIsAnX

	cmp byte[charToken], 's'
	je itIsSinX

	cmp byte[charToken], 'c'
	je itIsCosX

	cmp byte[charToken], 'l'
	je itIsLnX

	cmp byte[charToken], '+'
	je itIsSum
	
	cmp byte[charToken], '-'
	je itIsResta

	cmp byte[charToken], '*'
	je itIsMul 

	cmp byte[charToken], '/'
	je itIsDiv 

	;else it is a number 
	getNumber: 
	

endOfShuntingYard:
	cmp r12, 0 
	jne shuntingYardX


	; pop a result el resultado esto es un for 
	; append a los puntos para que estos se los devuelva a VFunctionDev
	jmp conditionWhileBeginEndX
	
fin:

	pop r15
	pop r14
	pop r13
	pop r12 
	pop rbx

	pop rbp
	ret	
