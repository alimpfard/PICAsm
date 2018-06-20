#include <p18f452.inc>

movlf macro lit, dest
	movlw lit
	movff WREG, dest
endm

filltbl macro loc
	movlf UPPER loc, TBLPTRU
	movlf HIGH loc, TBLPTRH
	movlf LOW loc, TBLPTRL
endm

negate_float macro reg
	btg reg, 0
endm

S_B equ 0x100
SH_PS equ 0x102
V0_SIGN equ 0x104
shr2 macro reg0, reg1, lit
	local loop
	movff reg0, V0_SIGN
	movlw 0x8000
	andwf V0_SIGN
	movff STATUS, S_B
	movlw lit
	loop:
	btfss V0_SIGN, 0
	bcf STATUS, C
	btfsc V0_SIGN, 0
	bsf STATUS, C
	rrcf reg1
	rrcf reg0
	decfsz WREG
	goto loop
	movff S_B, STATUS
endm
shl2 macro reg0, reg1, lit
	local loop
	movff STATUS, S_B
	movlw lit
	loop:
	bcf STATUS, C
	rlcf reg0
	rlcf reg1
	decfsz WREG
	goto loop
	movff S_B, STATUS
endm

accum0 equ 0x103
add2prg macro reg0, reg1, src_label, dest_label;read two bytes from program mem, add the two regs, write in the given label
	filltbl src_label
	tblrd *+
	movff TABLAT, WREG
	addwf reg0, 0
	movff WREG, accum0
	filltbl dest_label
	movff accum0, TABLAT
	tblwt *+
	btfsc STATUS, OV
	bsf STATUS, C
	filltbl src_label
	tblrd *+
	movff TABLAT, WREG
	addwfc reg1, 0
	movff WREG, accum0
	filltbl dest_label
	movff accum0, TABLAT
	tblwt *+
	bcf STATUS, C
	btfsc STATUS, OV
	bsf STATUS, C
endm

add4prg macro reg0, reg1, reg2, reg3, src_label, dest_label;read four bytes from program mem, add the four regs, write in the given label
	filltbl src_label
	tblrd *+
	movff TABLAT, WREG
	addwf reg0, 0
	movff WREG, accum0
	filltbl dest_label
	movff accum0, TABLAT
	tblwt *+
	btfsc STATUS, OV
	bsf STATUS, C
	filltbl src_label
	tblrd *+
	movff TABLAT, WREG
	addwfc reg1, 0
	movff WREG, accum0
	filltbl dest_label
	movff accum0, TABLAT
	tblwt *+
	bcf STATUS, C
	btfsc STATUS, OV
	bsf STATUS, C
	filltbl src_label
	tblrd *+
	movff TABLAT, WREG
	addwfc reg2, 0
	movff WREG, accum0
	filltbl dest_label
	movff accum0, TABLAT
	tblwt *+
	bcf STATUS, C
	btfsc STATUS, OV
	bsf STATUS, C
	filltbl src_label
	tblrd *+
	movff TABLAT, WREG
	addwfc reg3, 0
	movff WREG, accum0
	filltbl dest_label
	movff accum0, TABLAT
	tblwt *+
	bcf STATUS, C
	btfsc STATUS, OV
	bsf STATUS, C
endm

org 0x000
goto main

atan_table:
;e [data generate ctr]
;s [tbl is File new: 'arctan.tbl', read split: '\n', join: '']
;s [tdata is tbl characters chunks: 8, fmap: (\:x x join: ''), chunks: 4]
;p [tdata imap: \:i:x 'atan_tbl_%d:\n%:L\n' % [i, '\n', (x fmap: \:s 'db B\'$$s\'')], join: '\n']
;e [data generate ctr]
atan_tbl_0:
db B'00100000'
db B'00000000'
db B'00000000'
db B'00000000'

atan_tbl_1:
db B'00010010'
db B'11100100'
db B'00000101'
db B'00011101'

atan_tbl_2:
db B'00001001'
db B'11111011'
db B'00111000'
db B'01011011'

atan_tbl_3:
db B'00000101'
db B'00010001'
db B'00010001'
db B'11010100'

atan_tbl_4:
db B'00000010'
db B'10001011'
db B'00001101'
db B'01000011'

atan_tbl_5:
db B'00000001'
db B'01000101'
db B'11010111'
db B'11100001'

atan_tbl_6:
db B'00000000'
db B'10100010'
db B'11110110'
db B'00011110'

