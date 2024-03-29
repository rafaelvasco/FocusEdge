extends Node

const WordMode = {
	Colors = "Colors",
	Letters = "Letters"
}

enum SpecialAxisBeahaviors { EasyTarget }
enum Directions {Up, Down, Left, Right}


const PossibleLetters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
const PossibleColors = []

static func GetRandomDigit():
	return PossibleLetters[randi() % PossibleLetters.size()]


static func GetRandomLetterWord(length):
	var result = ""
	for i in length:
		result += GetRandomDigit()
	return result

static func GetRandomDirection():
	var rand_i = randi() % 4
	match rand_i:
		0: return Directions.Up
		1: return Directions.Down
		2: return Directions.Left
		3: return Directions.Right
