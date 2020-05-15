tool
class_name MaterialoTextureLoader

var directory_parser:Directory

var TEXTURE_LIST_RESOURCE:MaterialoTextureListTemplate
var ENTITY_LIST_RESOURCE:MaterialoEntityListTemplate

func _init():
	directory_parser = Directory.new()

func initialise():
	TEXTURE_LIST_RESOURCE = MaterialoTextureListTemplate.new()
	ENTITY_LIST_RESOURCE = load(MaterialoConstants.PATH_ENTITY_LIST_RESOURCE)

func save_resource():
	if TEXTURE_LIST_RESOURCE != null:
		if ResourceSaver.save(MaterialoConstants.PATH_TEXTURE_LIST_RESOURCE, TEXTURE_LIST_RESOURCE) == OK:
			print("Texture Resource Saving was successful...")
			return OK
	print("Texture Resource Saving failed...")
	return FAILED

func load_block_textures(mod:MaterialoModStructure):
	for block_key in ENTITY_LIST_RESOURCE.BLOCK_LIST.keys():
		var block = ENTITY_LIST_RESOURCE.BLOCK_LIST[block_key]
		var texture_dictionary = block.block_model.model_textures
		var ids = block.block_model.model_textures.keys()
		for id in ids:
			var full_path = "%s%s" % [mod.mod_base_folder, texture_dictionary[id]]
			var full_id = "%s:%s" % [block_key, id]
			var texture
			if directory_parser.file_exists(full_path):
				texture = load(full_path).get_data()
			else:
				texture = load(MaterialoConstants.PATH_MISSING_TEXTURE).get_data()
			if texture.get_format() != 16: texture.convert(16)
			TEXTURE_LIST_RESOURCE.BLOCK_TEXTURE_LIST[full_id] = texture