atan_tbl_7:
db B'00000000'
db B'01010001'
db B'01111100'
db B'01010101'

atan_tbl_8:
db B'00000000'
db B'00101000'
db B'10111110'
db B'01010011'

atan_tbl_9:
db B'00000000'
db B'00010100'
db B'01011111'
db B'00101110'

atan_tbl_10:
db B'00000000'
db B'00001010'
db B'00101111'
db B'10011000'

atan_tbl_11:
db B'00000000'
db B'00000101'
db B'00010111'
db B'11001100'

atan_tbl_12:
db B'00000000'
db B'00000010'
db B'10001011'
db B'11100110'

atan_tbl_13:
db B'00000000'
db B'00000001'
db B'01000101'
db B'11110011'

atan_tbl_14:
db B'00000000'
db B'00000000'
db B'10100010'
db B'11111001'

atan_tbl_15:
db B'00000000'
db B'00000000'
db B'01010001'
db B'01111100'

atan_tbl_16:
db B'00000000'
db B'00000000'
db B'00101000'
db B'10111110'

atan_tbl_17:
db B'00000000'
db B'00000000'
db B'00010100'
db B'01011111'

atan_tbl_18:
db B'00000000'
db B'00000000'
db B'00001010'
db B'00101111'

atan_tbl_19:
db B'00000000'
db B'00000000'
db B'00000101'
db B'00010111'

atan_tbl_20:
db B'00000000'
db B'00000000'
db B'00000010'
db B'10001011'

atan_tbl_21:
db B'00000000'
db B'00000000'
db B'00000001'
db B'01000101'

atan_tbl_22:
db B'00000000'
db B'00000000'
db B'00000000'
db B'10100010'

atan_tbl_23:
db B'00000000'
db B'00000000'
db B'00000000'
db B'01010001'

atan_tbl_24:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00101000'

atan_tbl_25:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00010100'

atan_tbl_26:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00001010'

atan_tbl_27:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000101'

atan_tbl_28:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000010'

atan_tbl_29:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000001'

atan_tbl_30:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

;e [program define ctr vargen]
;s [var t is '0' * 16 * 17]
;s [var p is Program argument: 2, or: '']
;s [t is t characters chunks: 8, chunks: 4]
;s [t is t imap: \:i:x
;s     '%s_%d:\n%:L\n' %
;s     [p, i, '\n', (x fmap: \:s ?>db B'%:L'<? % ['', (s or: [0] * 8)])]]
;p [t]
;e [program define ctr vargen]
;--RES OK

x:
;e [call vargen x]
x_0:
db B'00000000'
db B'00000000'

x_1:
db B'00000000'
db B'00000000'

x_2:
db B'00000000'
db B'00000000'

x_3:
db B'00000000'
db B'00000000'

x_4:
db B'00000000'
db B'00000000'

x_5:
db B'00000000'
db B'00000000'

x_6:
db B'00000000'
db B'00000000'

x_7:
db B'00000000'
db B'00000000'

x_8:
db B'00000000'
db B'00000000'

x_9:
db B'00000000'
db B'00000000'

x_10:
db B'00000000'
db B'00000000'

x_11:
db B'00000000'
db B'00000000'

x_12:
db B'00000000'
db B'00000000'

x_13:
db B'00000000'
db B'00000000'

x_14:
db B'00000000'
db B'00000000'

x_15:
db B'00000000'
db B'00000000'

x_16:
db B'00000000'
db B'00000000'

y:
;e [call vargen y]
y_0:
db B'00000000'
db B'00000000'

y_1:
db B'00000000'
db B'00000000'

y_2:
db B'00000000'
db B'00000000'

y_3:
db B'00000000'
db B'00000000'

y_4:
db B'00000000'
db B'00000000'

y_5:
db B'00000000'
db B'00000000'

y_6:
db B'00000000'
db B'00000000'

y_7:
db B'00000000'
db B'00000000'

y_8:
db B'00000000'
db B'00000000'

y_9:
db B'00000000'
db B'00000000'

y_10:
db B'00000000'
db B'00000000'

y_11:
db B'00000000'
db B'00000000'

y_12:
db B'00000000'
db B'00000000'

y_13:
db B'00000000'
db B'00000000'

y_14:
db B'00000000'
db B'00000000'

y_15:
db B'00000000'
db B'00000000'

y_16:
db B'00000000'
db B'00000000'

