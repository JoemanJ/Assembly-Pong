segment code
extern plot_xy
;-----------------------------------------------------------------------------
;função bloco
; Parametros:
;	PUSH x; PUSH y; PUSH w; PUSH h; CALL bloco;  (x<639, y<479)
; Obs: w e h devem ser na verdade metade do valor desejado de largura e comprimento

global fblock
fblock:
    PUSH	BP
    MOV		BP,SP
    PUSHf             		;coloca os flags na pilha
    PUSH 	AX
    PUSH 	BX
    PUSH	CX
    PUSH	DX
    
    MOV		AX,[BP+10]   	;resgata os vALores das coordenadas
    MOV		BX,[BP+8]    	;resgata os vALores das coordenadas
    MOV		CX,[BP+6]    	;resgata os vALores das coordenadas
    MOV		DX,[BP+4]    	;resgata os vALores das coordenadas

    MOV     [xcenter],AX
    MOV     [ycenter],BX

    ; Desenhando o bloco usando a funcao de fblock

    ; marcando os pontos x1,y1,x2,y2 a partir do centro e dos valores de w e h
    MOV     AX,[xcenter]
    SUB     AX,CX
    MOV     [x1coord],AX    ;salvando x1 para recuperar mais tarde

    MOV     AX,[ycenter]
    SUB     AX,DX
    MOV     BX,AX           ; BX recebe y1
    
    MOV     AX,[xcenter]
    ADD     AX,CX
    MOV     CX,AX           ; CX recebe x2

    MOV     AX,[ycenter]
    ADD     AX,DX
    MOV     DX,AX           ; DX recebe y2

    MOV     AX,[x1coord]    ; AX recupera valor de x1

lup:
    PUSH AX
    PUSH BX
    CALL plot_xy            ; requisicao para pintar esse pixel

    INC AX                  ; aumenta a posicao de x1 ate chegar em x2
    CMP AX,CX
    JB lup                  ; enquanto x1 nao chegar em x2, nao passa daqui
    MOV AX,[x1coord]        ; quando x1 chegar em x2, reseta o valor de x1 pro valor original
    INC BX                  ; aumenta o valor de y1 ate chegar em y2
    CMP BX,DX               
    JB lup                  ; enquanto y1 nao chegar em y2, nao passa daqui
                            ; quando passar, todos os pixels do quadrado foram pintados

    POP		DX
    POP		CX
    POP		BX
    POP		AX
    POPf
    POP		BP

    RET 8
;*******************************************************************
segment data
    x1coord     dw  0
    xcenter     dw  0
    ycenter     dw  0