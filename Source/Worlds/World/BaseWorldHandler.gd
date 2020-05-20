extends Node
class_name BaseWorldHandler

export(Script) var world_resource_template = load("res://Source/Worlds/World/BaseWorldResource.gd")
export(String) var world_name
var world_resource:BaseWorldResource

func _ready():
	pass

func _add_data_to_resource(_chunk:Chunk):
	var l_dir = Directory.new()
	var l_dirname = "res://Game/Resources/Worlds/%s/Chunkmap/Chunks/" % world_name
	if not l_dir.dir_exists(l_dirname):
		if l_dir.make_dir_recursive(l_dirname) != OK: print("Creating directory failed. Dir: [%s]" % [l_dirname])
	



	var l_key = Vector3(_chunk.chunk_x, _chunk.chunk_y, _chunk.chunk_z)
	var l_chunk_name = "%s_%s_%s" % [_chunk.chunk_x, _chunk.chunk_y, _chunk.chunk_z]
	var l_value = "res://Game/Resources/Worlds/%s/Chunkmap/Chunks/%s.tres" % [world_name, l_chunk_name]
	world_resource.CHUNK_DATA_REFERENCE[l_key] = l_value

func _load_world_resource():
	pass

func _save_world_resource():
	pass

func _create_world_resource():
	var l_dir = Directory.new()
	var l_new_resource = world_resource_template.new()
