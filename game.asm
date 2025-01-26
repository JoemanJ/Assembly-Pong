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
    extern fblock
    
    extern preparar_int9
    extern salvar_modo_grafico
    extern iniciar_modo_grafico_VGA
    extern restaurar_modo_grafico
    extern encerrar_programa

    ; TODO: Terminar interrupção de teclado para sair
    CALL preparar_int9

    CALL salvar_modo_grafico
    CALL iniciar_modo_grafico_VGA

    CALL desenhar_bordas
    CALL desenhar_bola
    CALL desenhar_blocos

    ;TODO: CALL desenhar_raquetes

    main_loop:
    ;TODO: Verificar tecla pressionada...

    CALL proximo_frame
    JMP main_loop

    fim:
    CALL restaurar_modo_grafico
    CALL encerrar_programa
    
    proximo_frame:
        CALL quica_bola
        CALL move_bola
        CALL desenhar_bordas
        CALL desenhar_bola
        RET

    quica_bola:
        CALL quica_bola_parede_cima
        CALL quica_bola_parede_baixo
        RET
        
    quica_bola_parede_cima:
        PUSH AX

        MOV AX, bola_raio
        CMP AX, [bola_posicao_y]
        JAE quica_bola_parede_cima_fim
        NEG WORD [bola_velocidade_y]

        quica_bola_parede_cima_fim:
        POP AX
        RET

    quica_bola_parede_baixo:
        PUSH AX

        MOV AX, 479
        SUB AX, bola_raio
        CMP AX, [bola_posicao_y]
        JBE quica_bola_parede_baixo_fim
        NEG WORD [bola_velocidade_y]

        quica_bola_parede_baixo_fim:
        POP AX
        RET


    move_bola:
        PUSH AX

        MOV AX, [bola_posicao_x]
        ADD AX, [bola_velocidade_x]
        MOV [bola_posicao_x], AX

        MOV AX, [bola_posicao_y]
        ADD AX, [bola_velocidade_y]
        MOV [bola_posicao_y], AX

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
    
    desenhar_blocos:
        PUSH AX

        MOV BYTE [cor], cyan_claro
        MOV AX,[bloco_1_esq_x]
        PUSH AX
        MOV AX,[bloco_1_esq_y]
        PUSH AX
        MOV AX,[bloco_w]
        PUSH AX
        MOV AX,[bloco_h]
        PUSH AX
        CALL fblockx

        MOV BYTE [cor], cyan_claro
        MOV AX,[bloco_2_esq_x]
        PUSH AX
        MOV AX,[bloco_2_esq_y]
        PUSH AX
        MOV AX,[bloco_w]
        PUSH AX
        MOV AX,[bloco_h]
        PUSH AX
        CALL fblock

        MOV BYTE [cor], cyan_claro
        MOV AX,[bloco_3_esq_x]
        PUSH AX
        MOV AX,[bloco_3_esq_y]
        PUSH AX
        MOV AX,[bloco_w]
        PUSH AX
        MOV AX,[bloco_h]
        PUSH AX
        CALL fblock

        MOV BYTE [cor], cyan_claro
        MOV AX,[bloco_4_esq_x]
        PUSH AX
        MOV AX,[bloco_4_esq_y]
        PUSH AX
        MOV AX,[bloco_w]
        PUSH AX
        MOV AX,[bloco_h]
        PUSH AX
        CALL fblock

        MOV BYTE [cor], cyan_claro
        MOV AX,[bloco_5_esq_x]
        PUSH AX
        MOV AX,[bloco_5_esq_y]
        PUSH AX
        MOV AX,[bloco_w]
        PUSH AX
        MOV AX,[bloco_h]
        PUSH AX
        CALL fblock

        POP AX

        RET

    desenhar_bola:
        PUSH AX

        MOV BYTE [cor], vermelho

        MOV AX, [bola_posicao_x]
        PUSH AX
        MOV AX, [bola_posicao_y]
        PUSH AX
        MOV AX, [bola_raio]
        PUSH AX
        CALL fcircle

        POP AX
        
        RET


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
    
    ; variaveis da bola
    bola_raio equ 10
    bola_posicao_x dw 320
    bola_posicao_y dw 240

    bola_velocidade_x dw 0001h
    bola_velocidade_y dw 0001h

    ; variaveis de blocos
    bloco_w         dw  10
    bloco_h         dw  45

    bloco_1_esq_x   dw  20
    bloco_1_esq_y   dw  48

    bloco_2_esq_x   dw  20
    bloco_2_esq_y   dw  144

    bloco_3_esq_x   dw  20
    bloco_3_esq_y   dw  240

    bloco_4_esq_x   dw  20
    bloco_4_esq_y   dw  336

    bloco_5_esq_x   dw  20
    bloco_5_esq_y   dw  432

    bloco_1_dir_x   dw  0
    bloco_1_dir_y   dw  0

    bloco_2_dir_x   dw  0
    bloco_2_dir_y   dw  0

    bloco_3_dir_x   dw  0
    bloco_3_dir_y   dw  0

    bloco_4_dir_x   dw  0
    bloco_4_dir_y   dw  0

    bloco_5_dir_x   dw  0
    bloco_5_dir_y   dw  0


    ; variaveis da raquete esquerda
    raquete_esquerda_posicao_x dw 10
    raquete_esquerda_posicao_y dw 240

    raquete_esquerda_velocidade_y dw 0001h
    
    ; variaveis da raquete direita
    raquete_direita_posicao_x dw 630
    raquete_direita_posicao_y dw 240

    raquete_direita_velocidade_y dw 0001h

    global tecla
    tecla db 0

segment stack stack
    resb 256
    stack_top: