/*
    ------------------------------------------------
      Realiza uma chamada ao sistema para o dormir
    ------------------------------------------------

Coloca o tempo em segundos para dormir r0 e em nano segundos em r1. 
O tempo total de sleep é r0(segundos) + r1(nano segundos).
*/
.macro nanoSleep timesec timenano
    ldr r0, =\timespecsec   @ Lê o valor em que está na memória e diz para dormir por x segundos
    ldr r1, =\timenano      @ Diz para iniciar o sleep assim que receber a interrupção
    mov r7, #162    @ #sys_nanosleep = 162 é o valor que precisa estar em r7 para o SO entender que se trata de um sleep
    svc 0
.endm


??????? Pq não passar o valor como imediato  logo direto pro nanoSleep ?????????