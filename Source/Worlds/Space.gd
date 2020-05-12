extends Spatial

var texture_loader = load("res://Source/Handlers/TextureLoader/TextureLoader.gd").new()
var block_list = BlockList.new()

var _prev_player_chunk_pos:Vector3
var _update_world_chunks:bool


func _ready():
	texture_loader.load_textures(block_list.BLOCKS.keys())

func _process(_delta):
	_update_player_chunk_pos()

func _update_player_chunk_pos():
	var player = get_node("Player")
	var player_chunk_pos = player.get_chunk_pos()
	if player_chunk_pos != _prev_player_chunk_pos:
		_prev_player_chunk_pos = player_chunk_pos
		get_node("WorldEarth").load_world(player_chunk_pos)
