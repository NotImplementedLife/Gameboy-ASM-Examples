;	Now let's modify the hello-world source such that we'll repeatedly 
;   'show' and 'hide' the displayed string.
;   There'll be a little play with registers and WRAM. Two WRAM locations are
;   of interest:
;   $C004 - backup location  (will be used to temporary store register 'a')
;   $C005 - counter location (value stored here is incremented modulo 63, this
;							  will let us know when to show/hide the string)


INCLUDE "../common/hardware.inc"

wait_vram: MACRO
.waitVRAM\@
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .waitVRAM\@
ENDM

SECTION "Vblank VARS", HRAM
hVBlankFlag:
	DS 1
	
SECTION "VBlank  Interrupt", ROM0[$40]
	push af
    xor a
    ldh [hVBlankFlag], a
    pop af
    reti

SECTION "LCD controller status interrupt", ROM0[$48]
	reti
	
SECTION "Timer overflow interrupt", ROM0[$50]
	reti

SECTION "Serial transfer completion interrupt", ROM0[$58]
	reti

SECTION "P10-P13 signal low edge interrupt", ROM0[$60]
	reti
	
SECTION "Header", ROM0[$100]

EntryPoint:
    nop	
    jp Start 

REPT $150-$104
    db 0
ENDR

SECTION "Main", ROM0

waitForVBlank:	
    halt
	nop
    ldh a, [hVBlankFlag]
    and a
    jr nz, waitForVBlank
	ret	


Start:  
	xor a
	ldh [hVBlankFlag], a	
	ld a, 1
	ldh [rIE], a		
	
	call waitForVBlank
	;ld b,b
	; Turn off the LCD
    xor a                 ; ld a,0 
    ld [rLCDC], a 		

    ; copy the font to VRAM
    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyFont
	wait_vram
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
	wait_vram
    ld a, [de]
    ld [hli],a
    inc de
    and a                 ; check if the byte we copied is 0
    jr nz, .copyString    ; Continue if it's not	
	
	jr .draw	
.hideString	              ; The same as .copyString, but for each character we print a space
	wait_vram
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
	
    jp .loop              ; while(1) 

SECTION "FONT", ROM0

FontTiles:
INCBIN "../common/res/font.chr"
FontTilesEnd:

SECTION "The string", ROM0

TheString:
	; Simulate endline by filling the lines with hidden text
    db "This Blinking Text [ INVISIBLE]  I LOVE SPAGHETTI", 0