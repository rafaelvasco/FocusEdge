extends Node

var last_word_index = 0

const Words = [
	"Love",
	"Light",
	"One",
	"Shadow",
	"Purpose",
	"Life",
	"Spirit",
	"Soul",
	"Materialistic",
	"Energy",
	"Poetry",
	"Mind",
	"Kindness",
	"Meditation",
	"Introspection",
	"Focus",
	"Empty",
	"Full",
	"Sun",
	"Moon",
	"Fire",
	"Water",
	"Air",
	"Earth",
	"Ether",
	"Believe",
	"Door",
	"Space",
	"Astral",
	"Project",
	"Change",
	"Build",
	"Think",
	"Eternity",
	"Time",
	"Timeless",
	"Origin",
	"Gold",
	"Silver",
	"Diamond",
	"Service",
	"Discipline",
	"House",
	"Temple",
	"Body",
	"Concentration",
	"Mindless",
	"Vortex",
	"Pyramid",
	"Crystal",
	"Sphere",
	"Circle",
	"Pendulum",
	"Map",
	"Friendship",
	"Brother",
	"Sister",
	"Father",
	"Mother",
	"Prayer",
	"Mantra",
	"Tantra"
]


func generate():
	var index = randi() % Words.size()
	while index == last_word_index:
		index = randi() % Words.size()
		
	last_word_index = index
	return Words[index]

