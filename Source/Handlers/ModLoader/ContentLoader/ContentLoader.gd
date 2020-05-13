tool
class_name MaterialoContentLoader

var BLOCK_LOADER
var MATERIALO_ENTITY_LIST:MaterialoEntityListTemplate

func _init():
	BLOCK_LOADER = MaterialoBlockLoader.new()


func generate_content(mod_structures:Array):
	_load_entity_list()
	for mod in mod_structures:
		_load_content(mod)



func _load_content(mod:MaterialoModStructure):
	MATERIALO_ENTITY_LIST = BLOCK_LOADER.load_block_list(MATERIALO_ENTITY_LIST, mod)
	_save_entity_list()

func _load_entity_list():
	var directory_parser = Directory.new()
	if not directory_parser.dir_exists(MaterialoConstants.PATH_ENTITY_LIST):
		directory_parser.make_dir_recursive(MaterialoConstants.PATH_ENTITY_LIST)
	if not directory_parser.file_exists(MaterialoConstants.PATH_ENTITY_LIST_RESOURCE):
		if ResourceSaver.save(
			MaterialoConstants.PATH_ENTITY_LIST_RESOURCE,
			MaterialoEntityListTemplate.new()
		) == FAILED: print("Saving entity list failed")
	MATERIALO_ENTITY_LIST = load(MaterialoConstants.PATH_ENTITY_LIST_RESOURCE)

func _save_entity_list():
	if ResourceSaver.save(
		MaterialoConstants.PATH_ENTITY_LIST_RESOURCE,
		MATERIALO_ENTITY_LIST
	) == OK:
		print("Materialo Entity List Saved Successfully")
