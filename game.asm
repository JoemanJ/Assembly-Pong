segment code
    ;Inicializar registradores de segmento
    MOV AX, data
    MOV DS, AX  
    MOV AX, stack
    MOV SS, AX
    MOV SP, stack_top

    ;Imports
    extern cursor
    extern caracter
    extern plot_xy
    extern fcircle
    extern line
    extern fblock
    
    extern preparar_int9
    extern salvar_modo_grafico
    extern iniciar_modo_grafico_VGA
    extern restaurar_modo_grafico
    extern encerrar_programa
    extern sair

    CALL preparar_int9

    CALL salvar_modo_grafico
    CALL iniciar_modo_grafico_VGA

    MOV BYTE [tecla], 0 ;Porque ao abrir o programa enter e solto...

    CALL desenhar_bordas
    CALL desenhar_blocos

    loop_menu:
        CALL escreve_dificuldade_facil
        CALL escreve_dificuldade_medio
        CALL escreve_dificuldade_dificil
        
        MOV AL, [tecla]
        MOV BYTE [tecla], 0
        
        CMP AL, BAIXO_SOLTO
        JE aumenta_dificuldade

        CMP AL, CIMA_SOLTO
        JE diminui_dificuldade

        CMP AL, ENTER_APERTADO
        JE comeca_jogo

        JMP loop_menu

        aumenta_dificuldade:
        INC BYTE [dificuldade_selecionada]
        CMP BYTE [dificuldade_selecionada], 3
        JNE _aumenta_dificuldade_fim
        MOV BYTE [dificuldade_selecionada], 0
        _aumenta_dificuldade_fim:
        JMP loop_menu

        diminui_dificuldade:
        DEC BYTE [dificuldade_selecionada]
        CMP BYTE [dificuldade_selecionada], -1
        JNE _diminui_dificuldade_fim
        MOV BYTE [dificuldade_selecionada], 2
        _diminui_dificuldade_fim:
        JMP loop_menu

    comeca_jogo:

    CALL limpa_dificuldades
    CALL define_velocidade_bola

    CALL desenhar_bola

    main_loop:
    CALL verifica_sair
    CALL atualiza_status_controles
    CALL executa_controles

    CALL proximo_frame
    JMP main_loop

    fim:
    CALL restaurar_modo_grafico
    CALL encerrar_programa

    escreve_dificuldade_facil:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV DH, 18
        MOV DL, 37

        CMP BYTE [dificuldade_selecionada], 0
        JNE _escreve_dificuldade_facil_1
        MOV BYTE [cor], verde
        JMP _escreve_dificuldade_facil_2
        _escreve_dificuldade_facil_1:
        MOV BYTE [cor], branco_intenso

        _escreve_dificuldade_facil_2:
        MOV CX, 5
        MOV BX, facil

        _escreve_dificuldade_facil_loop:
        MOV AL, [BX]
        CALL cursor
        CALL caracter
        INC BX
        INC DL
        LOOP _escreve_dificuldade_facil_loop

        POP DX
        POP CX
        POP BX
        POP AX

        RET

    escreve_dificuldade_medio:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV DH, 20
        MOV DL, 37

        CMP BYTE [dificuldade_selecionada], 1
        JNE _escreve_dificuldade_medio_1
        MOV BYTE [cor], amarelo
        JMP _escreve_dificuldade_medio_2
        _escreve_dificuldade_medio_1:
        MOV BYTE [cor], branco_intenso

        _escreve_dificuldade_medio_2:
        MOV CX, 5
        MOV BX, medio

        _escreve_dificuldade_medio_loop:
        MOV AL, [BX]
        CALL cursor
        CALL caracter
        INC BX
        INC DL
        LOOP _escreve_dificuldade_medio_loop

        POP DX
        POP CX
        POP BX
        POP AX

        RET

    escreve_dificuldade_dificil:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV DH, 22
        MOV DL, 37

        CMP BYTE [dificuldade_selecionada], 2
        JNE _escreve_dificuldade_dificil_1
        MOV BYTE [cor], vermelho
        JMP _escreve_dificuldade_dificil_2
        _escreve_dificuldade_dificil_1:
        MOV BYTE [cor], branco_intenso

        _escreve_dificuldade_dificil_2:
        MOV CX, 7
        MOV BX, dificil

        _escreve_dificuldade_dificil_loop:
        MOV AL, [BX]
        CALL cursor
        CALL caracter
        INC BX
        INC DL
        LOOP _escreve_dificuldade_dificil_loop

        POP DX
        POP CX
        POP BX
        POP AX

        RET

    limpa_dificuldades:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV BYTE [cor], preto

        MOV DH, 18
        MOV DL, 37


        MOV CX, 5
        MOV BX, facil

        _limpa_dificuldades_loop_1:
        MOV AL, [BX]
        CALL cursor
        CALL caracter
        INC BX
        INC DL
        LOOP _limpa_dificuldades_loop_1


        MOV DH, 20
        MOV DL, 37

        MOV CX, 5
        MOV BX, medio

        _limpa_dificuldades_loop_2:
        MOV AL, [BX]
        CALL cursor
        CALL caracter
        INC BX
        INC DL
        LOOP _limpa_dificuldades_loop_2

        MOV DH, 22
        MOV DL, 37

        MOV CX, 7
        MOV BX, dificil

        _limpa_dificuldades_loop_3:
        MOV AL, [BX]
        CALL cursor
        CALL caracter
        INC BX
        INC DL
        LOOP _limpa_dificuldades_loop_3


        POP DX
        POP CX
        POP BX
        POP AX

        RET

    define_velocidade_bola:
        PUSH AX

        MOV AX, [bola_velocidade_x]
        MUL BYTE [dificuldade_selecionada]
        MOV [bola_velocidade_x], AX

        MOV AX, [bola_velocidade_y]
        MUL BYTE [dificuldade_selecionada]
        MOV [bola_velocidade_y], AX

        POP AX
        RET

    verifica_sair:
        PUSH AX

        MOV AL, [tecla]
        CMP AL, Q_SOLTO
        JNE _verifica_sair_1
        CALL loop_sair

        _verifica_sair_1:
        POP AX
        RET

    loop_sair:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        _loop_sair_1:

        MOV BYTE [cor], vermelho
        MOV BX, mensagem_sair
        MOV CX, 16
        MOV DH, 20
        MOV DL, 32
        
        _loop_sair_proximo_caracter:
        CALL cursor

        MOV AL, [BX]
        CALL caracter

        INC DL
        INC BX
        LOOP _loop_sair_proximo_caracter

        MOV AL, [tecla]
        CMP AL, Y_SOLTO
        JNE _loop_sair_2
        JMP sair
        _loop_sair_2:

        CMP AL, N_SOLTO
        JE _loop_sair_fim
        JMP _loop_sair_1

        _loop_sair_fim:
        MOV BYTE [cor], preto
        MOV BX, mensagem_sair
        MOV CX, 16
        MOV DH, 20
        MOV DL, 32
        
        _loop_sair_limpar_proximo_caracter:
        CALL cursor

        MOV AL, [BX]
        CALL caracter

        INC DL
        INC BX
        LOOP _loop_sair_limpar_proximo_caracter

        POP DX
        POP CX
        POP BX
        POP AX
        RET

    atualiza_status_controles:
        PUSH AX

        MOV AL, [tecla]

        CMP AL, W_APERTADO
        JNE _atualiza_status_controles_1
        OR BYTE [status_controles], P1_CIMA
        _atualiza_status_controles_1:

        CMP AL, W_SOLTO
        JNE _atualiza_status_controles_2
        MOV AH, P1_CIMA
        NOT AH
        AND [status_controles], AH
        _atualiza_status_controles_2:

        CMP AL, S_APERTADO
        JNE _atualiza_status_controles_3
        OR BYTE [status_controles], P1_BAIXO
        _atualiza_status_controles_3:

        CMP AL, S_SOLTO
        JNE _atualiza_status_controles_4
        MOV AH, P1_BAIXO
        NOT AH
        AND [status_controles], AH
        _atualiza_status_controles_4:

        CMP AL, CIMA_APERTADO
        JNE _atualiza_status_controles_5
        OR BYTE [status_controles], P2_CIMA
        _atualiza_status_controles_5:

        CMP AL, CIMA_SOLTO
        JNE _atualiza_status_controles_6
        MOV AH, P2_CIMA
        NOT AH
        AND [status_controles], AH
        _atualiza_status_controles_6:

        CMP AL, BAIXO_APERTADO
        JNE _atualiza_status_controles_7
        OR BYTE [status_controles], P2_BAIXO
        _atualiza_status_controles_7:

        CMP AL, BAIXO_SOLTO
        JNE _atualiza_status_controles_8
        MOV AH, P2_BAIXO
        NOT AH
        AND [status_controles], AH
        _atualiza_status_controles_8:

        POP AX
        RET

    executa_controles:
        CALL executa_controles_P1
        CALL executa_controles_P2

        RET

    executa_controles_P1:
        PUSH AX

        MOV AL, [status_controles]
        AND AL, CONTROLES_P1
        CMP AL, P1_CIMA
        JNE _executa_controles_P1_1
        MOV AX, raquete_h
        ADD AX, [raquete_esquerda_posicao_y]
        ADD AX, 5
        CMP AX, 479
        JAE _executa_controles_P1_2
        MOV WORD [raquete_esquerda_velocidade_y], 5
        JMP _executa_controles_P1_fim

        _executa_controles_P1_1:
        MOV AL, [status_controles]
        AND AL, CONTROLES_P1
        CMP AL, P1_BAIXO
        JNE _executa_controles_P1_2
        MOV AX, [raquete_esquerda_posicao_y]
        SUB AX, raquete_h
        SUB AX, 5
        CMP AX, 0
        JLE _executa_controles_P1_2
        MOV WORD [raquete_esquerda_velocidade_y], -5
        JMP _executa_controles_P1_fim

        _executa_controles_P1_2:
        MOV WORD [raquete_esquerda_velocidade_y], 0

        _executa_controles_P1_fim:
        POP AX
        RET

    executa_controles_P2:
        PUSH AX

        MOV AL, [status_controles]
        AND AL, CONTROLES_P2
        CMP AL, P2_CIMA
        JNE _executa_controles_P2_1
        MOV AX, raquete_h
        ADD AX, [raquete_direita_posicao_y]
        ADD AX, 5
        CMP AX, 479
        JAE _executa_controles_P2_2
        MOV WORD [raquete_direita_velocidade_y], 5
        JMP _executa_controles_P2_fim

        _executa_controles_P2_1:
        MOV AL, [status_controles]
        AND AL, CONTROLES_P2
        CMP AL, P2_BAIXO
        JNE _executa_controles_P2_2
        MOV AX, [raquete_direita_posicao_y]
        SUB AX, raquete_h
        SUB AX, 5
        CMP AX, 0
        JLE _executa_controles_P2_2
        MOV WORD [raquete_direita_velocidade_y], -5
        JMP _executa_controles_P2_fim

        _executa_controles_P2_2:
        MOV WORD [raquete_direita_velocidade_y], 0

        _executa_controles_P2_fim:
        POP AX
        RET
    
    proximo_frame:
        PUSH AX
        CALL quica_bola

        MOV     BYTE AL, preto
        PUSH AX
        call desenhar_bola
        CALL move_bola
        CALL desenhar_bordas
        MOV     BYTE AL, vermelho
        PUSH AX
        CALL desenhar_bola
        CALL limpar_raquetes
        CALL move_raquetes
        CALL desenhar_raquetes

        POP AX
        RET

    quica_bola:
        CALL quica_bola_parede_cima
        CALL quica_bola_parede_baixo
        CALL quica_bola_bloco_direito
        CALL quica_bola_bloco_esquerdo
        CALL quica_bola_raquete_direita
        CALL quica_bola_raquete_esquerda
        RET
        
    quica_bola_parede_cima:
        PUSH AX
        PUSHf

        MOV AX, bola_raio
        CMP AX, [bola_posicao_y]
        JAE quica_bola_parede_cima_fim
        NEG WORD [bola_velocidade_y]

        quica_bola_parede_cima_fim:
        POPf
        POP AX
        RET

    quica_bola_parede_baixo:
        PUSH AX
        PUSHf

        MOV AX, 479
        SUB AX, bola_raio
        CMP AX, [bola_posicao_y]
        JBE quica_bola_parede_baixo_fim
        NEG WORD [bola_velocidade_y]

        quica_bola_parede_baixo_fim:
        
        POPf
        POP AX
        RET

    quica_bola_raquete_direita:
        PUSH AX
        
        MOV AX, [raquete_direita_posicao_x]
        SUB AX, raquete_w
        SUB AX, bola_raio

        CMP AX, [bola_posicao_x]
        JAE quica_bola_raquete_direita_fim

        MOV AX, [raquete_direita_posicao_x]
        ADD AX, raquete_w
        SUB AX, bola_raio

        CMP AX, [bola_posicao_x]

        JB quica_bola_raquete_direita_fim

        MOV AX, [bola_posicao_y]
        SUB AX, raquete_h
        CMP AX, [raquete_direita_posicao_y]

        JA quica_bola_raquete_direita_fim

        MOV AX, [bola_posicao_y]
        ADD AX, raquete_h
        CMP AX, [raquete_direita_posicao_y]

        JB quica_bola_raquete_direita_fim

        CALL desenhar_raquetes

        MOV AX, [bola_velocidade_x]
        CMP AX, 0
        JB quica_bola_raquete_direita_fim

        NEG WORD [bola_velocidade_x]

        quica_bola_raquete_direita_fim:
        
        POP AX
        RET

    quica_bola_raquete_esquerda:
        PUSH AX
        
        MOV AX, [raquete_esquerda_posicao_x]
        ADD AX, raquete_w
        ADD AX, bola_raio

        CMP AX, [bola_posicao_x]
        JBE quica_bola_raquete_esquerda_fim

        MOV AX, [raquete_esquerda_posicao_x]
        SUB AX, raquete_w
        ADD AX, bola_raio

        CMP AX, [bola_posicao_x]

        JA quica_bola_raquete_esquerda_fim

        MOV AX, [bola_posicao_y]
        SUB AX, raquete_h
        CMP AX, [raquete_esquerda_posicao_y]

        JA quica_bola_raquete_esquerda_fim

        MOV AX, [bola_posicao_y]
        ADD AX, raquete_h
        CMP AX, [raquete_esquerda_posicao_y]

        JB quica_bola_raquete_esquerda_fim

        CALL desenhar_raquetes

        MOV AX, [bola_velocidade_x]
        CMP AX, 0
        JA quica_bola_raquete_esquerda_fim

        NEG WORD [bola_velocidade_x]

        quica_bola_raquete_esquerda_fim:
        
        POP AX
        RET

    quica_bola_bloco_direito:
        PUSH AX
        PUSHf

        MOV AX, [bloco_1_dir_x]
        SUB AX, bloco_w
        SUB AX, bola_raio

        CMP AX, [bola_posicao_x] 
        JB possivel_colisao_bloco_direito
        
        JMP quica_bola_bloco_direito_fim ; tive que fazer essa gambiarra porque tava fora do range do JAE

        possivel_colisao_bloco_direito:

        MOV AX, [bloco_1_dir_x]
        ADD AX, bloco_w
        SUB AX, bola_raio

        CMP AX, [bola_posicao_x]
        JA dentro_faixa_x_bloco_direito

        JMP quica_bola_bloco_direito_fim

        dentro_faixa_x_bloco_direito:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 1 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_1_dir_y]
        JA bloco_1_dir_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_1_dir_y]
        JB bloco_1_dir_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_1_dir_ativo]
        CMP AX, 1
        JNE bloco_1_dir_fim

        MOV BYTE [bloco_1_dir_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_1_dir_x]
        PUSH AX
        MOV AX,[bloco_1_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_direito_fim

        bloco_1_dir_fim:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 2 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_2_dir_y]
        JA bloco_2_dir_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_2_dir_y]
        JB bloco_2_dir_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_2_dir_ativo]
        CMP AX, 1
        JNE bloco_2_dir_fim

        MOV BYTE [bloco_2_dir_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_2_dir_x]
        PUSH AX
        MOV AX,[bloco_2_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_direito_fim

        bloco_2_dir_fim:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 3 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_3_dir_y]
        JA bloco_3_dir_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_3_dir_y]
        JB bloco_3_dir_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_3_dir_ativo]
        CMP AX, 1
        JNE bloco_3_dir_fim

        MOV BYTE [bloco_3_dir_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_3_dir_x]
        PUSH AX
        MOV AX,[bloco_3_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_direito_fim

        bloco_3_dir_fim:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 4 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_4_dir_y]
        JA bloco_4_dir_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_4_dir_y]
        JB bloco_4_dir_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_4_dir_ativo]
        CMP AX, 1
        JNE bloco_4_dir_fim

        MOV BYTE [bloco_4_dir_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_4_dir_x]
        PUSH AX
        MOV AX,[bloco_4_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_direito_fim

        bloco_4_dir_fim:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 5 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_5_dir_y]
        JA bloco_5_dir_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_5_dir_y]
        JB bloco_5_dir_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_5_dir_ativo]
        CMP AX, 1
        JNE bloco_5_dir_fim

        MOV BYTE [bloco_5_dir_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_5_dir_x]
        PUSH AX
        MOV AX,[bloco_5_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_direito_fim

        bloco_5_dir_fim:

        quica_bola_bloco_direito_fim:

        POPf
        POP AX

        RET

    quica_bola_bloco_esquerdo:
        PUSH AX
        PUSHf

        MOV AX, [bloco_1_esq_x]
        ADD AX, bloco_w
        ADD AX, bola_raio

        CMP AX, [bola_posicao_x]

        JA possivel_colisao_bloco_esquerdo ; verifica se a posicao x da bola para determinar colisoes

        JMP quica_bola_bloco_esquerdo_fim   ; tive que fazer essa gambiarra porque tava fora do range do JBE

        possivel_colisao_bloco_esquerdo:

        MOV AX, [bloco_1_esq_x]
        SUB AX, bloco_w
        ADD AX, bola_raio

        CMP AX, [bola_posicao_x]

        JB dentro_faixa_x_bloco_esquerdo

        JMP quica_bola_bloco_esquerdo_fim

        dentro_faixa_x_bloco_esquerdo:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 1 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_1_esq_y]
        JA bloco_1_esq_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_1_esq_y]
        JB bloco_1_esq_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_1_esq_ativo]
        CMP AX, 1
        JNE bloco_1_esq_fim

        MOV BYTE [bloco_1_esq_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_1_esq_x]
        PUSH AX
        MOV AX,[bloco_1_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_esquerdo_fim

        bloco_1_esq_fim:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 2 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_2_esq_y]
        JA bloco_2_esq_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_2_esq_y]
        JB bloco_2_esq_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_2_esq_ativo]
        CMP AX, 1
        JNE bloco_2_esq_fim

        MOV BYTE [bloco_2_esq_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_2_esq_x]
        PUSH AX
        MOV AX,[bloco_2_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_esquerdo_fim

        bloco_2_esq_fim:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 3 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_3_esq_y]
        JA bloco_3_esq_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_3_esq_y]
        JB bloco_3_esq_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_3_esq_ativo]
        CMP AX, 1
        JNE bloco_3_esq_fim

        MOV BYTE [bloco_3_esq_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_3_esq_x]
        PUSH AX
        MOV AX,[bloco_3_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_esquerdo_fim

        bloco_3_esq_fim:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 4 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_4_esq_y]
        JA bloco_4_esq_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_4_esq_y]
        JB bloco_4_esq_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_4_esq_ativo]
        CMP AX, 1
        JNE bloco_4_esq_fim

        MOV BYTE [bloco_4_esq_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_4_esq_x]
        PUSH AX
        MOV AX,[bloco_4_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_esquerdo_fim

        bloco_4_esq_fim:

        MOV AX, [bola_posicao_y]          ; verifica se a bola esta dentro do alcance do bloco 5 esquerdo
        SUB AX, bloco_h
        CMP AX, [bloco_5_esq_y]
        JA bloco_5_esq_fim

        MOV AX, [bola_posicao_y]
        ADD AX, bloco_h
        CMP AX, [bloco_5_esq_y]
        JB bloco_5_esq_fim

        XOR AX, AX                      ; caso esteja dentro do alcance, verifica se o bloco esta ativo
        MOV AL, BYTE [bloco_5_esq_ativo]
        CMP AX, 1
        JNE bloco_5_esq_fim

        MOV BYTE [bloco_5_esq_ativo], 0  ; caso esteja no alcance e o bloco esteja ativo, desativa o bloco e da bounce

        MOV BYTE [cor], preto
        MOV AX,[bloco_5_esq_x]
        PUSH AX
        MOV AX,[bloco_5_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        NEG WORD [bola_velocidade_x]
        JMP quica_bola_bloco_esquerdo_fim

        bloco_5_esq_fim:

        quica_bola_bloco_esquerdo_fim:

        POPf
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

    move_raquetes:
        MOV AX, [raquete_esquerda_posicao_y]
        ADD AX, [raquete_esquerda_velocidade_y]
        MOV [raquete_esquerda_posicao_y], AX

        MOV AX, [raquete_direita_posicao_y]
        ADD AX, [raquete_direita_velocidade_y]
        MOV [raquete_direita_posicao_y], AX

        RET

    limpar_raquetes:
        PUSH AX

        MOV BYTE [cor], preto
        MOV AX, [raquete_esquerda_posicao_x]
        PUSH AX
        MOV AX, [raquete_esquerda_posicao_y]
        PUSH AX
        MOV AX, raquete_w
        PUSH AX
        MOV AX, raquete_h
        PUSH AX
        call fblock

        MOV BYTE [cor], preto
        MOV AX, [raquete_direita_posicao_x]
        PUSH AX
        MOV AX, [raquete_direita_posicao_y]
        PUSH AX
        MOV AX, raquete_w
        PUSH AX
        MOV AX, raquete_h
        PUSH AX
        call fblock

        POP AX

        RET
    
    desenhar_raquetes:
        PUSH AX

        MOV BYTE [cor], cyan_claro
        MOV AX, [raquete_esquerda_posicao_x]
        PUSH AX
        MOV AX, [raquete_esquerda_posicao_y]
        PUSH AX
        MOV AX, raquete_w
        PUSH AX
        MOV AX, raquete_h
        PUSH AX
        call fblock

        MOV BYTE [cor], cyan_claro
        MOV AX, [raquete_direita_posicao_x]
        PUSH AX
        MOV AX, [raquete_direita_posicao_y]
        PUSH AX
        MOV AX, raquete_w
        PUSH AX
        MOV AX, raquete_h
        PUSH AX
        call fblock

        POP AX

        RET

    desenhar_blocos:
        PUSH AX

        MOV BYTE [cor], rosa
        MOV AX,[bloco_1_esq_x]
        PUSH AX
        MOV AX,[bloco_1_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], magenta_claro
        MOV AX,[bloco_2_esq_x]
        PUSH AX
        MOV AX,[bloco_2_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], magenta
        MOV AX,[bloco_3_esq_x]
        PUSH AX
        MOV AX,[bloco_3_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], vermelho
        MOV AX,[bloco_4_esq_x]
        PUSH AX
        MOV AX,[bloco_4_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], amarelo
        MOV AX,[bloco_5_esq_x]
        PUSH AX
        MOV AX,[bloco_5_esq_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], rosa
        MOV AX,[bloco_1_dir_x]
        PUSH AX
        MOV AX,[bloco_1_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], magenta_claro
        MOV AX,[bloco_2_dir_x]
        PUSH AX
        MOV AX,[bloco_2_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], magenta
        MOV AX,[bloco_3_dir_x]
        PUSH AX
        MOV AX,[bloco_3_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], vermelho
        MOV AX,[bloco_4_dir_x]
        PUSH AX
        MOV AX,[bloco_4_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        MOV BYTE [cor], amarelo
        MOV AX,[bloco_5_dir_x]
        PUSH AX
        MOV AX,[bloco_5_dir_y]
        PUSH AX
        MOV AX,bloco_w
        PUSH AX
        MOV AX,bloco_h
        PUSH AX
        CALL fblock

        POP AX

        RET

    desenhar_bola:                      ; passar a cor como parametro pra essa funcao para poder usar ela para apagar a bola tambem
        PUSH 	BP                      ; colocar a cor em BL e passar BX inteiro por push na stack
        MOV	 	BP,SP                   
        PUSH 	AX
        
        MOV		AX,[BP+4]    			; resgata a cor

        MOV BYTE [cor], AL

        MOV AX, [bola_posicao_x]
        PUSH AX
        MOV AX, [bola_posicao_y]
        PUSH AX
        MOV AX, bola_raio
        PUSH AX
        CALL fcircle

        POP     AX
        POP     BP

        RET 2


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
    
    ; dados do menu de dificuldade
    facil db 'facil'
    medio db 'medio'
    dificil db 'dificil'

    dificuldade_selecionada db 0

    ; mensagem de sair do jogo
    mensagem_sair db 'sair? [y]es [n]o'

    ; variaveis da bola
    bola_raio equ 10
    bola_posicao_x dw 320
    bola_posicao_y dw 240

    bola_velocidade_x dw 0001h
    bola_velocidade_y dw 0001h

    ; variaveis de blocos
    bloco_w         equ     7
    bloco_h         equ     40

    bloco_1_esq_x   dw  20
    bloco_1_esq_y   dw  48
    bloco_1_esq_ativo db 1

    bloco_2_esq_x   dw  20
    bloco_2_esq_y   dw  144
    bloco_2_esq_ativo db 1

    bloco_3_esq_x   dw  20
    bloco_3_esq_y   dw  240
    bloco_3_esq_ativo db 1

    bloco_4_esq_x   dw  20
    bloco_4_esq_y   dw  336
    bloco_4_esq_ativo db 1

    bloco_5_esq_x   dw  20
    bloco_5_esq_y   dw  432
    bloco_5_esq_ativo db 1

    bloco_1_dir_x   dw  619
    bloco_1_dir_y   dw  48
    bloco_1_dir_ativo db 1

    bloco_2_dir_x   dw  619
    bloco_2_dir_y   dw  144
    bloco_2_dir_ativo db 1

    bloco_3_dir_x   dw  619
    bloco_3_dir_y   dw  240
    bloco_3_dir_ativo db 1

    bloco_4_dir_x   dw  619
    bloco_4_dir_y   dw  336
    bloco_4_dir_ativo db 1

    bloco_5_dir_x   dw  619
    bloco_5_dir_y   dw  432
    bloco_5_dir_ativo db 1


    ; dimensoes das raquetes

    raquete_w equ 10
    raquete_h equ 40

    ; variaveis da raquete esquerda
    raquete_esquerda_posicao_x dw 50
    raquete_esquerda_posicao_y dw 240

    raquete_esquerda_velocidade_y dw 0000h
    
    ; variaveis da raquete direita
    raquete_direita_posicao_x dw 590
    raquete_direita_posicao_y dw 240

    raquete_direita_velocidade_y dw 0000h

    ; variavel de estado dos controles:
    ;
    ; Bit 0 - Jogador 1 cima
    ; Bit 1 - Jogador 1 baixo
    ; Bit 2 - Jogador 2 cima
    ; Bit 3 - jogador 2 baixo

    status_controles db 0

    ; CONSTANTES

    CONTROLES_P1 EQU 00000011b
    CONTROLES_P2 EQU 00001100b
    P1_CIMA  EQU 00000001b
    P1_BAIXO EQU 00000010b
    P2_CIMA  EQU 00000100b
    P2_BAIXO EQU 00001000b

    CIMA_APERTADO  EQU 0x48
    CIMA_SOLTO     EQU 0xC8
    BAIXO_APERTADO EQU 0x50
    BAIXO_SOLTO    EQU 0XD0

    W_APERTADO EQU 0x11
    W_SOLTO    EQU 0x91
    S_APERTADO EQU 0x1F
    S_SOLTO    EQU 0x9F

    Y_SOLTO EQU 0x95
    N_SOLTO EQU 0xB1
    Q_SOLTO EQU 0x90
    ENTER_APERTADO EQU 0x1C

    global tecla
    tecla db 0

segment stack stack
    resb 256
    stack_top: