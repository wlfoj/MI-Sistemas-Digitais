/*  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
      Realiza uma chamada ao sistema para o dormir
    ------------------------------------------------
    Recebe dois endereços do .data como parâmetro
*/
.macro nanoSleep timesec timenano
    ldr r0, =\timesec   @ COLOCA AQUI OQ ESSE CARA FAZ
    ldr r1, =\timenano      @ COLOCA AQUI OQ ESSE CARA FAZ
    mov r7, #162    @ #sys_nanosleep = 162 é o valor que precisa estar em r7 para o SO entender que se trata de um sleep
    svc 0
.endm
