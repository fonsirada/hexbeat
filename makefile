
.PHONY: all

all: game.gb

game.gb: build build/graphics.o build/sound.o build/sprites.o build/player.o build/game_workings.o build/main.o 
	rgblink --dmg --tiny --map game.map --sym game.sym -o game.gb build/main.o build/graphics.o build/sound.o build/sprites.o build/player.o build/game_workings.o
	rgbfix -v -p 0xFF game.gb

# game.gb: build build/graphics.o build/main.o
# 	rgblink --dmg --tiny --map game.map --sym game.sym -o game.gb build/main.o build/graphics.o
# 	rgbfix -v -p 0xFF game.gb

build:
	mkdir build

build/graphics.o: build src/graphics.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/graphics.o src/graphics.asm

build/sound.o: build src/sound.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/sound.o src/sound.asm

build/player.o: build src/player.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/player.o src/player.asm

build/sprites.o: build src/sprites.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/sprites.o src/sprites.asm

build/game_workings.o: build src/game_workings.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/game_workings.o src/game_workings.asm

build/main.o: build src/main.asm src/*.inc assets/*.tlm assets/*.chr
	rgbasm -o build/main.o src/main.asm
