// Cortex-M3 Devices Generic User Guide: https://developer.arm.com/documentation/dui0552/
// STM32f103xx Family Reference Manual: https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf
// STM32f103c8 Datasheet: https://www.st.com/resource/en/datasheet/stm32f103c8.pdf
// Procedure Call Standard for the Arm Architecture: https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm
.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.set Pin__puerto,0
.set Pin__numero,4

defun Pin_init
    // R0: self, R1: puerto, R2: numPin
    str R1,[R0,#Pin__puerto]
    str R2,[R0,#Pin__numero]
    bx lr
endfun Pin_init

.set CRL,0x00
.set CRH,0x04
.set IDR,0x08
.set ODR,0x0C
.set BSRR,0x10
.set BRR,0x14

defun Pin_configura

    push {R4,R5,R6,LR}
    ands R2, R1, #0xF
    cmp R2, #8
    bne 0f
    push {R0,R1}
    lsrs R1,#4
    bl Pin_escribe
    pop {R0,R1}

0: 
    ldr R2,[R0,#Pin__puerto]
    ldr R3,[R0,#Pin__numero]
    cmp R3,#7
    bls 0f
    mov R5, #8
    mov R0, #CRH
    b 1f

0:
    mov R0, #CRL
    mov R5, #0

1:
    ldr R6,[R2, R0] 
    subs R3, R5 
    lsls R3,#2 
    movs R4,#0xF 
    lsls R4, R3 
    bics R6, R4  
    ands R1, #0xF
    lsls R1, R3 
    orrs R6, R1 
    str R6, [R2,R0] 
    pop {R4,R5,R6,PC}
    
endfun Pin_configura



defun Pin_escribe

    ldr R2,[R0,#Pin__puerto]
    ldr R3,[R0,#Pin__numero]
    movs R0,#1  
    lsls R0,R3 
    cbz R1, 0f 
    b 1f

0:

    str R0,[R2,#BRR]   
1:

    str R0,[R2, #BSRR]   
     bx lr
endfun Pin_escribe


defun Pin_lee
    
    ldr R1,[R0,#Pin__puerto]
   
    ldr R2,[R0,#Pin__numero]
   
    mov R3, #1 //asigno 1 a R3
    
    lsls R3, R2 //asigno R3 a R2, que es el pin que leeremos
   
    ldr R0, [R1, #IDR] //(R1 + #IDR) representa la entrada con la que estamos trabajando, y la guardamos en R0
   
    tst R0, R3 // Luego comparo si R0 es igual a R3, si es asi, salto a 0f
   
    beq 1f

    mov R0, #1 //Y bueno , si llegase a ser "0" el valor de esa entrada, entonces lo cambio a "1"

    b 0f //Salto al final del programa
1:

    mov R0, #0
    
0:

bx lr
     
endfun Pin_lee





defun Pin_leeSalida


    ldr R1,[R0,#Pin__puerto]

    ldr R2,[R0,#Pin__numero]

    mov R3, #1 //asigno 1 a R3

    lsls R3, R2 //asigno R3 al numero de pin de trabajo

    ldr R0,[R1, #ODR] //(R1 + #ODR) representa el valor de salida del pin de trabajo, el cual guardo en R0

    tst R0, R3  // Ahora controlo si R0 es 1

    beq 1f  

    mov R0, #1

    b 0f
1:

    mov R0,#0 

0:

    bx lr

endfun Pin_leeSalida
