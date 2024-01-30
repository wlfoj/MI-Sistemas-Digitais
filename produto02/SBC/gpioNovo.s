.macro MemoryMap
	LDR R0, =devmem @ R0 = nome do arquivo
	MOV R1, #2 @ O_RDWR (permissao de leitura e escrita pra arquivo)
	MOV R7, #5 @ sys_open
	SVC 0
	MOV R4, R0 @ salva o descritor do arquivo.

	@sys_mmap2
	MOV R0, #0 @ NULL (SO escolhe o endereco)
	LDR R1, =pagelen
	LDR R1, [R1] @ tamanho da pagina de memoria
	MOV R2, #3 @ protecao leitura ou escrita
	MOV R3, #1 @ memoria compartilhada
	LDR R5, =gpioaddr @ endereco GPIO / 4096
	LDR R5, [R5] 
	MOV R7, #192 @sys_mmap2
	SVC 0
	MOV R8, R0
.endm

@ Preciso de uma função que seta o pino de saída em ALTO. recebe o pino como parametro
@SetPinGPIOHigh
.macro SetPinGPIOHigh pino
    
    sub sp, sp, #16
    str r2, [sp, #8]
    str r1, [sp, #0]

    ldr r1, =\pino
    ldr r1, [r1]
    
    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data
    
    bl labelPinHigh

    ldr r2, [sp, #8]
    ldr r1, [sp, #0]
    add sp, sp, #16
.endm

labelPinHigh:
@=======PUT PILHA
    sub sp, sp, #24
    str r0, [sp, #16]
    str r6, [sp, #0]
@=======PUT PILHA

    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @ Acessar pinos com deslocamento

    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser high
                                
    orr r6, r6, r0		@Somente o bit correspondente é setado como 1 e os outros não são alterados.
    str r6, [r8, r1]            @Carrega a configuração

@=======POP PILHA
    ldr r0, [sp, #16]
    ldr r6, [sp, #0]
    add sp, sp, #24
@=======POP PILHA

    bx lr


@ Preciso de uma função que seta o pino de saída em BAIXO. recebe o pino como parametro
@SetPinGPIOLow
.macro SetPinGPIOLow pino 
    sub sp, sp, #16
    str r1, [sp, #0]
    str r2, [sp, #8]

    ldr r1, =\pino		@ Offset do registrador data
    ldr r1, [r1] 		@ Carregando valor
    
    ldr r2, =\pino		@ Offset do registrador data
    add r2, #4	
    ldr r2, [r2] 		@ Carregando valor

    bl labelPinLow

    ldr r1, [sp, #0]
    ldr r2, [sp, #8]
    add sp, sp, #16

.endm

labelPinLow:
@=======PUT PILHA
    sub sp, sp, #16
    str r0, [sp, #0]
    str r6, [sp, #8]
@=======PUT PILHA

    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @Acessar pinos com deslocamento   

    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser low
                                
    bic r6, r6, r0		@Somente o bit correspondente é setado como 0 e os outros não são alterados.
    str r6, [r8, r1]            @Carrega a configuração
@=======POP PILHA
    ldr r0, [sp, #0]
    ldr r6, [sp, #8]
    add sp, sp, #16
@=======POP PILHA
    bx lr
    


@ Preciso de uma função que seta o pino como saída. recebe o pino como parametro
@setPinGPIOOut
.macro setPinGPIOOut pino
    sub sp, sp, #16
    str r2, [sp, #8]
    str r3, [sp, #0]

    ldr r2, =\pino 		@ Primeiro valor do .data do pino
    add r2, #8			@ Offset do registrador select
    ldr r2, [r2] 		@ Carrega o valor
    
    ldr r3, =\pino 		@ Primeiro valor do .data do pino
    add r3, #12			@ Offset do registrador select
    ldr r3, [r3] 		@ Carrega o valor

    bl labelPinOut

    ldr r3, [sp, #0]
    ldr r2, [sp, #8]
    add sp, sp, #16   

.endm

labelPinOut:
@=======PUT PILHA
    sub sp, sp, #16
    str r0, [sp, #8]
    str r1, [sp, #0]
@=======PUT PILHA
    add r2, #0x800		@ Adicionar o offset padrão do gpio
    
    ldr r1, [r8, r2] 		@ Valor no registrador select

    mov r0, #0b111 		@ Registrador a ser usado como máscara
    lsl r0, r3 			@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão)
    bic r1, r0 			@ Limpa os bits

    mov r0, #1 			@ 1 para deslocar e setar como 001(output)
    lsl r0, r3 			@ Deslocamento de acordo com o data do pino
    orr r1, r0 			@ Seta o bit como 1

    str r1, [r8, r2] 		@ Salva novamente no endereço
@=======POP PILHA
    ldr r0, [sp, #8]
    ldr r1, [sp, #0]
    add sp, sp, #16
@=======POP PILHA
    bx lr


@ Preciso de uma função que seta o pino como entrada. recebe o pino como parametro
@setPinGPIOIn
.macro setPinGPIOIn pino
    sub sp, sp, #16
    str r2, [sp, #0]
    str r3, [sp, #8]

    ldr r2, =\pino 		@ Primeiro valor do .data do pino
    add r2, #8			@ Offset do registrador select
    ldr r2, [r2] 		@ Carrega o valor
    
    ldr r3, =\pino 		@ Primeiro valor do .data do pino
    add r3, #12			@ Offset do registrador select
    ldr r3, [r3] 		@ Carrega o valor

    bl labelPinIn

    ldr r3, [sp, #8]
    ldr r2, [sp, #0]
    add sp, sp, #16   

.endm

labelPinIn:
@=======PUT PILHA
    sub sp, sp, #16
    str r0, [sp, #8]
    str r1, [sp, #0]
@=======PUT PILHA
    add r2, #0x800		@ Adicionar o offset padrão do gpio

    ldr r1, [r8, r2] 		@ Valor no registrador select

    mov r0, #0b111 		@ Registrador a ser usado como máscara
    lsl r0, r3 			@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão)
    bic r1, r0 			@ Limpa os bits 000(input)

    str r1, [r8, r2] 		@ Salva novamente no endereço

@=======POP PILHA
    ldr r0, [sp, #8]
    ldr r1, [sp, #0]
    add sp, sp, #16
@=======POP PILHA
    bx lr


.macro readPinGPIO pino

    sub sp, sp, #16
    str r1, [sp, #8]
    str r2, [sp, #0]

    
    ldr r1, =\pino		@ Offset do registrador data
    ldr r1, [r1] 		@ Carregando valor
    
	
    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data

    
    bl labelreadPin

    ldr r2, [sp, #8]
    ldr r1, [sp, #0]
    add sp, sp, #16

.endm

@ Retorna o valor lido no pino R0
labelreadPin:
@=======PUT PILHA
    sub sp, sp, #8
    str r6, [sp, #0]
@=======PUT PILHA

    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @ Acessar pinos com deslocamento
    
    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser lido
                                
    and r0, r6			@Somente o bit correspondente é setado como 1 se no reg também estiver como 1, ou zero caso contrário.
    lsr r0, r2			@Armazena em r0 o valor que está no pino

@=======POP PILHA
    ldr r6, [sp, #0]
    add sp, sp, #8
@=======POP PILHA
    bx lr
    
@ Preciso de uma função que seta o pino de saída para o valor passado (0 ou 1). Recebe o high ou low e recebe o id do pino
@setStatePinGPIO (Usando reg R3 para o pino e R4 para o high ou low)
setStatePinGPIO:

@=======PUT PILHA
    sub sp, sp, #32
    str r0, [sp, #24]
    str r1, [sp, #16]
    str r6, [sp, #8]
    str r7, [sp, #0]
@=======PUT PILHA

    mov r6, r3			@Copio o endereço do pino para r6
    ldr r6, [r6]

    add r6, #0x800		@ Adicionar o offset padrão do gpio
    ldr r7, [r8, r6]            @ Acessar pinos com deslocamento

    mov r1, r3
    add r1, #4			
    ldr r1, [r1]		@Deslocamento dentro do registrador data

    mov r0, r4			@Registrador pra servir como máscara

    cmp r0, #0      		@Compara o valor em r0 com zero
    beq setOff    		@Desvia para a operacao de se o valor a ser setado é 0 setOff
	
    lsl r0, r0, r1		@r0 tem 1 somente no bit que é para ser high                         
    orr r7, r7, r0		@Somente o bit correspondente é setado como 1 e os outros não são alterados.
	
    b end

    setOff:
    mov r0, #1
    lsl r0, r0, r1		@r0 tem 1 somente no bit que é para ser low                          
    bic r7, r7, r0		@Somente o bit correspondente é setado como 0 e os outros não são alterados.
	
    end:
    str r7, [r8, r6]    @Carrega a configuração

@=======POP PILHA
    ldr r0, [sp, #24]
    ldr r1, [sp, #16]
    ldr r6, [sp, #8]
    ldr r7, [sp, #0]
    add sp, sp, #32
@=======POP PILHA
    bx lr



/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
    Setando os pinos das chaves como entradas
    ------------------------------------------------
*/
.macro setIn
    setPinGPIOIn sh1
    setPinGPIOIn sh2
    setPinGPIOIn sh3
    setPinGPIOIn sh4
        @ Botões
    setPinGPIOIn bConfirm
    setPinGPIOIn bOk
    setPinGPIOIn bCancel
.endm



/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
    Setando os pinos que vão para o display como saída 
    ------------------------------------------------
*/
.macro setOut
	setPinGPIOOut db7
	setPinGPIOOut db6
	setPinGPIOOut db5
	setPinGPIOOut db4
	setPinGPIOOut E
	setPinGPIOOut RS
	setPinGPIOOut led @ Setando o led que é acionado em HIGH 
.endm

/* 
    ------------------------------------------------
            Label para auxiliar o debounce
    ------------------------------------------------
    r7 -> representa a informação se o botão foi pressionado (deve ser verificado logo após a chamada da macro do debounce) 
    Fluxo abaixo:
    Verifico o estado do pino
        - Se tiver pressionado
            - Dou sleep e verifico novamente
                - Se ainda estiver pressionado, retorno 1 e finalizo
                - Se não estiver pressionado, finalizo
        - Se não estiver pressionado, finalizo
*/
labelDebounce:
    sub sp, sp, #24
    str r1, [sp, #16]
    str r0, [sp, #8]
    str lr, [sp, #0]
    
    mov r7, #0 @ Estou dizendo que nenhum o botão não foi pressionado
    
    @ Faço a primeira leitura do bootão
    ldr r1, [sp, #16]
    bl labelreadPin @ Tenho o estado em r0
    cmp r0, #0 
    bne endDebounce @ Se eu não tiver acionado o botão, finalizo
    nanoSleep timeZero, time300ms 
    @ Faço a segunda leitura do bootão
    ldr r1, [sp, #16]
    bl labelreadPin @ Tenho o estado em r0
    cmp r0, #0 
    bne endDebounce @ Se eu não tiver acionado o botão, finalizo
    @ Se o botão ainda estiver acionado, fica em loop até soltar
    loopBounce:
    @ Faço mais uma leitura do bootão
    ldr r1, [sp, #16]
    bl labelreadPin @ Tenho o estado em r0
    cmp r0, #0 
    beq loopBounce @ Se o botão estiver acionado ainda, continuo no loop
    @ Se o botão tiver sido solto agora, significa que ele passou no teste e eu indico que a ação que depende dele deverá ocorrer
    mov r7, #1 
   
    endDebounce:
    ldr r0, [sp, #8]
    ldr lr, [sp, #0]
    add sp, sp, #24
    bx lr


.macro debouncePin pino

    sub sp, sp, #16
    str r1, [sp, #8]
    str r2, [sp, #0]

    @ ================================================================
    ldr r1, =\pino		@ Offset do registrador data
    ldr r1, [r1] 		@ Carregando valor
    
	
    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data

    @ ================================================================
    bl labelDebounce

    ldr r2, [sp, #8]
    ldr r1, [sp, #0]
    add sp, sp, #16

.endm



/* 
    ------------------------------------------------
        Realiza a leitura de todas as chaves juntas
    ------------------------------------------------
    r6 -> É onde está os valores da chaves (4bits)
*/
LER_CHAVES_GPIO:
    sub sp, sp, #16
    str lr, [sp, #8]
    str r0, [sp, #0]

    mov r6, #0
    
    readPinGPIO sh4@ Retorna o estado em R0
    eor r0, r0, #1 @ Inverte o valor em r0 já que a chave apresenta valor 0 quanndo acionada. Aí fica 1 no lugar
    lsl r0, #3
    add r6, r6, r0
    readPinGPIO sh3@ Retorna o estado em R0
    eor r0, r0, #1 @ Inverte o valor em r0 já que a chave apresenta valor 0 quanndo acionada. Aí fica 1 no lugar
    lsl r0, #2
    add r6, r6, r0
    readPinGPIO sh2@ Retorna o estado em R0
    eor r0, r0, #1 @ Inverte o valor em r0 já que a chave apresenta valor 0 quanndo acionada. Aí fica 1 no lugar
    lsl r0, #1
    add r6, r6, r0
    readPinGPIO sh1@ Retorna o estado em R0
    eor r0, r0, #1 @ Inverte o valor em r0 já que a chave apresenta valor 0 quanndo acionada. Aí fica 1 no lugar
    add r6, r6, r0

    ldr lr, [sp, #8]
    ldr r0, [sp, #0]
    add sp, sp, #16
    bx lr
    
