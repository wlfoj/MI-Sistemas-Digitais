/*
    ------------------------------------------------
        Escreve COMANDO na segunda linha do display
    ------------------------------------------------
    Esta é uma função auxiliar para ser exibida nas telas
    de recebimento de dados da UART
    O exemplo de como seria exibido:
                xxxxxxxxxxxx
                   COMANDO

*/
EscreveComandoNaSegundaLinha:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    
    bl shiftRightCursor
    bl shiftRightCursor
    bl shiftRightCursor
    bl shiftRightCursor
    @ Escreve C
    mov R1, #0b01000011
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
    @ Escreve M
    mov R1, #0b01001101
    bl WriteCharLCD
    @ Escreve A
    mov R1, #0b01000001
    bl WriteCharLCD
    @ Escreve N
    mov R1, #0b01001110
    bl WriteCharLCD
    @ Escreve D
    mov R1, #0b01000100
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
	
	bl shiftRightCursor

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
	bx lr

/*
    ------------------------------------------------
        Escreve a temperatura no formato indicado
    ------------------------------------------------
                S01 TEMP:21ºC
                xxxxxxxxxxxx

    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
WriteTemperatureLCD:
    @ Salvo o endereço de quem chamou a função, pois vou entrar em outras funções aqui dentro. O lr inicial seria perdido
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário

    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    bl pegaNumSensor@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    bl shiftRightCursor@ Suponndo que dá o espaço
    @ ESCREVE 'TEMP'
    mov R1, #0b01010100 @ T
    bl WriteCharLCD
    mov R1, #0b01000101 @ E
    bl WriteCharLCD
    mov R1, #0b01001101 @ M
    bl WriteCharLCD
    mov R1, #0b01010000 @ P
    bl WriteCharLCD

    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    bl shiftRightCursor@ Suponndo que dá o espaço

    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    bl pegaNumDados@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    @ Escreve º
    mov R1, #0b11011111
    bl WriteCharLCD
    @ Escreve C
    mov R1, #0b01000011
    bl WriteCharLCD

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr

/*
    ------------------------------------------------
        Escreve a umidade no formato indicado
    ------------------------------------------------
                S01 UMID:21%
                xxxxxxxxxxxx

    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
WriteHumidityLCD:
    @ Salvo o endereço de quem chamou a função, pois vou entrar em outras funções aqui dentro. O lr inicial seria perdido
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário

    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD

    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    bl pegaNumSensor@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    bl shiftRightCursor@ Suponndo que dá o espaço
    @ ESCREVE 'UMID'
    mov R1, #0b01010101 @ U
    bl WriteCharLCD
    mov R1, #0b01001101 @ M
    bl WriteCharLCD
    mov R1, #0b01001001 @ I
    bl WriteCharLCD
    mov R1, #0b01000100 @ D
    bl WriteCharLCD

    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    bl shiftRightCursor@ Suponndo que dá o espaço

    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    bl pegaNumDados@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    @ Escreve %
    mov R1, #0b00100101
    bl WriteCharLCD

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr



/*
    ------------------------------------------------
        Parte de cima da tela para inserir o comando
    ------------------------------------------------
                S:00 C:00
                xxxxxxxxxxxx

    r12 -> É onde está o num do sensor(5 bits mais altos) e o codigo do comando(4 bits mais baixos)
    EX. Primeiro num sensor e depois comando 01010 1100
*/ 
ParteDeCimaTelaComandos:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @====================Parte de cima====================@
    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    @ Escreve o nº do sensor
    @ ================ TRECHO PARA ESCREVER O NUM Do sensor
    @ CHAMAR AQUI A MASCARA
    and r5, r12, #0b11111 @ Mascara para pegar os 4 ultimos bits
    bl SeparaDezenaUnidadeV2@ Dezena em r0 e unidade em r1
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ espaço 4x
    bl shiftRightCursor
    bl shiftRightCursor
    bl shiftRightCursor
    bl shiftRightCursor
    
    @ Escreve C
    mov R1, #0b01000011
    bl WriteCharLCD
    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    @ Escreve o nº do comando
    @ ================ TRECHO PARA ESCREVER O NUM Do comando
    @ CHAMAR AQUI A MASCARA
    lsr r5, r12, #8
    and r5, r5, #0b1111@ Faço and para pegar apenas os 4 últimos bits 
    bl SeparaDezenaUnidadeV2@ Dezena em r0 e unidade em r1
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr
    .ltorg


