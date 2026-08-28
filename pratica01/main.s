; PRÁTICA 01 - MICROPROCESSADORES
; COMPILADOR: pic-as v3.10
; MPLABX v6.20
; DISCIPLINA: MICROPROCESSADORES

 ; Hardware Pin Out
 ;                  --------
 ;    MRCLR'/RE3 --| 1   40 |-- RB7/PGD
 ;       RA0/AN0 --| 2   39 |-- RB6/PGC
 ;       RA1/AN1 --| 3   38 |-- RB5
 ;       RA2/AN2 --| 4   37 |-- RB4
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
 ;    (LED)  RD1 <<| 20  21 |-- RD2
 ;                  --------
 ;

PROCESSOR 18F4520

; CONFIG1H
  CONFIG  OSC = HS
  CONFIG  FCMEN = OFF
  CONFIG  IESO = OFF

; CONFIG2L
  CONFIG  PWRT = OFF
  CONFIG  BOREN = SBORDIS
  CONFIG  BORV = 3

; CONFIG2H
  CONFIG  WDT = OFF
  CONFIG  WDTPS = 32768

; CONFIG3H
  CONFIG  CCP2MX = PORTC
  CONFIG  PBADEN = ON
  CONFIG  LPT1OSC = OFF
  CONFIG  MCLRE = ON

; CONFIG4L
  CONFIG  STVREN = ON
  CONFIG  LVP = OFF
  CONFIG  XINST = OFF

; CONFIG5L
  CONFIG  CP0 = OFF
  CONFIG  CP1 = OFF
  CONFIG  CP2 = OFF
  CONFIG  CP3 = OFF

; CONFIG5H
  CONFIG  CPB = OFF
  CONFIG  CPD = OFF

; CONFIG6L
  CONFIG  WRT0 = OFF
  CONFIG  WRT1 = OFF
  CONFIG  WRT2 = OFF
  CONFIG  WRT3 = OFF

; CONFIG6H
  CONFIG  WRTC = OFF
  CONFIG  WRTB = OFF
  CONFIG  WRTD = OFF

; CONFIG7L
  CONFIG  EBTR0 = OFF
  CONFIG  EBTR1 = OFF
  CONFIG  EBTR2 = OFF
  CONFIG  EBTR3 = OFF

; CONFIG7H
  CONFIG  EBTRB = OFF

#include <xc.inc>

; cristal externo (1 ciclo de instrução ~ 1us)
#define _XTAL_FREQ 4000000

; variáveis no access RAM
PSECT udata_acs
VAR_AUX1: DS 1 ; 1 byte
VAR_AUX2: DS 1 ; 1 byte

; vetor de reset
PSECT resetVec,class=CODE,delta=2

resetVec:
    goto start

; LED definido em RD1
#define LED LATD,1

; main
PSECT code

start:
    ; RD1 como saída
    BANKSEL TRISD
    MOVLW 11111101B
    MOVWF TRISD

    ; inicializa LATD com 0x00
    BANKSEL LATD
    MOVLW 00000000B
    MOVWF LATD

loop:
    ; Acende o LED
    BANKSEL LATD
    BCF LED

    CALL delay_500ms

    ; Apaga o LED
    BANKSEL LATD
    BSF LED

    CALL delay_500ms

    GOTO loop

delay_500ms:
    ; seleciona o banco correto
    BANKSEL VAR_AUX1

    ; VAR_AUX1 = 250
    MOVLW 250
    MOVWF VAR_AUX1

delay1:
    ; VAR_AUX2 = 154
    MOVLW 154
    MOVWF VAR_AUX2

delay2:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    ; 10 NOP = 10us

    ; decremento com salto se VAR_AUX2 = 0 (153 vezes)
    DECFSZ VAR_AUX2,1
    GOTO delay2
    ; 3us

    ; decremento com salto se VAR_AUX1 = 0 (249 vezes)
    DECFSZ VAR_AUX1,1
    GOTO delay1

    RETURN
    ; t ~ (250 X 13 X 154) x 10^-6 s

END resetVec

