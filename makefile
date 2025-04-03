
.PHONY: all

all: game.gb

game.gb: build build/graphics.o build/main.o
	rgblink --dmg --tiny --map game.map --sym game.sym -o game.gb build/main.o build/graphics.o
	rgbfix -v -p 0xFF game.gb

build:
	mkdir build

build/graphics.o: build src/graphics.asm src/hardware.inc src/utils.inc assets/*.tlm assets/*.chr
	rgbasm -o build/graphics.o src/graphics.asm

build/main.o: build src/main.asm src/hardware.inc assets/*.tlm assets/*.chr
	rgbasm -o build/main.o src/main.asm
