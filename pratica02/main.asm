; ======================================================================
; Universidade Federal do Ceará - Campus de Sobral
; Disciplina: Microprocessadores
; Curso: Engenharia Elétrica / Engenharia de Computação
; Semestre: 2026.2
; ======================================================================

LIST      P=18F4520, F=INHX32
INCLUDE   "p18f4520.inc"

 ; Hardware Pin Out
 ;                  --------
 ;    MRCLR'/RE3 --| 1   40 |-- RB7/PGD
 ;       RA0/AN0 --| 2   39 |-- RB6/PGC
 ;       RA1/AN1 --| 3   38 |-- RB5
 ;       RA2/AN2 --| 4   37 |-- RB4
 ;       RA3/AN3 --| 5   36 |-- RB3/PGM
 ;           RA4 --| 6   35 |-- RB2
 ;       RA5/AN4 --| 7   34 |<< RB1 (E)
 ;       RE0/AN5 --| 8   33 |<< RB0 (RS)
 ;       RE1/AN6 --| 9   32 |-- VDD
 ;       RE2/AN7 --| 10  31 |-- VSS
 ;           VDD --| 11  30 |<< RD7
 ;           VSS --| 12  29 |<< RD6
 ;      OSC1/RA7 --| 13  28 |<< RD5
 ;      OSC2/RA6 --| 14  27 |<< RD4
 ;           RC0 --| 15  26 |-- RC7/RX
 ;           RC1 --| 16  25 |-- RC6/TX
 ;           RC2 --| 17  24 |-- RC5
 ;           RC3 --| 18  23 |-- RC4
 ;           RD0 >>| 19  22 |<< RD3
 ;           RD1 >>| 20  21 |<< RD2
 ;                  --------
 ;

; =====================================================================
; CONEXÕES (MONTAGEM FÍSICA)
; =====================================================================
; LCD pino  1 (VSS) -> GND
; LCD pino  2 (VDD) -> +5 V
; LCD pino  3 (VEE) -> cursor do potenciômetro de 10k (5 V/GND)
; LCD pino  4 (RS)  -> RB0 do PIC (pino físico 33)
; LCD pino  5 (RW)  -> GND
; LCD pino  6 (E)   -> RB1 do PIC (pino físico 34)
; LCD pino  7 (D0)  -> RD0 do PIC
; LCD pino  8 (D1)  -> RD1 do PIC
; LCD pino  9 (D2)  -> RD2 do PIC
; LCD pino 10 (D3)  -> RD3 do PIC
; LCD pino 11 (D4)  -> RD4 do PIC
; LCD pino 12 (D5)  -> RD5 do PIC
; LCD pino 13 (D6)  -> RD6 do PIC
; LCD pino 14 (D7)  -> RD7 do PIC
;
; Cristal de 4 MHz entre OSC1 e OSC2, com capacitores de 22pF pra GND.
; MCLR (pino 1 do PIC) puxado para +5 V via resistor de 10k.

; IMPORTANTE: O código assume:
;   RS = RB0
;   EN = RB1
;   RW = GND (escrita apenas)
;   D0..D7 = RD0..RD7
; =====================================================================

; ---------------------------------------------------------------------
; CONFIG BITS
; ---------------------------------------------------------------------
CONFIG  OSC = XT          ; Oscilador externo tipo XT (cristal ~4 MHz)
CONFIG  FCMEN = OFF       ; Fail-Safe Clock Monitor desabilitado
CONFIG  IESO = OFF        ; Sem troca INT/EXT automática

CONFIG  PWRT = OFF        ; Power-up Timer OFF
CONFIG  BOREN = SBORDIS   ; Brown-out Reset hardware only
CONFIG  BORV = 3          ; Nível de Brown-out

CONFIG  WDT = OFF         ; Watchdog Timer OFF
CONFIG  WDTPS = 32768     ; Pós-escalonador do WDT (irrelevante com WDT OFF)

CONFIG  CCP2MX = PORTC    ; CCP2 em RC1
CONFIG  PBADEN = OFF      ; PORTB<4:0> digitais após reset
CONFIG  LPT1OSC = OFF
CONFIG  MCLRE = ON        ; /MCLR habilitado (reset externo ativo em RE3/MCLR)

CONFIG  STVREN = ON       ; Reset em stack overflow/underflow
CONFIG  LVP = OFF         ; Desativa programação em baixa tensão (libera RB5)
CONFIG  XINST = OFF       ; Conjunto estendido de instruções OFF
CONFIG  DEBUG = OFF       ; Debug OFF

; ---------------------------------------------------------------------
; DEFINIÇÕES DE PINOS DO LCD
; ---------------------------------------------------------------------
LCD_RS      EQU     0         ; RB0 -> RS
LCD_EN      EQU     1         ; RB1 -> EN

; ---------------------------------------------------------------------
; VARIÁVEIS
; ---------------------------------------------------------------------
CBLOCK  0x20
    d0          ; contador de delay grosso
    d1          ; contador interno de delay
ENDC

; ---------------------------------------------------------------------
; VETOR DE RESET
; ---------------------------------------------------------------------
ORG     0x0000
GOTO    START

; ---------------------------------------------------------------------
; DELAYS
; ---------------------------------------------------------------------

; Delay curto (centenas de microssegundos @4MHz, aproximado)
DelayShort:
    MOVLW   0xFF
    MOVWF   d1, ACCESS
DelayShortLoop:
    DECFSZ  d1, F, ACCESS
    BRA     DelayShortLoop
    RETURN

