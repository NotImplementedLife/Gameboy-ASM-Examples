INCLUDE "../common/hardware.inc"
INCLUDE "inc/header.asm"

SECTION "Work Ram", WRAM0[$C500]

backup::
	ds 2
digits::
	ds 4
drawingFlag:
	ds 1
counter:
	ds 1

SECTION "Main", ROM0

waitForVBlank:
	ldh a, [rLY]          ; Load the current scanline
	cp 144                ; 144 - 153 are within vblank
	jr nz, waitForVBlank  ; Loop if != 144
	ret

; loadTiles
; arguments:
;	hl = destination address
;   de = source address
;	bc = data size
loadMemory:
	ld a, [de]            ; Grab 1 byte from the source
    ld [hli], a           ; Place it at the destination, incrementing hl
    inc de                ; Move to next byte
    dec bc                ; Decrement count
    ld a ,b               ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, loadMemory
	ret
; drawDigit
; arguments:
; hl = screen top-left position
; bc = memory tiles [ view Digits SECTION]
drawDigit:	
	ld d, 0
	ld e, 0
.renderDigit
	ld a, [bc]
	ld [hli], a
	inc bc
	inc d	
	ld a, d               
	cp a, $3 	
	jr NZ, .renderDigit
	inc e	
	ld a, b
	ld [backup+0], a
	ld a, c
	ld [backup+1], a
	ld bc, $1D
	add hl, bc
	ld a, [backup+0]
	ld b, a
	ld a, [backup+1]
	ld c, a
	ld a, e
	cp a, $5
	ld d, $0
	jr nz, .renderDigit
	ret	
	
; draw all four digits
; split the drawing method into two subtoutines, each to be executed in a separate vblank
; This is due to the expensive drawing method
update00__: ; draw [XX][:][  ]  	
	ld d,0
	ld e,0
	ld b, $C0
	ld a, [digits+0]
	ld c, a	
	ld hl, $98E2			
	call drawDigit
	
	ld b, $C0
	ld a, [digits+1]
	ld c, a	
	ld hl, $98E6			
	call drawDigit	
	
	ret

update__00:	; draw [  ][:][XX]
	ld b, $C0
	ld a, [digits+2]
	ld c, a	
	ld hl, $98EB			
	call drawDigit
		
	ld b, $C0
	ld a, [digits+3]
	ld c, a	
	ld hl, $98EF			
	call drawDigit	
	
	ret

; increments [bc] with $F. If digit out of range, set [bc] to 0 and increment [bc-1]
; bc = digits+0 .. digits+3
; simulates the clock incrementation (*:XX->*:XX+1 ; *:59->*.00)
increment:
	ld a, [bc]
	add a, $F
	ld d, a
	ld a, c	
	cp a, LOW(digits+2) 
	ld a, d
	jr z, .digit3is6
	cp a, $96
	jr z, .0x96
	ld [bc],a 
	ret
.0x96
	ld a, 0
	ld [bc], a	
	ld a, c	
	cp a, $06
	ret z
	ld a, 4	
	dec bc
	jr increment	
	ret	
.digit3is6
	cp a, $5A ; check if the 3rd digit is 6
	jr z, .0x96
	ld [bc],a
	ret 

Start:
    ; Turn off the LCD
	call waitForVBlank	
    xor a                 ; ld a,0 
    ld [rLCDC], a   
	
	; copy digital tilemap to VRAM
	ld hl, $8800
	ld de, DigitalTilemap
	ld bc, DigitalTilemapEnd-DigitalTilemap
	call loadMemory
	
	; copy digits data to WRAM
	ld hl, $C000
	ld de, Digits
	ld bc, DigitsEnd-Digits
	call loadMemory
		
	ld [backup+0], a         ; Copy a at the address 0xD004
	ld a, 0               
	ld [backup+1], a         ; Set value 0 at 0xD005
	ld a, [backup+0]         ; Retrieve the a from 0xD004
	
	; Draw the ":" symbol
	ld hl, $9909	; screen X=9, Y=8
	ld a, $87
	ld [hli], a
	inc a
	ld [hli], a		
	ld hl, $9949	; screen X=9, Y=10
	ld a, $87
	ld [hli], a
	inc a
	ld [hli], a		
	
	ld a, $00
	ld [digits+0], a
	ld [digits+1], a
	ld [digits+2], a
	ld [digits+3], a		
	
	ld a, 0
	ld [counter], a
	
	call update00__
	call update__00
	
	; main loop
.loop
	ld a, [drawingFlag]
	cp a, 1
	call z,update00__
	ld a, 0
	ld [drawingFlag], a
	
	ld a, [counter]
	and a, 127
	cp a, 127
	jr nz, .draw		
	ld bc, digits+3	
	call increment				
	call update__00
	ld a, 1
	ld [drawingFlag], a
