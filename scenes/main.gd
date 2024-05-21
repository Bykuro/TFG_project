extends Node2D

const player_const = preload("res://actors/Player.tscn")

@onready var capturable_base_manager = $CapturableBaseManager
@onready var enemy_ai = $EnemyMapAI
@onready var bullet_manager = $BulletManager
@onready var ground = $Ground
@onready var pathfinding = $Pathfinding
@onready var camera = $Camera2D
@onready var gui = $GUI
@onready var director = $AIDirector
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	GlobalSignals.bullet_fired.connect(bullet_manager.handle_bullet_spawned)
	
	var enemy_respawns = $EnemyRespawnPoints
	pathfinding.create_navigation_map(ground)
	
	var bases = capturable_base_manager.get_capturable_bases()
	enemy_ai.initialize(bases,pathfinding,enemy_respawns.get_children())
	
	director.initialize(bases)
	spawn_player()

func spawn_player():
	var player = player_const.instantiate()
	add_child(player)
	player.set_camera_transform(camera.get_path())
	gui.set_player(player)
	
