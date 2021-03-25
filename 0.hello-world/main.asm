INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

EntryPoint:
    di ; Disable interrupts
    jp Start 

REPT $150-$104
    db 0
ENDR

SECTION "Main", ROM0

Start:
    ; Turn off the LCD
.waitVBlank 
    ld a, [rLY]
    cp 144 ; check if LCD if past VBlank
    jr c, .waitVBlank

    xor a ; ld a,0 
    ld [rLCDC],a 

    ; copy the font to VRAM

    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyFont
    ld a    , [de] ; Grab 1 byte from the source
    ld [hli], a    ; Place it at the destination, incrementing hl
    inc de         ; Move to next byte
    dec bc         ; Decrement count
    ld a    ,b     ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, .copyFont

    ld hl, $9800 ; Print the string at the 0,0 position of the screen
    ld de, HellowWorldStr
.copyString 
    ld a, [de]
    ld [hli],a
    inc de
    and a ; check if the byte we copied is 0
    jr nz, .copyString ; Continue if it's not

    ; Init dispaly registers
    ld a, %11100100
    ld [rBGP], a
    xor a ; ld a, 0
    ld [rSCX], a
    ld [rSCY], a

    ; Shut down sound
    ld [rNR52], a

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a

    ;Lock up
.lockup
    jr .lockup

SECTION "FONT", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "Hello world string", ROM0

HellowWorldStr:
    db "Hello World", 0