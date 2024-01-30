// ==================================================================================================================================================== //
// ============================================================BLOCO DE FUNÇÕES BASE=================================================================== //
// ==================================================================================================================================================== //




/* 
    ------------------------------------------------
            Define as configurações do display
    ------------------------------------------------
    Informa se os dados são transmitidos por 9 bits ou por 4 bits
    Informa se vou usar uma ou duas linhas
    Informa qual a fonte usada pelos caracteres, a menor (5x8) ou maior (5x10)
    !! Não dá para usar a fonte maior e ter duas linhas
*/ 
.macro FunctionSet
	SetPinGPIOLow RS
    @SetPinGPIOLow RW
    @@ Parte 1
	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOHigh db5
	SetPinGPIOLow db4 @ 1 para informar que os dados são mandados em 8bit e 0 para 4 bits
	enableDisplay @ db7-db4  0 0 1 0
    @@ Parte 2
	SetPinGPIOHigh db7 @ 1 para 2 linhas e 0 para uma linha
	SetPinGPIOLow db6 @ Fonte de caracters: 1 para 5x10 pontos e 0 para 5x8 pontos
	@SetPinGPIOHigh db5
	@SetPinGPIOLow db4
	enableDisplay @ db7-db4  1 1 x x
.endm

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    (os tempos que estão aqui devem estar em .data)
    ------------------------------------------------
        Informa ao display para executar a instrução
    ------------------------------------------------
    Dá o pulso de enable para o display observar os 4 bits
*/
.macro enableDisplay
    SetPinGPIOHigh E
    nanoSleep timeZero, time1ms
    SetPinGPIOLow E
    nanoSleep timeZero, time1ms @ Se não fuancionar, comenta aquite
.endm

