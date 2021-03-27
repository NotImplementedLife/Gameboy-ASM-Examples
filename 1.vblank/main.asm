;	Now let's modify the hello-world source such that we'll repeatedly 
;   'show' and 'hide' the displayed string.
;   There'll be a little play with registers and WRAM. Two WRAM locations are
;   of interest:
;   $C004 - backup location  (will be used to temporary store register 'a')
;   $C005 - counter location (value stored here is incremented modulo 63, this
;							  will let us know when to show/hide the string)


INCLUDE "../common/hardware.inc"

SECTION "Header", ROM0[$100]

EntryPoint:
    di ; Disable interrupts
    jp Start 

REPT $150-$104
    db 0
ENDR

SECTION "Main", ROM0

waitForVBlank:
	ldh a, [rLY]          ; Load the current scanline
	cp 144                ; 144 - 153 are within vblank
	jr nz, waitForVBlank  ; Loop if != 144
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
.copyFont
    ld a    , [de]        ; Grab 1 byte from the source
    ld [hli], a           ; Place it at the destination, incrementing hl
    inc de                ; Move to next byte
    dec bc                ; Decrement count
    ld a    ,b            ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, .copyFont
	
	ld [$C004], a         ; Copy a at the address 0x5554
	ld a, 0               
	ld [$C005], a         ; Set value 0 at 0x5555
	ld a, [$C004]         ; Retrieve the a from 0x5554
	
	; main loop
.loop
    ld hl, $9901          ; Print the string at the 1,8 position of the screen
	                      ; This will center the text on the screen
    ld de, TheString
	ld [$C004], a	      ; *(0xC004) = a  | backup
	ld a, [$C005]         ; a = counter = *(0xC005)
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
	ld [$C004], a         ; backup
	ld a, [$C005]      
	inc a                 ; counter ++
	ld [$C005], a
	ld a, [$C004]         ; retrieve backup
	

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

SECTION "The string", ROM0

TheString:
    db "This Blinking Text ", 0