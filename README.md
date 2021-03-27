# Gameboy ASM Examples

A collection of Gameboy projects I made while learning GBZ80 Assembly.

The repository comes with scripts for building and running the ROMs. [RGBDS](https://github.com/gbdev/rgbds "RGBDS") will be required in the build process. Make sure it is found in your ```%PATH%```.

I used the [BGB64](https://bgb.bircd.org/ "BGB") emulator. Feel free to edit the batch files in order to use your favorite Gameboy emulator.

Building example:

<pre style="background:black"><code><span style="color:dodgerblue">C:\Gameboy-ASM-Examples>build 1.vblank</span>
Building 1.vblank
:: rgbasm -o main.o main.asm
Linking...
:: rgblink -o 1.vblank.gb main.o
Fixing ROM...
:: rgbfix -v -p 0 1.vblank.gb
Cleaning...
Launching... <span style="color:green"># test the ROM on the Gameboy emulator</span>
Done.
</code></pre>

If there's no need to build the ROM, just ```run``` it:

<pre style="background:black"><code><span style="color:dodgerblue">C:\Gameboy-ASM-Examples>run 1.vblank</span>
Launching...
Done.
</code></pre>