segment code
    extern tecla

    global preparar_int9
    global salvar_modo_grafico
    global iniciar_modo_grafico_VGA
    global restaurar_modo_grafico
    global encerrar_programa
    global sair

    preparar_int9:
        PUSH AX
        PUSHF

        CLI
        XOR AX, AX
        MOV ES, AX
        MOV AX, [ES:9h*4]
        MOV [IP_INT9_DOS], AX
        MOV AX, [ES:9h*4+2]
        MOV [CS_INT9_DOS], AX
        MOV WORD [ES:9h*4], int_teclado
        MOV [ES:9h*4+2], CS
        STI

        POPF
        POP AX
        RET

    restaurar_int9:
        PUSH AX
        PUSHF

        CLI
        XOR AX, AX
        MOV ES, AX
        MOV AX, IP_INT9_DOS
        MOV [ES:9h*4], AX
        MOV AX, CS_INT9_DOS
        MOV [ES:9h*4+2], AX
        STI

        POPF
        POP AX
        RET

    int_teclado:
        PUSH AX
        PUSHF

        XOR AX, AX
        IN AL, PORTA_DADO_TECLADO
        MOV [tecla], AL

        ;Reiniciando o PIC
        IN AL, PORTA_CONTROLE_TECLADO
        OR AL, 80h
        OUT PORTA_CONTROLE_TECLADO, AL
        AND AL, 7Fh
        OUT PORTA_CONTROLE_TECLADO, AL
        MOV AL, EOI
        OUT PORTA_CONTROLE_PIC, AL

        POPF
        POP AX
        IRET


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

    sair:
        CALL restaurar_int9
        CALL restaurar_modo_grafico
        JMP encerrar_programa

segment data
    PORTA_DADO_TECLADO EQU 60h
    PORTA_CONTROLE_TECLADO EQU 61h
    EOI EQU 20h
    PORTA_CONTROLE_PIC EQU 20h
    Q_MINUSCULO EQU 10h

    modo_grafico_anterior db 0

    IP_INT9_DOS dw 0
    CS_INT9_DOS dw 0