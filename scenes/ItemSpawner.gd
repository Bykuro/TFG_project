extends Node2D

@export var box_medicine:PackedScene = null
@export var box_ammo:PackedScene = null

var max_items
var current_items
var respawn_points_health:Array =[]
# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.spawn_item.connect(item_spawner_ammo)
	pass # Replace with function body.



func initialize(respawn_points_health_init: Array, respawn_points_ammo_init: Array ):
	respawn_points_health = respawn_points_health_init
	max_items = respawn_points_health_init.size()
	

func item_spawner_medicine():	#Spawns at specified points of the map via timer
	if	current_items < max_items:
		var box = box_medicine.instantiate()
		for i in respawn_points_health:
			if i.get_child_count() > 0:
				box.global_position = i.global_position
				i.add_child(box)
				return
	
	
func item_spawner_ammo(pos):	#Spawns on enemy death
	var box = box_ammo.instantiate()
	self.add_child(box)
	box.global_position = pos
	
	
func update_data():
	pass