segment code
    ;Inicializar registradores de segmento
    MOV AX, data
    MOV DS, AX
    MOV AX, stack
    MOV SS, AX
    MOV SP, stack_top

    ;Imports
    extern plot_xy
    extern fcircle
    extern line

    CALL salvar_modo_grafico
    CALL iniciar_modo_grafico_VGA

    CALL desenhar_bordas
    CALL desenhar_bola
    ;CALL desenhar_raquetes

    lup:
    ;Encerrar programa caso alguma tecla seja pressionada
    ;CALL verifica_tecla_pressionada ; AL=0 se nada pressionado, AL!=0 caso contrario
    
    ;CMP AL, 0
    ;JNE fim

    CALL proximo_frame
    JMP lup

    fim:
    CALL restaurar_modo_grafico
    CALL encerrar_programa
    
    proximo_frame:
        CALL desenhar_bordas
        CALL desenhar_bola
        RET

    salvar_modo_grafico:
        PUSH AX
        MOV AX, 0Fh
        INT 10h
        MOV [modo_grafico_anterior], AL
        POP AX
        RET

    iniciar_modo_grafico_VGA:
        PUSH AX
        MOV AX, 12h
        INT 10h
        POP AX
        RET

    desenhar_bordas:
        PUSH AX

        MOV BYTE [cor], branco_intenso

        ;Linha de baixo
        MOV AX, 0
        PUSH AX
        MOV AX, 479
        PUSH AX
        MOV AX, 639
        PUSH AX
        MOV AX, 479
        PUSH AX

        CALL line

        ;Linha de cima
        MOV AX, 0
        PUSH AX
        MOV AX, 0
        PUSH AX
        MOV AX, 639
        PUSH AX
        MOV AX, 0
        PUSH AX

        CALL line

        POP AX
        RET
    
    desenhar_bola:
        PUSH AX

        MOV BYTE [cor], vermelho

        MOV AX, 320
        PUSH AX
        MOV AX, 240
        PUSH AX
        MOV AX, 10
        PUSH AX
        CALL fcircle

        POP AX
        
        RET
    
    restaurar_modo_grafico:
        PUSH AX
        MOV AH, 0
        MOV AL, [modo_grafico_anterior]
        INT 10h
        POP AX
        RET
    
    encerrar_programa:
        MOV AH, 4Ch
        INT 21h


segment data
    global cor
    cor		db		branco_intenso
                                ; I R G B COR
    preto			equ		0	; 0 0 0 0 preto
    azul			equ		1	; 0 0 0 1 azul
    verde			equ		2	; 0 0 1 0 verde
    cyan			equ		3	; 0 0 1 1 cyan
    vermelho		equ		4	; 0 1 0 0 vermelho
    magenta			equ		5	; 0 1 0 1 magenta
    marrom			equ		6	; 0 1 1 0 marrom
    branco			equ		7	; 0 1 1 1 branco
    cinza			equ		8	; 1 0 0 0 cinza
    azul_claro		equ		9	; 1 0 0 1 azul claro
    verde_claro		equ		10	; 1 0 1 0 verde claro
    cyan_claro		equ		11	; 1 0 1 1 cyan claro
    rosa			equ		12	; 1 1 0 0 rosa
    magenta_claro	equ		13	; 1 1 0 1 magenta claro
    amarelo			equ		14	; 1 1 1 0 amarelo
    branco_intenso	equ		15	; 1 1 1 1 branco INTenso
    
    modo_grafico_anterior db 0
    
    ; variaveis da bola
    bola_raio equ 10
    bola_posicao_x dw 320
    bola_posicao_y dw 240

    bola_velocidade_x dw 0001h
    bola_velocidade_y dw 0001h

    ; variaveis da raquete esquerda
    raquete_esquerda_posicao_x dw 10
    raquete_esquerda_posicao_y dw 240

    raquete_esquerda_velocidade_y dw 0001h
    
    ; variaveis da raquete direita
    raquete_direita_posicao_x dw 630
    raquete_direita_posicao_y dw 240

    raquete_direita_velocidade_y dw 0001h

segment stack stack
    resb 256
    stack_top: