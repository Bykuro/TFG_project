extends Node2D

@export var box_medicine:PackedScene = null
@export var box_ammo:PackedScene = null

var current_items
var respawn_points_health:Array =[]
@onready var time = $Timer
@onready var ammo_parent = $AmmoParent
# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.spawn_item.connect(item_spawner_ammo)
	GlobalSignals.send_config_values.connect(get_new_respawn_timer)
	pass # Replace with function body.
	time.start()


func get_new_respawn_timer(new_config):
	time.wait_time = new_config.respawn_timer

func initialize(respawn_points_health_init: Array):
	respawn_points_health = respawn_points_health_init
	

func item_spawner_medicine():	#Spawns at specified points of the map via timer
	
	for i in respawn_points_health:
		if i.get_child_count() == 0:
			var box = box_medicine.instantiate()
			i.add_child(box)
			box.global_position = i.global_position
			time.start()
			return
	
	
func item_spawner_ammo(pos):	#Spawns on enemy death
	var box = box_ammo.instantiate()
	ammo_parent.add_child(box)
	box.global_position = pos
	
	
func update_data():
	pass


func _on_timer_timeout():
	item_spawner_medicine()
