segment code
    global preparar_int9
    global salvar_modo_grafico
    global iniciar_modo_grafico_VGA
    global restaurar_modo_grafico
    global encerrar_programa

    preparar_int9:
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
        RET

    int_teclado:
        PUSH AX
        PUSH BX

        XOR AX, AX
        IN AL, PORTA_DADO_TECLADO
        MOV BL, AL
        IN AL, PORTA_CONTROLE_TECLADO
        OR AL, 80h
        OUT PORTA_CONTROLE_TECLADO, AL
        AND AL, 7Fh
        OUT PORTA_CONTROLE_TECLADO, AL
        MOV AL, EOI
        OUT PORTA_CONTROLE_PIC, AL

        CMP BL, Q_MINUSCULO
        JNE int_teclado_IRET
        CALL restaurar_modo_grafico
        POP BX
        POP AX
        CALL encerrar_programa

        int_teclado_IRET:
        POP BX
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

segment data
    PORTA_DADO_TECLADO EQU 60h
    PORTA_CONTROLE_TECLADO EQU 61h
    EOI EQU 20h
    PORTA_CONTROLE_PIC EQU 20h
    Q_MINUSCULO EQU 0x81

    tecla dw 0

    modo_grafico_anterior db 0

    IP_INT9_DOS dw 0
    CS_INT9_DOS dw 0