#include <p18f452.inc>

org 0x00
goto main


main:
  clrf TRISB
  clrf PORTB
  bsf  TRISB, 0 ; push button input port
  ;Initialize DISPLAY registers here
main_loop:
  btfss PORTB, 0
  call block_button_pressed
  call display
  goto main_loop

block_button_pressed:
  movlw 10
check_button_pressed:
  btfss PORTB, 0
  decfsz WREG
  goto check_button_pressed
  return

display:
  nop
  ;do stuff
  return
msdelay:
  nop
  ;do stuff
  return

end
