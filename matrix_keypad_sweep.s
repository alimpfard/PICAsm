; 8x8 keypad, rows to PORTC, cols to PORTB
; action: `call beep` if no buttons are pressed

;bit pattern register, will arithm. shift left until [0b10000000]
BR0 equ 0x10
RSR equ 0x12

org 0x000
goto main

main:
  movlw 0x001
  movwf BR0
main_loop:
  call sweep
  call act_if_pressed
  call msdelay
  goto main_loop

sweep:
    movlw 8
  sweep_loop_0:
    ;
    call set_stage_0
    movff BR0, PORTC
    call read_stage_0
    ;
    call set_stage_1
    movff BR1, PORTB
    call read_stage_1
    ;
    rlncf BR0
    decfsz WREG
    goto sweep_loop_0
  return

act_if_pressed:
  btfss RSR, 0
  call beep
  return

set_stage_0:
  ;stage 0: write rows, read columns
  setf TRISC
  clrf TRISB
  return

set_stage_1:
  ;stage 1: write cols, read rows
  setf TRISB
  clrf TRISC
  return

read_stage_0:
  movlw 0
  cpfsgt PORTC
  bsf RSR, 0
  return


read_stage_1:
  movlw 0
  cpfsgt PORTB
  bsf RSR, 0
  return

end
