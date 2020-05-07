var texture_template = load("res://Source/Loaders/TextureLoader/ResourceTemplate.gd")
var non_texture

func _init():
	non_texture = load("res://Resource/Blocks/Texture/missing_block.png").get_data()
	if non_texture.get_format() != 16: non_texture.convert(16)

func load_textures(block_names:Array):
	var resource_dir = Directory.new()
	if resource_dir.file_exists("res://Game/Resources/Textures.res"):
		var resource = load("res://Game/Resources/Textures.res")
		var valid = true
		for key in block_names:
			if not resource.images.has(key):
				valid = false
				break
		if valid: return
	create_new_save(block_names)
	
func create_new_save(block_names:Array):
	var dir = Directory.new()
	var new_texture_save = texture_template.new()
	var images = Dictionary()
	for name in block_names:
		var loaded_image
		var image_name = "res://Resource/Blocks/Texture/%s.png" % [name]
		if dir.file_exists(image_name):
			loaded_image = load(image_name).get_data()
			if loaded_image.get_format() != 16: loaded_image.convert(16)
			images[name] = loaded_image
		else: images[name] = non_texture
	new_texture_save.images = images
	if ResourceSaver.save("res://Game/Resources/Textures.res", new_texture_save) == FAILED:
		print("Texture Resource saving failed...")
	
