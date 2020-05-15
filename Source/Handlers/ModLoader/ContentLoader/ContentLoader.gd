tool
class_name MaterialoContentLoader

var BLOCK_LOADER:MaterialoBlockLoader
var TEXTURE_LOADER:MaterialoTextureLoader
var MATERIALO_ENTITY_LIST:MaterialoEntityListTemplate

func _init():
	BLOCK_LOADER = MaterialoBlockLoader.new()
	TEXTURE_LOADER = MaterialoTextureLoader.new()


func generate_content(mod_structures:Array):
	load_entity_list()
	for mod in mod_structures:
		load_content(mod)
		load_content_textures(mod)



func load_content(mod:MaterialoModStructure):
	MATERIALO_ENTITY_LIST = BLOCK_LOADER.load_block_list(MATERIALO_ENTITY_LIST, mod)
	save_entity_list()

func load_content_textures(mod:MaterialoModStructure):
	TEXTURE_LOADER.initialise()
	TEXTURE_LOADER.load_block_textures(mod)
	TEXTURE_LOADER.save_resource()

func load_entity_list():
	var directory_parser = Directory.new()
	if not directory_parser.dir_exists(MaterialoConstants.PATH_RESOURCES):
		directory_parser.make_dir_recursive(MaterialoConstants.PATH_RESOURCES)
	if not directory_parser.file_exists(MaterialoConstants.PATH_ENTITY_LIST_RESOURCE):
		if ResourceSaver.save(
			MaterialoConstants.PATH_ENTITY_LIST_RESOURCE,
			MaterialoEntityListTemplate.new()
		) == FAILED: print("Saving entity list failed")
	MATERIALO_ENTITY_LIST = load(MaterialoConstants.PATH_ENTITY_LIST_RESOURCE)

func save_entity_list():
	if ResourceSaver.save(
		MaterialoConstants.PATH_ENTITY_LIST_RESOURCE,
		MATERIALO_ENTITY_LIST
	) == OK:
		print("Materialo Entity List Saved Successfully")