; Delay longo (~alguns ms) chamando vários DelayShort
DelayLong:
    MOVLW   0x04
    MOVWF   d0, ACCESS
DelayLongLoop:
    CALL    DelayShort
    DECFSZ  d0, F, ACCESS
    BRA     DelayLongLoop
    RETURN

; ---------------------------------------------------------------------
; ROTINAS DE LCD
; ---------------------------------------------------------------------

; Gera pulso no pino EN do LCD.
; Pré-condição: LATD já tem o byte e RS já está ajustado em LATB.
LCD_PulseEN:
    BSF     LATB, LCD_EN, ACCESS   ; EN = 1
    CALL    DelayShort
    BCF     LATB, LCD_EN, ACCESS   ; EN = 0
    CALL    DelayShort
    RETURN

; Envia comando (RS=0). WREG contém o comando (ex: 0x01 = clear).
LCD_Command:
    MOVWF   LATD, ACCESS           ; LATD <- comando
    BCF     LATB, LCD_RS, ACCESS   ; RS = 0 (comando)
    CALL    LCD_PulseEN
    CALL    DelayLong              ; tempo pro LCD executar
    RETURN

; Envia dado (caractere ASCII) (RS=1). WREG contém o caractere.
LCD_Data:
    MOVWF   LATD, ACCESS           ; LATD <- caractere ASCII
    BSF     LATB, LCD_RS, ACCESS   ; RS = 1 (dado)
    CALL    LCD_PulseEN
    CALL    DelayShort
    RETURN

; Inicialização padrão HD44780 em 8 bits.
; 0x38: interface 8 bits, 2 linhas, fonte 5x8
; 0x0C: display ON, cursor OFF, blink OFF
; 0x01: clear display
; 0x06: entry mode, cursor avança
LCD_Init:
    CALL    DelayLong
    CALL    DelayLong          ; atraso inicial pós-power-up

    MOVLW   0x38               ; Function Set
    CALL    LCD_Command

    MOVLW   0x0C               ; Display ON, cursor OFF, blink OFF
    CALL    LCD_Command

    MOVLW   0x01               ; Clear display
    CALL    LCD_Command

    MOVLW   0x06               ; Entry mode: cursor incrementa
    CALL    LCD_Command

    RETURN

; Cursor no início da linha 1.
; Linha 1 = DDRAM addr 0x00 -> comando 0x80
LCD_SetLine1:
    MOVLW   0x80
    CALL    LCD_Command
    RETURN

; Cursor no início da linha 2.
; Linha 2 = DDRAM addr 0x40 -> comando 0xC0
LCD_SetLine2:
    MOVLW   0xC0
    CALL    LCD_Command
    RETURN

; Imprime string ROM terminada em 0x00.
; Supõe TBLPTR apontando para o 1º caractere da string.
LCD_PrintString:
NextChar:
    TBLRD*+                     ; TABLAT <- [TBLPTR], TBLPTR++
    MOVF    TABLAT, W, ACCESS   ; W = caractere lido
    BNZ     SendChar            ; se W != 0x00, imprime
    RETURN                      ; se W == 0x00, acabou a string

SendChar:
    CALL    LCD_Data            ; manda caractere em W
    BRA     NextChar

; ---------------------------------------------------------------------
; PROGRAMA PRINCIPAL
; ---------------------------------------------------------------------
START:
    ; Desativa interrupções globais
    CLRF    INTCON, ACCESS

    ; Força PORTA/PORTB digitais
    MOVLW   0x0F
    MOVWF   ADCON1, ACCESS

    ; Zera as saídas antes de configurar TRIS
    CLRF    LATB, ACCESS
    CLRF    LATD, ACCESS

    ; PORTB como saída (RB0=RS, RB1=EN, etc.)
    MOVLW   0x00
    MOVWF   TRISB, ACCESS       ; RB7..RB0 = 0 -> saída

    ; PORTD como saída (D0..D7 do LCD)
    MOVLW   0x00
    MOVWF   TRISD, ACCESS       ; RD7..RD0 = 0 -> saída

    ; Inicializa LCD
    CALL    LCD_Init

    ; ===== Linha 1 =====
    CALL    LCD_SetLine1

    ; Carrega TBLPTR para MsgLinha1
    MOVLW   HIGH(MsgLinha1)
    MOVWF   TBLPTRH, ACCESS
    MOVLW   UPPER(MsgLinha1)
    MOVWF   TBLPTRU, ACCESS
    MOVLW   LOW(MsgLinha1)
    MOVWF   TBLPTRL, ACCESS

    CALL    LCD_PrintString

    ; ===== Linha 2 =====
    CALL    LCD_SetLine2

    ; Carrega TBLPTR para MsgLinha2
    MOVLW   HIGH(MsgLinha2)
    MOVWF   TBLPTRH, ACCESS
    MOVLW   UPPER(MsgLinha2)
    MOVWF   TBLPTRU, ACCESS
    MOVLW   LOW(MsgLinha2)
    MOVWF   TBLPTRL, ACCESS

    CALL    LCD_PrintString

MainLoop:
    BRA     MainLoop            ; loop infinito

; ---------------------------------------------------------------------
; STRINGS EM FLASH (terminadas com 0x00)
; colocadas depois do código inicial pra não causar problema
; no vetor de reset
; ---------------------------------------------------------------------
    ORG     0x300

MsgLinha1:
    DB      "- MICROS -",0x00
MsgLinha2:
    DB      "2026.2",0x00

; ---------------------------------------------------------------------
; END OF FILE
; ---------------------------------------------------------------------
END

