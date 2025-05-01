# header

"""
(inspired by)
"THE REGRET OF VICTORY" - KASTLEVANIA by KIELEN KING

c#6 g#5 b5 c#5 b5 g#5 g#5 f#5 g#5 f#5 e5 f#5 g#5 br
3   1   1   1  1  4   3   2   2   2   3  3   4   4

f#5 f#5 f#5 f#5 g#5 c#6 c#6 e6 f#6 e6 d#6 g#5 c#6
2   2   2   1   2   4   2   2  2   1  1   2   4
"""

def convert_to_rom_data(music, NoteTable, LengthTable):
    converted_notes = []
    for note in music:
        converted_note = [NoteTable[note[0]], LengthTable[note[1]]]
        converted_notes.append(converted_note)
    return converted_notes

def print_notes(music):
    for note in music:
        print(note[0], end=", ")
    print()
    for note in music:
        print(note[1], end=", ")
    return 0

# ----- MAIN ----- #

def main():
    # Notes data from C2 to B8
    # 20 * 34 + 8 = 688
    # 7 * 2 * (8 - 2) = 84
    # assuming a length of 250ms; r24, r23
    #* no e#, b#
    NoteTable = {
        "c3":"", "d3":"", "e3":"", "f3":"", "g3":"", "a3":"", "b3":"",  
        "c#3":"", "d#3":"", "e#3":"", "f#3":"", "g#3":"", "a#3":"", "b#3":"",
        "c4":"$c60b", "d4":"$c642", "e4":"$c672", "f4":"$c689", "g4":"$c6b2", "a4":"$c6d6", "b4":"$c6f7",  
        "c#4":"$c627", "d#4":"$c65b", "e#4":"", "f#4":"$c69e", "g#4":"$c6c4", "a#4":"$c6e7", "b#4":"",
        "c5":"$c706", "d5":"$c721", "e5":"$c739", "f5":"$c744", "g5":"$c759", "a5":"$c76b", "b5":"$c77b",  
        "c#5":"$c714", "d#5":"$c72d", "e#5":"", "f#5":"$c74f", "g#5":"$c762", "a#5":"$c773", "b#5":"",
        "c6":"$c783", "d6":"$c790", "e6":"$c79d", "f6":"$c7a2", "g6":"$c7ac", "a6":"$c7b6", "b6":"c7be",  
        "c#6":"$c78a", "d#6":"$c797", "e#6":"", "f#6":"$c7a7", "g#6":"$c7b1", "a#6":"$c7ba", "b#6":"",
        "c7":"$c7c1"
    }

    # assuming duty is 50 ($40):
    # 250ms: NR21 $80, NR24 $C0
    # prolly implement length w/ time between notes
    LengthTable = {
        1:"$0008",
        2:"$0010",
        3:"$0020",
        4:"$0040",
        5:"$0080"
    }

    song1 = [["c#6", 3], ["g#5", 1], ["b5", 1], ["c#6", 1], 
             ["b5", 1], ["g#5", 4], ["g#5", 3], ["f#5", 2],
             ["g#5", 2], ["f#5", 2], ["e5", 3], ["f#5", 3],
             ["g#5", 5], ["f#5", 2], ["f#5", 2], #add break
             ["f#5", 2], ["f#5", 1], ["g#5", 2], ["c#6", 4],
             ["c#6", 2], ["e6", 2], ["f#6", 2], ["e6", 1],
             ["d#6", 1], ["g#5", 2], ["c#6", 4]
            ]
    song2 = [["d#6", 1], ["c#6", 1], ["a#5", 2], ["a#5", 1],
             ["g#5", 1], ["d#5", 2], ["c#5", 2], ["d5", 2],
             ["f5", 1], ["f#5", 1], ["f5", 1], ["f#5", 1], 
             ["f5", 1], ["f#5", 1], ["d#5", 2], ["d#5", 1],
             ["f#5", 1], ["g#5", 1], ["a#5", 1],["c6", 1],
             ["c#6", 1], ["d#6", 2], ["a#5", 2]
            ]
    song3 = [["a#5", 1], ["c6", 1], ["c#6", 1], ["d#6", 2], 
             ["c6", 2], ["c#6", 1], ["d#6", 1], 
             ["a#5", 1], ["d#5", 1], ["f5", 1], ["g#5", 1], 
             ["d#5", 1]
            ]
    song4 = [["a#5", 2],["f#5", 1],["f5", 2],["f#5", 1],
             ["f5", 2],["d5", 2],["c#5", 2],["c#5", 1],
             ["d5", 1],["c#5", 1],["d5", 1],["c#5", 1],
             ["a#4", 1],["a4", 1],
             ["g#4", 1],["a#4", 1],["b4", 1],["b4", 1],
             ["g#4", 1],["a#4", 1],["b4", 1],["b4", 1],
             ["g#4", 1],["a#4", 1],["c5", 1],["c#5", 1],
             ["c5", 1],["c#5", 1],["c5", 1],["a4", 1],
             ["g#4", 1],
             ["c5", 2],["b4", 2],["a#4", 2],["f#5", 1]
    ]

    # a#5 f#5 f5 f#5 f5 d5 c#5 | c#5 d5 c#5 d5 c#5 a#4 a4
    
    print_notes(convert_to_rom_data(song4, NoteTable, LengthTable))

if __name__ == '__main__':
    main()