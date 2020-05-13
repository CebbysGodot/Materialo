tool
class_name MaterialoModLoader

var CONTENT_LOADER:MaterialoContentLoader

func _init():
	CONTENT_LOADER = MaterialoContentLoader.new()

func load_mods():
	print("Starting to load mods")
	var directory_parser = Directory.new()
	var file_parser = File.new()

	if not directory_parser.dir_exists(MaterialoConstants.PATH_MOD_DIRECTORY):
		directory_parser.make_dir_recursive(MaterialoConstants.PATH_MOD_DIRECTORY)
		return
	
	print("Finding mod base folders")
	var mod_folders = []
	if directory_parser.open(MaterialoConstants.PATH_MOD_DIRECTORY) == OK:
		directory_parser.list_dir_begin()
		var mod_folder = directory_parser.get_next()
		while mod_folder != "":
			if directory_parser.current_is_dir() and not ( mod_folder == "." || mod_folder == ".." ):
				mod_folders.append( mod_folder )
			mod_folder = directory_parser.get_next()

	print("Generating mod structures")
	var mod_structures = []
	for mod_folder_name in mod_folders:
		var mod_base_folder = "%s%s/" % [ MaterialoConstants.PATH_MOD_DIRECTORY, mod_folder_name ]
		var mod_json_path = "%smod.json" % [ mod_base_folder ]
		if directory_parser.file_exists( mod_json_path ):
			file_parser.open( mod_json_path, File.READ )
			var mod_json = parse_json( file_parser.get_as_text() )
			file_parser.close()
			if is_valid_mod_json( mod_json ):
				print( "Valid mod to load[%s]" % [ mod_json[ "mod_id" ] ] )
				var mod = MaterialoModStructure.new( mod_base_folder, mod_json )
				mod_structures.append( mod )

	CONTENT_LOADER.generate_content( mod_structures )

func is_valid_mod_json( mod_json:Dictionary ) -> bool:
	if not (
		mod_json.has("mod_id")
	): return false
	return true

