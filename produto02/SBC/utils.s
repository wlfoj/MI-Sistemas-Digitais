/*
    ------------------------------------------------
    Função que faz uma mascara para obter o valor de um bit
    ------------------------------------------------
    Registradores de Parâmetros e Retornos:
    	* r5 -> reg que possui o bit a ser lido
    	* r6 -> posição a ser analisada em r5
    	* r3 -> valor de retorno (se o bit era 1 ou 0)
*/
@ Chamo com bl ou blx
mascaraBit: 
    @ Colocando na pilha r5 e r7
    sub sp, sp, #16
    str r10,[sp,#8]
    str r7,[sp,#0]

    mov r10, #1 @Crio uma maskara em r10  ...0000001
	lsr r7, r5, r6 @ Pego r5, desloco r6 bits para a esquerda e guardo no temporario r7
    and r3, r7, r10 @ Aplico a mascara para obter o valor no bit menos significativo

    @ Retirando da pilha r10 e r7
    ldr r10,[sp,#8]
    ldr r7,[sp,#0]
    add sp, sp, #16

    bx lr @ Retorno o PC para quem chamou a função


/*
    ------------------------------------------------
    Pega somente o número do sensor dos dados da UART
    ------------------------------------------------
    Registradores de Parâmetros e Retornos:
    	* r12 -> reg que possui os dados da UART (2 bytes)
    	* r3 -> reg de retorno com o número do sensor
*/
pegaNumSensor:
    sub sp, sp, #8
    str r10, [sp, #0]
    
    mov r10, #0b11111 @ Coloca a mascara para pegar os 5 bits de 4:0 dos dados recebidos pela UART
    and r3, r12, r10

    ldr r10, [sp, #0]
    add sp, sp, #8

    bx lr


/*
    ------------------------------------------------
    Pega somente o número do comando dos dados da UART
    ------------------------------------------------
    Registradores de Parâmetros e Retornos:
    	* r12 -> reg que possui os dados da UART (2 bytes)
    	* r3 -> reg de retorno com o código do comando
*/
pegaNumComando:
    sub sp, sp, #8
    str r10, [sp, #0]
    
    mov r10, #0b111100000 @ Coloca a mascara para pegar os 4 bits de 8:5 
    and r3, r12, r10
    lsr r3, #5

    ldr r10, [sp, #0]
    add sp, sp, #8
    t1:
    bx lr

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
    Pega somente a parte corrrespondente aos dados de leitura da UART
    ------------------------------------------------
    Retira apenas o valor da leitura. Ex no caso de leitura de temperatura
    vai pegar 23
    Registradores de Parâmetros e Retornos:
    	* r12 -> reg que possui os dados da UART (2 bytes)
    	* r3 -> reg de retorno com o código do comando
*/
pegaNumDados:
    lsr r3, r12, #9 @ TESTAR SE É NOVE MESMO
    bx lr


/* 
    ------------------------------------------------
    Função que faz separa o valor em dezenas e unidades
    ------------------------------------------------
    Esta função serve para auxiliar a função de escrever números no display, pois 
    sabendo qual é o digito da dezena e qual é o digito da unidade só será preciso passa-los
    pro comando (db7 a db4).
    !! Só funciona para valores entre 1 e 99
    Se r3 for 54, r0 será 5 e r1 será 4

    Registradores de Parâmetros e Retornos:
    	* r5 -> reg que possui o valor a ser convertido (Parametro)
    	* r3 -> Dezena (Retorno)
    	* r4 -> Unidade (Retorno)
*/
SeparaDezenaUnidadeV2:
    @ Colocando na pilha r8 e r7
    sub sp, sp, #16
    str r8,[sp,#8] @ Usado como temporário
    str r7,[sp,#0] @ Usado como temporário

    mov r3, #0 @ guarda o digito da dezena (Será retornado)
    mov r7, #0 @ Guarda o digito da unidade (Será retornado)
    
    cmp r5, #10
    BLT NADA
    
    CMP r5, #0 @ Teste para o caso de passar 0 em r5
    BEQ RETURN @ Teste para o caso de passar 0 em r5
    WHILE:
        add r7, r7, #10 @ Aumenta uma dezena
        add r3, r3, #1 @ Aumenta o digito da dezena
        sub r8, r5, r7 @ r8 = r3 - r7
        CMP r8, #10
        BGE WHILE @ Se o resultado for maior ou igual a 10, continue
    mov r4, r8 @ Quando saio do laço, já tenho a resposta do valor menos a dezena, que é a unidade, em r8
    RETURN:
        @ Retirando da pilha r8 e r7
        ldr r8,[sp,#8]
        ldr r7,[sp,#0]
        add sp, sp, #16
        bx lr
    NADA:
        mov r3, #0
        mov r4, r5
        b RETURN