/*
    ------------------------------------------------
        Parte de baixo da tela para inserir o comando
    ------------------------------------------------
                xxxxxxxxxxxxxxxx
                VOLTAR SEGUIR
*/ 
ParteDeBaixoTelaComandos:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    
    @ Escreve V
    mov R1, #0b01010110
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
    @ Escreve L
    mov R1, #0b01001100
    bl WriteCharLCD
    @ Escreve T
    mov R1, #0b01010100
    bl WriteCharLCD
    @ Escreve A
    mov R1, #0b01000001
    bl WriteCharLCD
    @ Escreve R
    mov R1, #0b01010010
    bl WriteCharLCD
    
    bl shiftRightCursor
    
    bl shiftRightCursor
    bl shiftRightCursor
    
    bl shiftRightCursor
    
    .ltorg
    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ Escreve E
    mov R1, #0b01000101
    bl WriteCharLCD
    @ Escreve G
    mov R1, #0b01000111
    bl WriteCharLCD
    @ Escreve U
    mov R1, #0b01010101
    bl WriteCharLCD
    @ Escreve I
    mov R1, #0b01001001
    bl WriteCharLCD
    @ Escreve R
    mov R1, #0b01010010
    bl WriteCharLCD
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr
    .ltorg



 /*
    ------------------------------------------------
    Parte de cima da tela para de continuo de temperatura desligado
    ------------------------------------------------
                 S01 TEMPC:OFF
                xxxxxxxxxxxxxx
*/ 
DesligaTempContinuos:
    @ Salvo o endereço de quem chamou a função, pois vou entrar em outras funções aqui dentro. O lr inicial seria perdido
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    bl pegaNumSensor@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    bl shiftRightCursor@ Suponndo que dá o espaço
    @ ESCREVE 'TEMP'
    mov R1, #0b01010100 @ T
    bl WriteCharLCD
    mov R1, #0b01000101 @ E
    bl WriteCharLCD
    mov R1, #0b01001101 @ M
    bl WriteCharLCD
    mov R1, #0b01010000 @ P
    bl WriteCharLCD
    mov R1, #0b01000011 @ C
    bl WriteCharLCD
    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    bl shiftRightCursor@ Suponndo que dá o espaço
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
    @ Escreve F
    mov R1, #0b01000110
    bl WriteCharLCD
    @ Escreve F
    mov R1, #0b01000110
    bl WriteCharLCD

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr

 /*
    ------------------------------------------------
    Parte de cima da tela para de continuo de umidade desligado
    ------------------------------------------------
                 S01 UMIDC:OFF
                xxxxxxxxxxxxxx
*/ 
DesligaUmidContinuos:
    @ Salvo o endereço de quem chamou a função, pois vou entrar em outras funções aqui dentro. O lr inicial seria perdido
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário

    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    bl pegaNumSensor@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    bl shiftRightCursor@ Suponndo que dá o espaço
    @ ESCREVE 'UMIDC'
    mov R1, #0b01010101 @ U
    bl WriteCharLCD
    mov R1, #0b01001101 @ M
    bl WriteCharLCD
    mov R1, #0b01001001 @ I
    bl WriteCharLCD
    mov R1, #0b01000100 @ D
    bl WriteCharLCD
    mov R1, #0b01000011 @ C
    bl WriteCharLCD
    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
    @ Escreve F
    mov R1, #0b01000110
    bl WriteCharLCD
    @ Escreve F
    mov R1, #0b01000110
    bl WriteCharLCD
    
    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr
    .ltorg
 
