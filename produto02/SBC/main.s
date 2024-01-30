.include "utils.s"
.include "sleep.s"
.include "gpioNovo.s"
.include "display_lcd.s"
.include "telas.s"
.include "uart.s"

@ Chamar as funções do display
.global _start


_start:
@INICIALIZAÇÃO GERAL
	MemoryMap	
	setOut
	setIn

	initDisplay
	
	MemoryMapUart
	inicializarUART
	@bl resetFifo @@@@@@@@@@@@@@@

	@FIM DA INICIALIZAÇÃO GERAL
    	
    	@======== INICIALIZA AS TELAS
	bl TELA_INICIAL
	@mov r12, #1 @Comando
	@lsl r12, #8 
	@add r12, r12, #7 @ Adiciono o endereço
	@bl sendUart
    	@======== INICIALIZA AS TELAS
    	
    	
    	LOOP_PRINCIPAL:
	@ Verifico se chegou algo na uart
	bl isUartReceived
	cmp r1, #1
	
	@ Se tiver chego algo, exibo a tela correspondente
	BEQ EXIBE_RECEBIDO
	
	velBt:
	@ Se não tiver recebido algo eu verifico o botão
	debouncePin bOk
	cmp r7, #1
	
	@ Se o botão tiver sido pressionado, vou para a tela de comando
	BEQ TEL_COMANDO
	
	@ Se não estiver pressionado, volto refaço o processo
	b LOOP_PRINCIPAL

	TEL_COMANDO:
	    bl TELA_COMANDO_MAIS_EXTERNA
	    bl resetFifo @@@@@@@@@@@@@@@@@@@@@@@@@@@
	    @ Quando saio da tela, já devo enviar os dados pela UART
	    bl TELA_INICIAL
	    bl sendUart
	    b LOOP_PRINCIPAL

	EXIBE_RECEBIDO:
	    bl readUart
	    mov r12, r11
	    bl SELECAO_TELA
	    KKKK:
	    b velBt
    
	@Encerramento do programa
	MOV R0, #0
    	MOV R7, #1
    	SVC 0




.data 
	timeZero: 	.word	0 @ 0 Segundos
	time1ms: 	.word	1000000  @ 1 Milissegundo
	time3ms:	.word	3000000  @ 3 Milissegundos
	time5ms:	.word	5000000  @ 5 Milissegundos 
	time15ms:	.word 	15000000 @ 15 Milissegundos
	time100ms:	.word	100000000
	time150ms:	.word	150000000
	time300ms:	.word	300000000
	time800ms:  .word   800000000 @ 800 Milisegundos
	time150us:	.word	150000 @ 150 us
	time60us:	.word	60000 @ 150 us
	timespecnano:	.word 	1000000
	devmem: .asciz "/dev/mem"

	@ endereço de memória dos registradores do gpio / 4096
	gpioaddr: .word 0x1C20 @0x01C20800 / 0x1000 (4096) @Endereço base do GPIO / 0x1000

	uartaddr: .word 0x1C28 
	pagelen: .word 0x1000 @4096
	uart3:	.word 0x04 @rx e tx estão no mesmo offset
		.word 20 @tx
		.word 24 @rx

	@ Pinos precisam de 4 campos NESTA ORDEM: offset reg_data, offset dentro do reg_data, offset reg_select, offset dentro do reg_select
	db7: .word 0xE8 
		.word 7 
		.word 0xD8
		.word 28 
	db6: .word 0xE8 
		.word 6 
		.word 0xD8
		.word 24 
	db5: .word 0xE8 
		.word 9 
		.word 0xDC
		.word 4 
	db4: .word 0xE8 
		.word 8 
		.word 0xDC
		.word 0 
	E: .word 0x10 
		.word 18 
		.word 0x08
		.word 8 
	RS: .word 0x10 
		.word 2 
		.word 0x00
		.word 8
		@PA 10
		
	@Botões ficam em 1 e qnd apertados vão pra 0
	@PA7 
	bCancel: .word 0X10
	    .word 7
	    .word 0x00
	    .word 28
	@PA 10
	bOk: .word 0X10
	    .word 10
	    .word 0x04
	    .word 8
	@PA20
	bConfirm: .word 0X10
	    .word 20
	    .word 0x08
	    .word 16
	
	@PA3 
	sh1: .word 0X10
	    .word 3
	    .word 0x00
	    .word 12
	    
	@PA0
	sh2: .word 0X10
	    .word 0
	    .word 0x00
	    .word 0
	    
	@PA1 
	sh3: .word 0X10
	    .word 1
	    .word 0x00
	    .word 4
	    
	@PA6 
	sh4: .word 0X10
	    .word 6
	    .word 0x00
	    .word 24
	    
	led: .word 0x10
	.word 9
	.word 0x04
	.word 4 
