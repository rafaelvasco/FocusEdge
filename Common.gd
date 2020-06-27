extends Node

const WordMode = {
	Colors = "Colors",
	Letters = "Letters"
}

enum Directions {UP, DOWN, LEFT, RIGHT}

const PossibleDigits = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' ']
const PossibleColors = []

var Words = [
	"abcde",
	"12345"
]

static func GetRandomDigit():
	return PossibleDigits[randi() % PossibleDigits.size()]


static func GetRandomLetterWord(length):
	var result = ""
	for i in length:
		result += GetRandomDigit()
	return result

static func GetRandomDirection():
	var rand_i = randi() % 4
	match rand_i:
		0: return Directions.UP
		1: return Directions.DOWN
		2: return Directions.LEFT
		3: return Directions.RIGHT
