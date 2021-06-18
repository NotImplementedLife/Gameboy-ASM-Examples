# 3.vblank-handler

More technique and less creativity today. This is just a rewritten `1.vblank` code which led to a pretty impressive performance boost.

Just by replacing this 

```
waitForVBlank:
    ldh a, [rLY]          ; Load the current scanline
	cp 144                ; 144 - 153 are within vblank
	jr nz, waitForVBlank  ; Loop if != 144
	ret
```

with this:

```
waitForVBlank:
    halt
    nop
    ldh a, [hVBlankFlag]
    and a
    jr nz, waitForVBlank
	ret	
```

There is a bunch of minor changes in order to make this work:

- first, enable vBlank interrupt:

```
    ld a, 1
    ld [rIE], a ; set bit 0 (vBlank) of Interrupt Enable
```

- add the vBlank interrupt handler

```
SECTION "VBlank  Interrupt", ROM0[$40]
	push af
    xor a
    ldh [hVBlankFlag], a
    pop af
    reti
```

- define the `hVBlankFlag`
```
SECTION "Vblank VARS", HRAM
hVBlankFlag:
	DS 1


; Initialize it before enabling vBlank interrupt:
    xor a
	ldh [hVBlankFlag], a
```
