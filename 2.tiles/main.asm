INCLUDE "../common/hardware.inc"
INCLUDE "inc/header.asm"

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

drawDigit:	
	ld a, [bc]
	ld [hli], a
	inc bc
	inc d	
	ld a, d               
	cp a, $3 	
	jp NZ, drawDigit
	inc e	
	ld a, b
	ld [$D004], a
	ld a, c
	ld [$D005], a
	ld bc, $1D
	add hl, bc
	ld a, [$D004]
	ld b, a
	ld a, [$D005]
	ld c, a
	ld a, e
	cp a, 5
	ld d, 0
	jp NZ, drawDigit
	ret	

Start:
    ; Turn off the LCD
	call waitForVBlank	
    xor a                 ; ld a,0 
    ld [rLCDC], a 

    ; copy the font to VRAM
    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
	call loadMemory
	
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
		
	ld [$D004], a         ; Copy a at the address 0xD004
	ld a, 0               
	ld [$D005], a         ; Set value 0 at 0xD005
	ld a, [$D004]         ; Retrieve the a from 0xD004
	
	; Draw the ":" symbol
	ld hl, $9908	; screen X=9, Y=8
	ld a, $87
	ld [hli], a
	inc a
	ld [hli], a		
	ld hl, $9948	; screen X=9, Y=10
	ld a, $87
	ld [hli], a
	inc a
	ld [hli], a	
		
	ld hl, $98E1
	ld bc, $C069
	ld d, 0
	ld e, 0
	call drawDigit
	
	ld hl, $98E5
	ld bc, $C000
	ld d, 0
	ld e, 0
	call drawDigit

	ld hl, $98EA	
	ld bc, $C03C
	ld d, 0
	ld e, 0
	call drawDigit
	
	ld hl, $98EE
	ld bc, $C087
	ld d, 0
	ld e, 0
	call drawDigit
	
	
	; main loop
.loop
	jr .draw
    ld hl, $9800          ; Print the string at the 1,8 position of the screen
	                      ; This will center the text on the screen
    ld de, TheString
	ld [$D004], a	      ; *(0xC004) = a  | backup
	ld a, [$D005]         ; a = counter = *(0xC005)
	and a, 63
	cp a, 31              ; if (counter % 64 < 31) ...
	ld a, [$C004]         ; a = *(0xC004)  | retrieve backup	
	jp C, .hideString     ; ... then cover the string with spaces
.copyString 
    ld a, [de]
    ld [hli],a
    inc de
    and a                 ; check if the byte we copied is 0
    jr nz, .copyString    ; Continue if it's not	
	
	jr .draw	
.hideString	              ; The same as .copyString, but for each character we print a space
	ld a, [de]
	ld [$C004], a	      ; We need to backup the character in order to check it with ```and a```
	ld a, 255             ; replace char with space
    ld [hli], a           ; write in VRAM
	ld a, [$C004]         ; retrive backup
    inc de                ; next character
    and a                 ; check if the byte we copied is 0
    jr nz, .hideString    ; Continue if it's not
	
.draw
	ld [$D004], a         ; backup
	ld a, [$D005]      
	inc a                 ; counter ++
	ld [$D005], a
	ld a, [$D004]         ; retrieve backup
	

    ; Init display registers
    ld a, %00011011
    ld [rBGP], a
    xor a ; ld a, 0
    ld [rSCX], a
    ld [rSCY], a    

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a	
    
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

SECTION "The string", ROM0

TheString:
	; Simulate endline by filling the lines with hidden text
    db "This Blinking Text", 0