/*
    -------------------------------------------------------------
    Exibe a tela com a situação do sensor sendo OK no formato indicado
    -------------------------------------------------------------
                        S01:OK
                        xxxxxxx
*/
SituacaoSensorOk:
    @ Salvo o endereço de quem chamou a função, pois vou entrar em outras funções aqui dentro. O lr inicial seria perdido
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário

    bl shiftRightCursor
    bl shiftRightCursor
    bl shiftRightCursor
    bl shiftRightCursor
    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    bl pegaNumSensor@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============
    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
    @ Escreve K
    mov R1, #0b01001011
    bl WriteCharLCD

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr


/*
    -------------------------------------------------------------
    Exibe a tela com a situação do sensor sendo ERRO no formato indicado
    -------------------------------------------------------------
                        S01:ERRO
                        xxxxxxx
*/
SituacaoSensorErro:
    @ Salvo o endereço de quem chamou a função, pois vou entrar em outras funções aqui dentro. O lr inicial seria perdido
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário

    bl shiftRightCursor
    bl shiftRightCursor
    bl shiftRightCursor
    bl shiftRightCursor
    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    bl pegaNumSensor@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============
    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    @ Escreve E
    mov R1, #0b01000101
    bl WriteCharLCD
    @ Escreve R
    mov R1, #0b01010010
    bl WriteCharLCD
    @ Escreve R
    mov R1, #0b01010010
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr
@========================================================================================================================================@
@========================================================== Bloco para as telas =========================================================@
@========================================================================================================================================@

/*
    ------------------------------------------------
        Exibe a tela de temperatura no formato indicado
    ------------------------------------------------
                S01 TEMP:21ºC
                   COMANDO

    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_TEMPERATURA:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @ Limpando a tela e resetando cursor
    bl setInitialCursorPos @ Zera todo o cursor para conseguir escrever direito
    bl clearDisplay @ Para garantir que não vai ter lixo na tela

    bl WriteTemperatureLCD @ Parte da linha de cima
    bl jumpLine
    bl EscreveComandoNaSegundaLinha @ Parte da linha debaixo
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr


/*
    ------------------------------------------------
        Exibe a tela de temperatura no formato indicado
    ------------------------------------------------
                S01 UMID:21%
                   COMANDO

    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_UMIDADE:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @ Limpando a tela e resetando cursor
    bl setInitialCursorPos @ Zera todo o cursor para conseguir escrever direito
    bl clearDisplay @ Para garantir que não vai ter lixo na tela

    bl WriteHumidityLCD @ Parte da linha de cima
    bl jumpLine
    bl EscreveComandoNaSegundaLinha @ Parte da linha debaixo
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr


/*
    ------------------------------------------------
    Exibe a tela de inserir comando no formato indicado
    ------------------------------------------------
                S:00 C:00
                VOLTAR SEGUIR

    r12 -> É onde está o num do sensor(5 bits mais altos) e o codigo do comando(4 bits mais baixos)
    EX. Primeiro num sensor e depois comando 01010 1100
*/
TELA_COMANDOS:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @ Limpando a tela e resetando cursor
    bl setInitialCursorPos @ Zera todo o cursor para conseguir escrever direito
    bl clearDisplay @ Para garantir que não vai ter lixo na tela    
    
    bl ParteDeCimaTelaComandos @ Parte da linha de cima
    bl jumpLine
    bl ParteDeBaixoTelaComandos @ Parte da linha debaixo	    
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr
	
