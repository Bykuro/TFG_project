extends Node2D

@onready var capturable_base_manager = $CapturableBaseManager
@onready var enemy_ai = $EnemyMapAI
@onready var bullet_manager = $BulletManager
@onready var player: Player = $Player
@onready var ground = $Ground
@onready var pathfinding = $Pathfinding
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	GlobalSignals.bullet_fired.connect(bullet_manager.handle_bullet_spawned)
	
	pathfinding.create_navigation_map(ground)
	
	var bases = capturable_base_manager.get_capturable_bases()
	enemy_ai.initialize(bases,pathfinding)
