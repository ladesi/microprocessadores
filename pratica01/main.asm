; PRÁTICA 01 - MICROPROCESSADORES
; DOCENTE: MARCELO MARQUES
; DISCIPLINA: MICROPROCESSADORES

 ; Hardware Pin Out
 ;                  --------
 ;    MRCLR'/RE3 --| 1   40 |-- RB7/PGD
 ;       RA0/AN0 --| 2   39 |-- RB6/PGC
 ;       RA1/AN1 --| 3   38 |-- RB5
 ;       RA2/AN2 --| 4   37 |>> RB4 (led)
 ;       RA3/AN3 --| 5   36 |-- RB3/PGM
 ;           RA4 --| 6   35 |-- RB2
 ;       RA5/AN4 --| 7   34 |-- RB1
 ;       RE0/AN5 --| 8   33 |-- RB0/INT
 ;       RE1/AN6 --| 9   32 |-- VDD
 ;       RE2/AN7 --| 10  31 |-- VSS
 ;           VDD --| 11  30 |-- RD7
 ;           VSS --| 12  29 |-- RD6
 ;      OSC1/RA7 --| 13  28 |-- RD5
 ;      OSC2/RA6 --| 14  27 |-- RD4
 ;           RC0 --| 15  26 |-- RC7/RX
 ;           RC1 --| 16  25 |-- RC6/TX
 ;           RC2 --| 17  24 |-- RC5
 ;           RC3 --| 18  23 |-- RC4
 ;           RD0 --| 19  22 |-- RD3
 ;           RD1 --| 20  21 |-- RD2
 ;                  --------
 ;

; PIC18F4520 Configuration Bit Settings

; Assembly source line config statements

#include "p18f4520.inc"

; CONFIG1H
  CONFIG  OSC = HS              ; Oscillator Selection bits (HS oscillator)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)

VARIAVEIS UDATA_ACS 0
  CONTA2m   RES 1 ; Variavel auxiliar para contagem de 2 ms
  CONTA500m RES 1 ; Variavel auxiliar para contagem de 500 ms

RES_VECT  CODE    0x0000 ; processor reset vector
  GOTO    START          ; go to beginning of program

MAIN_PROG CODE ; let linker place main program

START
    MOVLW b'11101101'; Configura RB4 como saida e demais como entrada
    MOVWF TRISD
APAGA
    BSF PORTD,1      ; Apaga o Led
    ;BCF PORTD,1
LOOP
    BTFSS PORTD,7    ; Verifica estado de SW1
    GOTO APAGA       ; Se SW1 não estiver pressionada apaga o led
    BCF PORTD,1      ; Caso contrário acende o led
  ;  BCF PORTD,1
    CALL ATRASO_500ms; Espera 500 ms
    ;CALL ATRASO_500ms ; Espera 500 ms
    ;CALL ATRASO_500ms ; Espera 500 ms
    BSF PORTD,1      ; Apaga o Led
   ; BSF PORTD,1
    CALL ATRASO_500ms; Espera 500 ms
   ; CALL ATRASO_500ms; Espera 500 ms
   ; CALL ATRASO_500ms; Espera 500 ms
    GOTO LOOP        ; reinicia o processo

 ATRASO_2ms       ; Subrotina que gera atraso de 2 ms
    MOVLW .152
    MOVWF CONTA2m ; Carrega contador para 200 interações
REPETE2           ; Inicio do loop
    NOP           ; 10 NOPs -> 10 us
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ CONTA2m
    GOTO REPETE2  ; Repete interações até que CONTA2 = 0
    RETURN

ATRASO_500ms ; Subrotina que gera atraso de 500 ms
    MOVLW .250
    MOVWF CONTA500m ; Carrega contador para 250 interações
REPETE_500   ; Inicio d92o loop
    CALL ATRASO_2ms ; Espera 2 ms
    DECFSZ CONTA500m
    GOTO REPETE_500 ; Repete interações até que CONTA500 = 0
    RETURN

    END