;e [call vargen z]
z_0:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_1:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_2:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_3:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_4:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_5:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_6:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_7:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_8:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_9:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_10:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_11:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_12:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_13:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_14:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_15:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

z_16:
db B'00000000'
db B'00000000'
db B'00000000'
db B'00000000'

x_start_0	equ 0x10
x_start_1	equ 0x11

y_start_0	equ 0x13
y_start_1	equ 0x14

angle_0	equ 0x16
angle_1	equ 0x17
angle_2	equ 0x18
angle_3	equ 0x19

sine_0	equ 0x21
sine_1	equ 0x22

cosine_0	equ 0x24
cosine_1	equ 0x25

quadrant 	equ 0x30

x_shr_0	equ 0x31
x_shr_1	equ 0x32

y_shr_0	equ 0x33
y_shr_1	equ 0x34

cordic:
; input at x_start, 16 bits
; input at y_start, 16 bits
; input at angle, 32 bits
; output at sine, 16 bits, cosine 16 bits
clrf quadrant
btfsc angle_0, 0
bsf quadrant, 0
btfsc angle_0, 1
bsf quadrant, 1

; adjust quadrants
btfsc quadrant, 0
goto quadrant1x
btfss quadrant, 1
goto quadrantxx
;case 01
; x_start => x_0
filltbl x_0
movff y_start_0, TABLAT
negate_float TABLAT
tblwt*+
movff y_start_1, TABLAT
tblwt*
; y_start => y_0
filltbl y_0
movff x_start_0, TABLAT
tblwt*+
movff x_start_1, TABLAT
tblwt*
; 00, angle[29:0] => z_0
filltbl z_0
movff angle_0, TABLAT
bcf TABLAT, 0
bcf TABLAT, 1 ;subtract pi/2 from angles in this quad
tblwt*+
movff angle_1, TABLAT
tblwt*+
movff angle_2, TABLAT
tblwt*+
movff angle_3, TABLAT
tblwt*

goto fquad
quadrant1x:
btfsc quadrant, 1
goto quadrantxx

;case 10
filltbl x_0
movff y_start_0, TABLAT
tblwt*+
movff y_start_1, TABLAT
tblwt*
filltbl y_0
movff x_start_0, TABLAT
negate_float TABLAT
tblwt*+
movff x_start_1, TABLAT
tblwt*
filltbl z_0
movff angle_0, TABLAT
bsf TABLAT, 0
bsf TABLAT, 1 ;add pi/2 to angles in this quad
tblwt*+
movff angle_1, TABLAT
tblwt*+
movff angle_2, TABLAT
tblwt*+
movff angle_3, TABLAT
tblwt*
goto fquad

;case 11, 00
quadrantxx:
; nothing to change for this quadrant
filltbl x_0
movff x_start_0, TABLAT
tblwt*+
movff x_start_1, TABLAT
tblwt*
filltbl y_0
movff y_start_0, TABLAT
tblwt*+
movff y_start_1, TABLAT
tblwt*
fquad:
z_sign equ 0x35

atg_0 equ 0x36
atg_1 equ 0x37
atg_2 equ 0x38
atg_3 equ 0x39

;e [data iterate i 0 15 1]
;p {
;filltbl x_$i$
;tblrd *+
;movff TABLAT, x_shr_0
;tblrd *
;movff TABLAT, x_shr_1
;shr2 x_shr_0, x_shr_1, $i$
;filltbl y_$i$
;tblrd *+
;movff TABLAT, y_shr_0
;tblrd *
;movff TABLAT, y_shr_1
;shr2 y_shr_0, y_shr_1, $i$
;filltbl z_$i$
;tblrd *+
;tblrd *+
;tblrd *+
;tblrd *
;movff TABLAT, z_sign
;btfss z_sign, 7
;btg y_shr_0, 0
;add2prg y_shr_0, y_shr_1, x_$i$,  x_$i + 1$
;btfss z_sign, 7
;btg x_shr_0, 0
;add2prg x_shr_0, x_shr_1, y_$i$, y_$i + 1$
;filltbl atan_tbl_$i$
;tblrd *+
;movff TABLAT, atg_0
;tblrd *+
;movff TABLAT, atg_1
;tblrd *+
;movff TABLAT, atg_2
;tblrd *
;movff TABLAT, atg_3
;btfss z_sign, 7
;btg atg_0, 0
;add4prg atg_0,atg_1,atg_2,atg_3, z_$i$, z_$i + 1$
;p }
filltbl x_0
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 0
filltbl y_0
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 0
filltbl z_0
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_0,  x_1
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_0, y_1
filltbl atan_tbl_0
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_0, z_1

