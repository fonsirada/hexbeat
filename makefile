
.PHONY: all

all: game.gb

game.gb: build build/graphics.o build/sprites.o build/main.o build/joypad.o
	rgblink --dmg --tiny --map game.map --sym game.sym -o game.gb build/main.o build/graphics.o build/sprites.o build/joypad.o
	rgbfix -v -p 0xFF game.gb

build:
	mkdir build

build/graphics.o: build src/graphics.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/graphics.o src/graphics.asm

build/sprites.o: build src/sprites.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/sprites.o src/sprites.asm

build/joypad.o: build src/joypad.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/joypad.o src/joypad.asm

build/main.o: build src/main.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/main.o src/main.asm
