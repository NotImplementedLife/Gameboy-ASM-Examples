# Gameboy ASM Examples

A collection of Gameboy projects I made while learning GBz80 Assembly.

The repository comes with scripts for building and running the ROMs. [RGBDS](https://github.com/gbdev/rgbds "RGBDS") will be required in the build process. Make sure it is found in your ```%PATH%```.

I used the [BGB64](https://bgb.bircd.org/ "BGB") emulator. Feel free to edit the batch files in order to use your favorite Gameboy emulator.

Building example:

<pre style="background:black;"><code><span style="color:dodgerblue">C:\Gameboy-ASM-Examples></span><span style="color:yellow">build 1.vblank</span>
<span style="color:white">Building 1.vblank
:: rgbasm -o main.o main.asm
Linking...
:: rgblink -o 1.vblank.gb main.o
Fixing ROM...
:: rgbfix -v -p 0 1.vblank.gb
Cleaning...
Launching...</span> <span style="color:green"># test the ROM on the Gameboy emulator</span>
<span style="color:white">Done.</span>
</code></pre>

If there's no need to build the ROM, just ```run``` it:

<pre style="background:black"><code><span style="color:dodgerblue">C:\Gameboy-ASM-Examples></span><span style="color:yellow">run 1.vblank</span>
<span style="color:white">Launching...
Done.</span>
</code></pre>

There are precompiled ROMs in the [bin](bin/ "bin") folder.

## Contents

| Id  | Name                                   | Description                         |
|----:|----------------------------------------|-------------------------------------|
| 0   | [hello-world](./0.hello-world)         | First ROM                           |
| 1   | [vblank](./1.vblank)                   | Learn using vBlank                  |
| 2   | [tiles](./2.tiles)                     | Learn using tilesets/tilemaps       |
| 3   | [vblank-handler](./3.vblank-handler)   | Faster vBlank using `halt`          |

Direct links:

- [Tiileset Generator](https://notimplementedlife.github.io/Gameboy-ASM-Examples/misc/TilesetGenerator/index.html "Tileset Generator") - html tool to create Gameboy Tiles
