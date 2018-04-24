RYGR equ 0x10
counter equ 0x11
counter_s equ 0x14
counter_h equ 0x15
counter_dh0 equ 0x16
counter_dh1 equ 0x17
R0 equ 0x18 ;DISPLAY input reg

; counter_s -> counter_h repeats (30, 5, 30, 5, 30, 5, ...)

org 0x000
goto main
;our timer interrupt handler
org 0x0008
goto hi_isr
;cannonfodder
org 0x0018
goto low_isr

main:
  movlw 30
  movwf counter
  movwf counter_h
  movlw 5
  movwf counter_s

  ;set color bit
  movlw b'00000001'
  movwf RYGR

  ;timer on, prescaler to 1:4, internal 4MHz osc
  movlw b'10000001'
  movwf T0CON

  ;global interrupt on, timer 0 IE on
  bsf INTCON, 7
  bsf INTCON, 5

  ;Lights at PORTD 0, 1, 2
  ;Counter0 at PORTB<0,7> [counts 1's]
  ;Counter1 at PORTC<0,7> [counts 10's]
  ;Counter selector at PORTD 3, 4
  clrf TRISB
  clrf PORTB
  clrf TRISC
  clrf PORTC
  bcf  TRISD, 0
  bcf  TRISD, 1
  bcf  TRISD, 2
  bcf  TRISD, 3
  bcf  TRISD, 4
main_loop:
  call DISPLAY_COUNTER
  movff RYGB, PORTC ;TODO: Don't overwrite bits that you don't own
  goto main_loop

DISPLAY_COUNTER:
    movlw 10
    ;if counter is less than 10, just DISPLAY it
    cmpslt counter
    goto DISPLAY_COUNTER_multidigit
    movff counter, R0
    call DISPLAY
    return
  DISPLAY_COUNTER_multidigit:
    movff counter, counter_dh0
    clrf counter_dh1
  DISPLAY_COUNTER_multidigit_s:
    movlw 10
    cmpslt counter_dh0
    goto DISPLAY_COUNTER_multidigit_divided
    subwf counter_dh0
    incf counter_dh1
    goto DISPLAY_COUNTER_multidigit_s
  DISPLAY_COUNTER_multidigit_divided:
    ;select Counter 0, display the tens
    bsf PORTD, 3
    bcf PORTD, 4
    movff counter_dh1, R0
    call DISPLAY
    ;select Counter 1, display the ones
    bsf PORTD, 4
    bcf PORTD, 3
    movff counter_dh0, R0
    call DISPLAY

    return

low_isr:
  ;ignore low priority interrupts
  nop
  retfie

hi_isr:
  ;if not a timer interrupt, go out
  btfss INTCON, TMR0IF
  goto end_int

  ;reset IF
  bcf INTCON, TMR0IF

  ;no real bother if counter isn't 0
  decfsz counter
  goto end_int

  ;counter reached zero, swap counter_s, counter_h; set counter to next stage's value
  movf counter_s, WREG
  movff counter_h, counter_s
  movwf counter
  movwf counter_h

  ;transition to next stage (color)
  rlncf RYGR
  btfss RYGR, 3 ;if fourth bit is set, we overflow on colors. rotate once, swapf
  retfie

  rlncf RYGR
  swapf RYGR
end_int:
  retfie