filltbl x_1
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 1
filltbl y_1
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 1
filltbl z_1
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_1,  x_2
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_1, y_2
filltbl atan_tbl_1
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_1, z_2

filltbl x_2
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 2
filltbl y_2
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 2
filltbl z_2
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_2,  x_3
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_2, y_3
filltbl atan_tbl_2
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_2, z_3

filltbl x_3
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 3
filltbl y_3
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 3
filltbl z_3
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_3,  x_4
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_3, y_4
filltbl atan_tbl_3
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_3, z_4

filltbl x_4
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 4
filltbl y_4
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 4
filltbl z_4
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_4,  x_5
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_4, y_5
filltbl atan_tbl_4
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_4, z_5

filltbl x_5
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 5
filltbl y_5
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 5
filltbl z_5
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_5,  x_6
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_5, y_6
filltbl atan_tbl_5
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_5, z_6

filltbl x_6
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 6
filltbl y_6
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 6
filltbl z_6
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_6,  x_7
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_6, y_7
filltbl atan_tbl_6
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_6, z_7

filltbl x_7
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 7
filltbl y_7
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 7
filltbl z_7
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_7,  x_8
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_7, y_8
filltbl atan_tbl_7
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_7, z_8

filltbl x_8
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 8
filltbl y_8
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 8
filltbl z_8
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_8,  x_9
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_8, y_9
filltbl atan_tbl_8
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_8, z_9

filltbl x_9
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 9
filltbl y_9
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 9
filltbl z_9
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_9,  x_10
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_9, y_10
filltbl atan_tbl_9
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_9, z_10

filltbl x_10
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 10
filltbl y_10
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 10
filltbl z_10
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_10,  x_11
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_10, y_11
filltbl atan_tbl_10
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_10, z_11

filltbl x_11
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 11
filltbl y_11
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 11
filltbl z_11
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_11,  x_12
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_11, y_12
filltbl atan_tbl_11
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_11, z_12

filltbl x_12
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 12
filltbl y_12
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 12
filltbl z_12
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_12,  x_13
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_12, y_13
filltbl atan_tbl_12
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_12, z_13

filltbl x_13
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 13
filltbl y_13
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 13
filltbl z_13
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_13,  x_14
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_13, y_14
filltbl atan_tbl_13
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_13, z_14

filltbl x_14
tblrd *+
movff TABLAT, x_shr_0
tblrd *
movff TABLAT, x_shr_1
shr2 x_shr_0, x_shr_1, 14
filltbl y_14
tblrd *+
movff TABLAT, y_shr_0
tblrd *
movff TABLAT, y_shr_1
shr2 y_shr_0, y_shr_1, 14
filltbl z_14
tblrd *+
tblrd *+
tblrd *+
tblrd *
movff TABLAT, z_sign
btfss z_sign, 7
btg y_shr_0, 0
add2prg y_shr_0, y_shr_1, x_14,  x_15
btfss z_sign, 7
btg x_shr_0, 0
add2prg x_shr_0, x_shr_1, y_14, y_15
filltbl atan_tbl_14
tblrd *+
movff TABLAT, atg_0
tblrd *+
movff TABLAT, atg_1
tblrd *+
movff TABLAT, atg_2
tblrd *
movff TABLAT, atg_3
btfss z_sign, 7
btg atg_0, 0
add4prg atg_0,atg_1,atg_2,atg_3, z_14, z_15


filltbl x_15
tblrd *+
movff TABLAT, cosine_0
tblrd *+
movff TABLAT, cosine_1
filltbl y_15
tblrd *+
movff TABLAT, sine_0
tblrd *+
movff TABLAT, sine_1
return

#define An0 B'10100111'
#define An1 B'11010010'
#define a0 B'00100000' ;45 degrees
#define a1 B'00000000'
#define a2 B'00000000'
#define a3 B'00000000'

main:
	;test stuff, nya
	movlw An0
	movwf x_start_0
	movlw An1
	movwf x_start_1
	clrf y_start_0
	clrf y_start_1
	movlw a0
	movwf angle_0
	movlw a1
	movwf angle_1
	movlw a2
	movwf angle_2
	movlw a3
	movwf angle_3
	call cordic
goto main
END
