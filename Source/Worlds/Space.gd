extends Spatial

# var texture_loader = load("res://Source/Handlers/TextureLoader/TextureLoader.gd").new()

var _prev_player_chunk_pos:Vector3
var _update_world_chunks:bool

var mod_loader

func _init():
	mod_loader = MaterialoModLoader.new()
func _ready():
	mod_loader.load_mods()
#	texture_loader.load_textures(block_list.BLOCKS.keys())

func _process(_delta):
	pass
#	_update_player_chunk_pos()
#
#func _update_player_chunk_pos():
#	var player = get_node("Player")
#	var player_chunk_pos = player.get_chunk_pos()
#	if player_chunk_pos != _prev_player_chunk_pos:
#		_prev_player_chunk_pos = player_chunk_pos
#		get_node("WorldEarth").load_world(player_chunk_pos)