/* 
    ------------------------------------------------
                Limpa a tela do display 
    ------------------------------------------------
    Coloca 0000 dá enable
    Coloca 0001 dá enable
*/
clearDisplay:
	sub sp, sp, #8
   	str lr, [sp, #0]

	SetPinGPIOLow RS
    @SetPinGPIOLow RW
    @ Parte 1
	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOLow db4
	enableDisplay
    @ Parte 2
	@SetPinGPIOLow db7
	@SetPinGPIOLow db6
	@SetPinGPIOLow db5
	SetPinGPIOHigh db4
	enableDisplay
	ldr lr, [sp, #0]
    add sp, sp, #8
	bx lr





/* 
    ------------------------------------------------
            Coloca o cursor na  posição 0
    ------------------------------------------------
*/
setInitialCursorPos:
	sub sp, sp, #8
   	str lr, [sp, #0]
   	
	SetPinGPIOLow RS
    @SetPinGPIOLow RW

	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOLow db4
	enableDisplay @ 0000

	@SetPinGPIOLow db7
	@SetPinGPIOLow db6
	SetPinGPIOHigh db5
	@SetPinGPIOLow db4
	enableDisplay @ 001x
	
	ldr lr, [sp, #0]
    add sp, sp, #8
	bx lr


/* 
    ------------------------------------------------
    Desloca posição do cursor para direita em 1 caracter
    ------------------------------------------------
*/ 
shiftRightCursor:
	sub sp, sp, #8
   	str lr, [sp, #0]
	SetPinGPIOLow RS
    @SetPinGPIOLow RW

	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOHigh db4
	enableDisplay @ 0001
	
	@SetPinGPIOLow db7 @ 0 para deslocar o cursor, 1 para a exibição/tela
	SetPinGPIOHigh db6 @ 1 para direita e 0 para esquerda
	@SetPinGPIOLow db5 
	@SetPinGPIOLow db4 
	enableDisplay @ 01xx

    ldr lr, [sp, #0]
    add sp, sp, #8
	bx lr
	.ltorg

/* 
    ------------------------------------------------
                Desliga o display
    ------------------------------------------------
*/ 
.macro DisplayOff
    @@@ Parte 1
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOLow db5
    SetPinGPIOLow db4
    enableDisplay
    @@@ Parte 2
    SetPinGPIOHigh db7
    SetPinGPIOLow db6 @ Desliga o display
    SetPinGPIOLow db5 @ Oculta o cursor
    SetPinGPIOLow db4 @ O carcter indicado pelo cursor não pisca
    enableDisplay
.endm


/* 
    ------------------------------------------------
                Liga o display
    ------------------------------------------------
*/ 
.macro DisplayOn
    @@@ Parte 1
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOLow db5
    SetPinGPIOLow db4
    enableDisplay
    @@@ Parte 2
    SetPinGPIOHigh db7
    SetPinGPIOHigh db6 @ liga o display
    SetPinGPIOHigh db5 @ exibe o cursor
    SetPinGPIOLow db4 @ O carcter indicado pelo cursor não pisca
    enableDisplay
.endm


/* 
    ------------------------------------------------
            Pula para a próxima linha
    ------------------------------------------------
    Se o cursor estiver na primeira linha, vai cair para a segunda linha (na primeira posição da linha)
*/ 
jumpLine:
	sub sp, sp, #8
   	str lr, [sp, #0]
	SetPinGPIOLow RS
    @@@ Parte 1 
	SetPinGPIOHigh db7
	SetPinGPIOHigh db6
	SetPinGPIOLow db5
	SetPinGPIOLow db4
	enableDisplay
    @@@ Parte 2 
	SetPinGPIOLow db7
	SetPinGPIOLow db6
	@SetPinGPIOLow db5 
	@SetPinGPIOLow db4  
	enableDisplay 
	
	ldr lr, [sp, #0]
    add sp, sp, #8
	bx lr
	.ltorg


/* 
    ------------------------------------------------
            Definindo o modo de entrada
    ------------------------------------------------
    Define que o cursor é deslocado para direita/esquerda sempre que escrever um carcter
    Define se o cursor será movimentado ou o display
*/ 
.macro EntryModeSet
	SetPinGPIOLow RS
    @SetPinGPIOLow RW
    @@@ Parte 1 
	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOLow db4
	enableDisplay
    @@@ Parte 2 
	@SetPinGPIOLow db7
	SetPinGPIOHigh db6
	SetPinGPIOHigh db5 @ 1 para direita e 0 para esquerda
	@SetPinGPIOLow db4  @ Move o cursor em vez da tela
	enableDisplay 
.endm


/* Macro para evitar trechos longos e repetidos de código na inicialização do LCD */
.macro FunctionSetParcial
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOHigh db5
    SetPinGPIOHigh db4
    enableDisplay
.endm


/*  
    ------------------------------------------------ 
    Inicializa o display, como sugere o datasheet 
    ------------------------------------------------
*/
.macro initDisplay
    nanoSleep timeZero, time100ms
    SetPinGPIOLow RS
    @SetPinGPIOLow RW

    FunctionSetParcial
    .ltorg
    nanoSleep timeZero, time5ms @ Aguarda por mais de 4.1ms

    FunctionSetParcial
    nanoSleep timeZero, time150us @ Aguarda por mais de 100us
    .ltorg 
    FunctionSetParcial
    nanoSleep timeZero, time150us @ Aguarda por mais de 100us
    @@@@@@@@@@@@@@@@@@@@@@ APÒS AQUI DEVO VER O BF @@@@@@@@@@@@@@@@@@@@@@

    @@@ FunctionSet !!(É esse o que vale)!! OK
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOHigh db5
    SetPinGPIOLow db4 @ Indica que os dados são de 4 em 4 bits
    .ltorg 
    enableDisplay
    nanoSleep timeZero, time150us @ Aguarda por mais de 100us
    
    
    FunctionSet
    nanoSleep timeZero, time60us @ Aguarda por mais de 100us
    
    DisplayOff
    nanoSleep timeZero, time60us @ Aguarda por mais de 100us
    
    bl clearDisplay
    nanoSleep timeZero, time3ms @ Aguarda por mais de 100us
    
    EntryModeSet
    nanoSleep timeZero, time60us @ Aguarda por mais de 100us
    @@@ O procedimento indicado acaba aqui @@@
    DisplayOn
    nanoSleep timeZero, time60us @ Aguarda por mais de 100us
    EntryModeSet
    .ltorg
.endm

// ==================================================================================================================================================== //
// ============================================================BLOCO DE FUNÇÕES PARA ESCREVER================================================================== //
// ==================================================================================================================================================== //

/* 
    ------------------------------------------------
                Escreve um caracter
    ------------------------------------------------
    Recebe um valor que corresponde ao caracter a ser exibido no reg R1. Por exemplo:
    01010100 para escrever o T
*/
WriteCharLCD:
 	sub sp, sp, #32
 	str r3, [sp, #24]
 	str r5, [sp, #16]
 	str r4, [sp, #8]
 	str lr, [sp,#0]

    MOV R5, R1 @ Parametro de mascara bit
    SetPinGPIOHigh RS

    @ Primeira parte dos dados
    MOV R6, #7 @ Informa qual o bit vou ler primeiro. Aqui estou vendo se o o bit 7 (da dir para esq) é 1 ou 0
    BL mascaraBit @ O valor vai estar em R3
    mov r4, r3
    @ # Informo que é o pino db7 no reg R3
    ldr R3, =db7 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg R4
    BL setStatePinGPIO

    MOV R6, #6
    BL mascaraBit
    mov r4, r3
    @ # Informo que é o pino db6
    ldr R3, =db6 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    MOV R6, #5
    BL mascaraBit
    mov r4, r3
    @ # Informo que é o pino db5
    ldr R3, =db5 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    MOV R6, #4
    BL mascaraBit
    mov r4, r3
    @ # Informo que é o pino db4
    ldr R3, =db4 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    enableDisplay

    @ Segunda parte dos dados
    MOV R6, #3
    BL mascaraBit
    mov r4, r3
    @ # Informo que é o pino db7
    ldr R3, =db7 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    MOV R6, #2
    BL mascaraBit
    mov r4, r3
    @ # Informo que é o pino db6
    ldr R3, =db6 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    MOV R6, #1
    BL mascaraBit
    mov r4, r3
    @ # Informo que é o pino db5
    ldr R3, =db5 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO @ Faz a mudança de estado do pino

    MOV R6, #0
    BL mascaraBit
    mov r4, r3
    @ # Informo que é o pino db4
    ldr R3, =db4 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    enableDisplay
    
    ldr lr, [sp, #0]
    ldr r5, [sp, #16]
    ldr r3, [sp, #24]
    ldr r4, [sp, #8]
 	add sp, sp, #32
    bx lr


/* 
    ------------------------------------------------
            Escreve um dígito numérico no lcd
    ------------------------------------------------
    Recebe um valor que corresponde ao número a ser exibido no reg R1. Por exemplo:
    0001 para escrever o 1
*/
 WriteNumberLCD:
 	sub sp, sp, #8
 	str lr, [sp,#0]
 	
 	add R1, R1, #48
 	
 	bl WriteCharLCD
 	
 	ldr lr, [sp, #0]
 	add sp, sp, #8
 	
 	bx lr

