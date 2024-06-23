extends Node2D

enum Difficulty{
	EASY,
	NORMAL,
	HARD,
	DIRECTOR
}

var HEALTH_THRESHOLD_COEFICIENT: float = 1.5
var ENEMIES_KILLED_THRESHOLD: int = 30
var MAX_ENEMY_THRESHOLD: int = 40
var MAX_ENEMIES_PER_WAVE: int = 4
var ENEMY_MULTIPLIER: float = 1
var difficulty_chosen : Difficulty = Difficulty.DIRECTOR
