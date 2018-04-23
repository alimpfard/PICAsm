ax equ 0x10
bx equ 0x11
cx equ 0x12

t0_s equ 0x13
t0_h equ 0x14
t0_hh equ 0x15

org 0x000
goto main

org 0x0008
goto isr_hi

org 0x0018
goto isr_lo

main:
  bcf TRISB, 0
  bcf PORTB, 0
  ;call setup_part_a ;50% duty cycle
  ;call setup_part_b ;30% duty cycle
  movlw 4
  movwf ax, f
  call setup_part_c  ;(ax/10)% duty cycle
main_loop:
  call writesig
  goto main_loop

setup_part_a:
  movlw 5
  movwf ax, f
  call setup_part_c
  return

setup_part_b:
  movlw 3
  movwf ax, f
  call setup_part_c
  return

scale_argm:
  movlw 1
  cmpfsgt ax
  retlw 2
  ;
  movlw 2
  cmpsgt ax
  retlw 3
  ;
  movlw 3
  cmpsgt ax
  retlw 5
  ;
  movlw 4
  cmpsgt ax
  retlw 6
  ;
  movlw 5
  cmpsgt ax
  retlw 8
  ;
  movlw 6
  cmpsgt ax
  retlw 9
  ;
  movlw 7
  cmpsgt ax
  retlw 11
  ;
  movlw 8
  cmpsgt ax
  retlw 12
  ;
  movlw 9
  cmpsgt ax
  retlw 13
  ;
  movlw 10
  cmpsgt ax
  retlw 15
  ;

setup_part_c:
  ;set timer 0 to interrupt every 1ms (1 KHz freq) (prescaler = 110, initial=255-16) 16 units for 1KHz.
  ;on interrupt, switch between 1ms and 1ms*[ax]/10 delay, toggle on interrupt
  movlw 251
  movwf TMR0L
  movwf t0_h
  movlw 255
  movwf t0_hh
  call scale_argm
  ;255 - scaled(ax) -> t0_s
  subwf t0_hh, f
  movff t0_hh, t0_s
  
  movlw b'11000011'
  movwf T0CON
  ;global interrupt on, timer 0 IE on
  bsf INTCON, 7
  bsf INTCON, 5
  return

isr_lo:
  nop
  retfie

isr_hi:
  ;if not a timer interrupt, go out
  btfss INTCON, TMR0IF
  goto end_int

  ;reset IF
  bcf INTCON, TMR0IF

  ;toggle output
  btg PORTB, 0

  movf t0_s, WREG
  movff t0_h, t0_s
  movwf TMR0L, f
  movwf t0_h, f

  end_int:
  retfie
