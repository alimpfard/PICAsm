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
  btfss PORTB, 0
  goto check_button_pressed
  call increase
  return
increase:
  nop
  ;do stuff
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
