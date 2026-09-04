; PRÁTICA 02 - MICROPROCESSADORES
; DESCRIÇÃO: Multiplexador 4:1
; COMPILADOR: pic-as v3.10
; MPLABX v6.20
; MICROCONTROLADOR: PIC18F4520
; DISCIPLINA: MICROPROCESSADORES

; Hardware Pin Out (PIC18F4520)
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
;           VDD --| 11  30 |<< RD7 (E4)
;           VSS --| 12  29 |<< RD6 (E3)
;      OSC1/RA7 --| 13  28 |<< RD5 (E2)
;      OSC2/RA6 --| 14  27 |<< RD4 (E1)
;           RC0 --| 15  26 |-- RC7/RX
;           RC1 --| 16  25 |-- RC6/TX
;           RC2 --| 17  24 |-- RC5
;           RC3 --| 18  23 |-- RC4
;           RD0 --| 19  22 |<< RD3 (S1)
;   (Saída) RD1 <<| 20  21 |<< RD2 (S2)
;                  --------

; PIC18F4520 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1H
  CONFIG  OSC = HS              ; Oscillator Selection bits (HS oscillator)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
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

// config statements should precede project file includes.
#include <xc.inc>

#define _XTAL_FREQ 4000000

; vetor de reset
PSECT resetVec,class=CODE,reloc=2,abs,ovrld

org 0x0000

resetVec:
    GOTO start

#define MUX_OUT_1 LATD,1
#define MUX_SEL_2 PORTD,2
#define MUX_SEL_1 PORTD,3
#define MUX_IN_4 PORTD,7
#define MUX_IN_3 PORTD,6
#define MUX_IN_2 PORTD,5
#define MUX_IN_1 PORTD,4

PSECT code,class=CODE,reloc=2

start:
    CLRF LATD
    CLRF PORTD
    BCF MUX_OUT_1
    ; TODO
    ; Configure as entradas e saídas

main:
    BTFSC MUX_SEL_2
    BRA mux34

; Para S2,S1 = 0,X
mux12:
    BTFSC MUX_SEL_1
    BRA mux_in2

; Para S2,S1 = 0,0
mux_in1:
    BTFSC MUX_IN_1
    BRA mux_set
    BRA mux_reset

; Para S2,S1 = 0,1
mux_in2:
    BTFSC MUX_IN_2
    BRA mux_set
    BRA mux_reset

; Para S2,S1 = 1,X
mux34:
    BTFSC MUX_SEL_1
    BRA mux_in4

; Para S2,S1 = 1,0
mux_in3:
    BTFSC MUX_IN_3
    BRA mux_set
    BRA mux_reset

; Para S2,S1 = 1,1
mux_in4:
    BTFSC MUX_IN_4
    BRA mux_set
    BRA mux_reset

; Saída 1
mux_set:
; TODO
; configure uma rotina para a saída do mux igual a 1
; depois retorne à rotina principal

; Saída 0
mux_reset:
; TODO
; configure uma rotina para a saída do mux igual a 0
; depois retorne à rotina principal

END resetVec