.draw		
	inc a
	ld [counter], a
    ; Init display registers
    ld a, %00011011
    ld [rBGP], a
    xor a ; ld a, 0
    ld [rSCX], a
    ld [rSCY], a    

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a	
.vblank
	call waitForVBlank
	
    jr .loop              ; while(1) 

SECTION "FONT", ROM0

FontTiles:
INCBIN "../common/res/font.chr"
FontTilesEnd:

SECTION "Digital tilemap", ROM0

DigitalTilemap:
    DB $7f, $7f, $3f, $3f, $9f, $9f, $c0, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	DB $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $fe, $fe, $fc, $fc, $f9, $f9, $03, $03, $07, $07, $07, $07, $07, $07, $07, $07
	DB $00, $00, $00, $00, $01, $01, $03, $03, $07, $07, $07, $07, $07, $07, $07, $07
	DB $e0, $e0, $c0, $c0, $80, $80, $00, $00, $00, $00, $80, $80, $c0, $c0, $e0, $e0
	DB $07, $07, $03, $03, $01, $01, $00, $00, $00, $00, $01, $01, $03, $03, $07, $07
	DB $00, $00, $00, $00, $80, $80, $c0, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	DB $00, $00, $03, $03, $07, $07, $07, $07, $07, $07, $07, $07, $03, $03, $00, $00
	DB $00, $00, $c0, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $c0, $c0, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
	DB $07, $07, $03, $03, $01, $01, $00, $00, $00, $00, $01, $01, $03, $03, $07, $07
	DB $00, $00, $00, $00, $0f, $0f, $3f, $3f, $3f, $3f, $8f, $8f, $c0, $c0, $e0, $e0
	DB $07, $07, $03, $03, $f1, $f1, $fc, $fc, $fc, $fc, $f0, $f0, $00, $00, $00, $00
	DB $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $e0, $e0, $c0, $c0, $8f, $8f, $3f, $3f, $3f, $3f, $8f, $8f, $c0, $c0, $e0, $e0
	DB $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00
	DB $07, $07, $03, $03, $f1, $f1, $fc, $fc, $fc, $fc, $f1, $f1, $03, $03, $07, $07
	DB $07, $07, $07, $07, $07, $07, $07, $07, $03, $03, $01, $01, $00, $00, $00, $00
	DB $e0, $e0, $c0, $c0, $8f, $8f, $3f, $3f, $3f, $3f, $0f, $0f, $00, $00, $00, $00
	DB $00, $00, $00, $00, $f0, $f0, $fc, $fc, $fc, $fc, $f1, $f1, $03, $03, $07, $07
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $f8, $f8, $fc, $fc, $fe, $fe
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $c0, $c0, $9f, $9f, $3f, $3f, $7f, $7f
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff
	DB $07, $07, $07, $07, $07, $07, $07, $07, $03, $03, $f9, $f9, $fc, $fc, $fe, $fe
	DB $7f, $7f, $3f, $3f, $1f, $1f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $1f, $1f, $3f, $3f, $7f, $7f
	DB $fe, $fe, $fc, $fc, $f8, $f8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	DB $00, $00, $00, $00, $0f, $0f, $3f, $3f, $3f, $3f, $0f, $0f, $00, $00, $00, $00
	DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DigitalTilemapEnd:

SECTION "Digits", ROM0
Digits:
	DB $80, $81, $82, $90, $91, $92, $84, $91, $85, $90, $91, $92, $B0, $B1, $B2 ; Digit 0 - $C000
	DB $91, $91, $83, $91, $91, $92, $91, $91, $93, $91, $91, $92, $91, $91, $A3 ; Digit 1 - $C00F
	DB $B3, $81, $82, $91, $91, $92, $94, $A1, $95, $90, $91, $91, $B0, $B1, $A6 ; Digit 2 - $C01E
	DB $B3, $81, $82, $91, $91, $92, $B6, $A1, $A2, $91, $91, $92, $B4, $B1, $B2 ; Digit 3 - $C02D
	DB $86, $91, $83, $90, $91, $92, $A4, $A1, $A2, $91, $91, $92, $91, $91, $A3 ; Digit 4 - $C03C
	DB $80, $81, $B5, $90, $91, $91, $A4, $A1, $A5, $91, $91, $92, $B4, $B1, $B2 ; Digit 5 - $C04B
	DB $80, $81, $B5, $90, $91, $91, $A0, $A1, $A5, $90, $91, $92, $B0, $B1, $B2 ; Digit 6 - $C05A
	DB $B3, $81, $82, $91, $91, $92, $91, $91, $93, $91, $91, $92, $91, $91, $A3 ; Digit 7 - $C069
	DB $80, $81, $82, $90, $91, $92, $A0, $A1, $A2, $90, $91, $92, $B0, $B1, $B2 ; Digit 8 - $C078
	DB $80, $81, $82, $90, $91, $92, $A4, $A1, $A2, $91, $91, $92, $B4, $B1, $B2 ; Digit 9 - $C087
DigitsEnd: