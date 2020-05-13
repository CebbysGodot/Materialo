tool extends Resource
class_name MaterialoModStructure

export(String) var mod_base_folder
export(String) var mod_id
export(Array) var mod_block_folder_paths

func _init( mod_base_folder_path:String, mod_json:Dictionary ):
	mod_id = mod_json["mod_id"]
	mod_base_folder = mod_base_folder_path
	
	if mod_json.has("block_folders"):
		mod_block_folder_paths = mod_json["block_folders"]
	else:
		mod_block_folder_paths = []

func get_block_id(block_name:String) -> String:
	var id = "%s:block:%s" % [mod_id, block_name]
	return id
