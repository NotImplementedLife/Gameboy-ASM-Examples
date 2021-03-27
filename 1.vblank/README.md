# 1.vblank 
_(VBlank Demonstration)_

Since [0.hello-world](../0.hello-world/ "0.hello-world") only needs to print a static string, it doesn't provide a reusable vBlank method. Instead the code loads the graphic resources during the first vBlank and catches itself into an empty loop to prevent the CPU do unwanted things.

So, I decided to use vBlank with a simple animation (if it can be called like that) which shows/hides a certain string. 

Here's the code used for vBlank:

```
waitForVBlank:
	ldh a, [rLY]          ; Load the current scanline
	cp 144                ; 144 - 153 are within vblank
	jr nz, waitForVBlank  ; Loop if != 144
	ret
```

and the main loop:

```
.loop
    ... ; stuff to be done
    call waitForVBlank
    jr .loop
```


I _hid_ the string by replacing every character with an empty string, although I'm sure there are more faster and elegant ways to achieve this.

This demo also makes use of tilemaps to print the string on multiple lines. Here's a snapshot of the BGMap in VRAM:

<p align="center">
 <img src="/README_Resources/1.bgmap.png" alt="BGMap" width="351"/>
</p>

And here is the final result: 

<p align="center">
 <img src="/README_Resources/1.demo.gif" alt="Demo" width="320"/>
</p>