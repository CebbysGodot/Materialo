tool
class_name MaterialoBlockLoader

func create_block( block_json:Dictionary ):
	var block = BaseBlock.new()
	block.block_name = block_json[ "name" ]

	return block

func load_block_list( materialo_entities:MaterialoEntityListTemplate, structure:MaterialoModStructure ):
	var directory_parser = Directory.new()
	var file_parser = File.new()
	
	var block_folders = structure.mod_block_folder_paths
	for folder in block_folders:
		var path = "%s%s" % [ structure.mod_base_folder, folder ]
		if directory_parser.open( path ) == OK:
			directory_parser.list_dir_begin()
			var block_json = directory_parser.get_next()
			while block_json != "":
				if not directory_parser.current_is_dir():
					var json_path = "%s%s" % [ path, block_json ]
					file_parser.open( json_path, File.READ )
					var block = create_block( parse_json( file_parser.get_as_text() ) )
					var block_id = structure.get_block_id( block.block_name )
					materialo_entities.BLOCK_LIST[ block_id ] = block

				block_json = directory_parser.get_next()
			directory_parser.list_dir_end()
		else: print( "Opening block dir[%s] failed!" % [ path ] )

	return materialo_entities
