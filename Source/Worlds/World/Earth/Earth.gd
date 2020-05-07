tool extends BaseWorld
class_name WorldEarth



func _init().("earth"):
	WORLD_GENERATOR = load("res://Source/Worlds/World/Earth/EarthGenerator.gd").new()

func _ready():
	pass # Replace with function body.