/*
    ------------------------------------------------
        Controla o fluxo da tela de comandos
    ------------------------------------------------
                S:00 C:00
                VOLTAR SEGUIR

    r12 -> É onde está os dados a serem enviados. [4:0] é num sensor e [11:8] é o comando
    EX. Primeiro num sensor e depois comando 01010 1100
*/
TELA_COMANDO_MAIS_EXTERNA:
    sub sp, sp, #24
    str r7,[sp,#16] 
    str r6,[sp,#8] 
    str lr,[sp,#0] @ Usado como temporário  
    
    

    
    
    @ ===========Loop principal da tela (estágio 1)=========== @
    INICIO_TELA_COMANDOS:
    mov r12, #0 @ Zero os dados para ser enviado
    @ O estágio 1 é onde controlo para qual sensor vou enviar os dados
    @ Faço o primeiro print da tela e espero apertar o botão Confirm para atualizar a tela
    bl TELA_COMANDOS 
    LOOP_1_TCOMANDO:
    @ Esperando apertar
    debouncePin bConfirm
    cmp r7, #1 @ Verifico se foi pressionado
    BEQ FIM_ESTAGIO_1 @ Se tiver pressionado e passado no teste do debounce, faço leitura das chaves e atualizo a tela
    @ Se não tiver passado, retorno o loop
    B LOOP_1_TCOMANDO
    FIM_ESTAGIO_1: 
    @ Faço a leitura das chaves e carrego no reg de enviar dados uart
    bl LER_CHAVES_GPIO @ Valores em r6
    add r12, r12, r6 @ Carrego num sensor
    @ Coloco no reg de enviar uart
    bl TELA_COMANDOS  @ Atualizo a tela 

    @ ===========Loop principal da tela (estágio 2)=========== @
    @ O estágio 2 é onde controlo para qual sensor vou enviar os dados
    LOOP_2_TCOMANDO:
    @ Esperando apertar
    debouncePin bConfirm
    cmp r7, #1 @ Verifico se foi pressionado
    BEQ FIM_ESTAGIO_2 @ Se tiver pressionado e passado no teste do debounce, faço leitura das chaves e atualizo a tela
    @ Se não tiver passado, retorno o loop
    B LOOP_2_TCOMANDO
    FIM_ESTAGIO_2: 
    @ Faço a leitura das chaves e carrego no reg de enviar dados uart
    bl LER_CHAVES_GPIO @ Valores em r6
    lsl r6, #8 @ Desloco para colocar os valores do comando no segundo byte
    add r12, r12, r6 @ Carrego o comando
    bl TELA_COMANDOS  @ Atualizo a tela 

    @ ===========Loop principal da tela (estágio 3)=========== @
    @ O estágio 3 é onde avalio se devo reiniciar a tela ou se já posso sair da  tela de comandos
    LOOP_3_TCOMANDO:
    @ Esperando apertar O SEGUIR
    debouncePin bConfirm
    cmp r7, #1 @ Verifico se foi pressionado
    BEQ FIM_ESTAGIO_3 @ Se tiver pressionado e passado no teste do debounce, faço leitura das chaves e atualizo a tela
    @ Se não tiver apertado o botão de SEGUIR, verifico se apertei o de VOLTAR    
    debouncePin bCancel
    cmp r7, #1 @ Verifico se foi pressionado
    BEQ INICIO_TELA_COMANDOS@ Se tiver pressionado, refaço o processo
    @ Se não tiver passado, retorno o loop
    B LOOP_3_TCOMANDO
    FIM_ESTAGIO_3: 
    @ FINALIZO TUDO E ENVIO


    str r7,[sp,#16] 
    str r6,[sp,#8] 
    ldr lr,[sp,#0]
    add sp, sp, #24
    bx lr
/*
    ------------------------------------------------------------------------------------------------
    Exibe a tela de desligamento do continuo de temperatura no formato indicado
    ------------------------------------------------------------------------------------------------
                                        S01 TEMPC:OFF
                                           COMANDO

    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_DESLIGA_CONTINUO_TEMP:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @ Limpando a tela e resetando cursor
    bl setInitialCursorPos @ Zera todo o cursor para conseguir escrever direito
    bl clearDisplay @ Para garantir que não vai ter lixo na tela

    bl DesligaTempContinuos @ Parte da linha de cima
    bl jumpLine
    bl EscreveComandoNaSegundaLinha @ Parte da linha debaixo
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr

/*
    ------------------------------------------------------------------------------------------------
    Exibe a tela de desligamento do continuo de umidade no formato indicado
    ------------------------------------------------------------------------------------------------
                                        S01 UMIDC:OFF
                                           COMANDO

    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_DESLIGA_CONTINUO_UMID:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @ Limpando a tela e resetando cursor
    bl setInitialCursorPos @ Zera todo o cursor para conseguir escrever direito
    bl clearDisplay @ Para garantir que não vai ter lixo na tela
    
    bl DesligaUmidContinuos @ Parte da linha de cima
    bl jumpLine
    bl EscreveComandoNaSegundaLinha @ Parte da linha debaixo

    ldr lr,[sp,#0]
    add sp, sp, #8
    
    bx lr

/*
    -------------------------------------------------------------
    Exibe a tela com a situação atual do sensor no formato indicado
    -------------------------------------------------------------
                        S01:OK
                        COMANDO

    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_SITUACAO_SENSOR_OK:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @ Limpando a tela e resetando cursor
    bl setInitialCursorPos @ Zera todo o cursor para conseguir escrever direito
    bl clearDisplay @ Para garantir que não vai ter lixo na tela

    bl SituacaoSensorOk @ Parte da linha de cima
    bl jumpLine
    bl EscreveComandoNaSegundaLinha @ Parte da linha debaixo
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr


/*
    -------------------------------------------------------------
    Exibe a tela com a situação atual do sensor no formato indicado
    -------------------------------------------------------------
                        S01:ERRO
                        COMANDO

    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_SITUACAO_SENSOR_ERRO:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @ Limpando a tela e resetando cursor
    bl setInitialCursorPos @ Zera todo o cursor para conseguir escrever direito
    bl clearDisplay @ Para garantir que não vai ter lixo na tela

    bl SituacaoSensorErro @ Parte da linha de cima
    bl jumpLine
    bl EscreveComandoNaSegundaLinha @ Parte da linha debaixo
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr


/*
    -------------------------------------------------------------
        Exibe a tela especifica, com base no código de resposta
    -------------------------------------------------------------
    R12 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
SELECAO_TELA:
@=======PUT PILHA
    sub sp, sp, #16
    str r0, [sp, #8]
    str lr, [sp, #0]
@=======PUT PILHA
    	bl pegaNumComando @ Retorna em r3
	 
	cmp r3, #15
	bne prox1
	bl TELA_SITUACAO_SENSOR_ERRO
	b encerra
	 
	prox1:
	cmp r3, #9
	bne prox2
	bl TELA_SITUACAO_SENSOR_OK
	b encerra
	 
	prox2:
	cmp r3, #10
	bne prox3
	bl TELA_UMIDADE
	b encerra
	 
	prox3:
	cmp r3, #11
	bne prox4
	bl TELA_TEMPERATURA
	b encerra
	 
	prox4:
	cmp r3, #12
	bne prox5
	bl TELA_DESLIGA_CONTINUO_TEMP
	b encerra
	 
	prox5:
	cmp r3, #13
	bne encerra 
	bl TELA_DESLIGA_CONTINUO_UMID
	 
	encerra:
	 
@=======POP PILHA
    ldr r0, [sp, #8]
    ldr lr, [sp, #0]
    add sp, sp, #16
@=======POP PILHA
	bx lr




TELA_INICIAL:
    sub sp, sp, #8
    str lr, [sp, #0]
    
    bl clearDisplay
    bl setInitialCursorPos
    bl jumpLine
    bl EscreveComandoNaSegundaLinha
    
    ldr lr, [sp, #0]
    add sp, sp, #8
    bx lr
    
    
    
