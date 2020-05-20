class_name ChunkMeshGenerator

class BaseBlockFace:
	var _vertices
	var _texture_id

	func _init(block_position:Vector3, face_direction:Vector3, texture_id:String) -> void:
		_vertices = []
		_texture_id = texture_id 
		var ax1 = Vector3(face_direction.z, face_direction.x, face_direction.y)
		var ax2 = Vector3(face_direction.y, face_direction.z, face_direction.x)
		
		if face_direction.x == -1 || face_direction.y == -1 || face_direction.z == -1:
			_vertices.append(block_position + face_direction)
			_vertices.append(block_position + face_direction + ax1)
			_vertices.append(block_position + face_direction + ax1 + ax2)
			_vertices.append(block_position + face_direction + ax2)
		else:
			_vertices.append(block_position)
			_vertices.append(block_position - ax2)
			_vertices.append(block_position - ax1 - ax2)
			_vertices.append(block_position - ax1)
	
	func get_vertex(vertex_id:int) -> Vector3:
		if vertex_id < 0: vertex_id = 0
		elif vertex_id >= _vertices.size(): vertex_id = _vertices.size() - 1
		return _vertices[vertex_id]

	func get_texture_id() -> String:
		return _texture_id

class ChunkMeshTexture:
	var _texture_resource:MaterialoTextureListTemplate = load(MaterialoConstants.PATH_TEXTURE_LIST_RESOURCE)

	var _texture:ImageTexture
	var _cell_positions:Dictionary
	var _cell_textures:Dictionary
	var atlas_cell_size:int
	
	func _init(block_types:Array):
		_texture = ImageTexture.new()
		_cell_positions = Dictionary()
		_cell_textures = Dictionary()
		
		for block in block_types:
			var block_textures = _texture_resource.get_textures_from_block(block)
			for key in block_textures.keys():
				_cell_textures[key] = block_textures[key]
		
		if _cell_textures.size() > 0:
			atlas_cell_size = int(ceil(sqrt(_cell_textures.size())))
			var i = 0
			for key in _cell_textures.keys():
				var x = int(floor(i / atlas_cell_size)) * MaterialoConstants.BLOCK_TEXTURE_SIZE
				var y = (int(i) % atlas_cell_size) * MaterialoConstants.BLOCK_TEXTURE_SIZE
				_cell_positions[key] = Vector2(x, y)
				i += 1
			var atlas_size = atlas_cell_size * MaterialoConstants.BLOCK_TEXTURE_SIZE
			var image = Image.new()
			image.create(atlas_size, atlas_size, false, 16)
			
			for key in _cell_textures.keys():
				var cell_rectangle = Rect2(
					Vector2(0, 0),
					Vector2(
						MaterialoConstants.BLOCK_TEXTURE_SIZE,
						MaterialoConstants.BLOCK_TEXTURE_SIZE
					)
				)
				image.blit_rect(_cell_textures[key], cell_rectangle, _cell_positions[key])
				_texture.create_from_image(image, 2048)
	
	func get_texture_pos(name:String) -> Vector2:
		if _cell_positions.has(name):return _cell_positions[name]
		else: return Vector2(0, 0)
	
	func get_chunk_texture():
		return _texture
	
	func get_texture_dimensions():
		return atlas_cell_size




var surface_tool:SurfaceTool
var materialo_entities:MaterialoEntityListTemplate
var FACING_DIRECTIONS:Array
var CHUNK_SHADER = load("res://Resource/Shaders/ChunkShader.tres")

func _init():
	surface_tool = SurfaceTool.new()
	materialo_entities = load(MaterialoConstants.PATH_ENTITY_LIST_RESOURCE)
	FACING_DIRECTIONS = [
		Vector3(-1, 0, 0), Vector3(1, 0, 0),
		Vector3(0, -1, 0), Vector3(0, 1, 0),
		Vector3(0, 0, -1), Vector3(0, 0, 1)
	]

func get_chunk_mesh_2(chunk_map:ChunkMap, chunk_position:Vector3):

	var face_array:Array = []

	for y in range(MaterialoConstants.CHUNK_SIZE):
		for x in range(MaterialoConstants.CHUNK_SIZE):
			for z in range(MaterialoConstants.CHUNK_SIZE):
				var test_position = Vector3(x, y, z)
				var block:BaseBlock = chunk_map.get_block(chunk_position, test_position)
				if block != null:
					for direction in FACING_DIRECTIONS:
						var neighbour_block = chunk_map.get_block(chunk_position, test_position + direction)
						if neighbour_block == null:
							var texture_id = "%s:0" % [block.block_id] # TODO proper texture loading
							var block_face = BaseBlockFace.new(test_position, direction, texture_id)
							face_array.append(block_face)
					

func get_chunk_mesh(chunk_data:Array):
	var chunk_mesh:ArrayMesh = ArrayMesh.new()

	var chunk_blocks = chunk_data[0]
	var chunk_composition = chunk_data[1]

	var face_array = []
	var block_ids = []

	for y in range(MaterialoConstants.CHUNK_SIZE):
		for x in range(MaterialoConstants.CHUNK_SIZE):
			for z in range(MaterialoConstants.CHUNK_SIZE):
				var block_position = Vector3(x, y, z)
				if chunk_composition.keys().has(block_position):
					var block_id = chunk_blocks[chunk_composition[block_position]]
					if block_id != "void":
						if not block_ids.has(block_id): block_ids.append(block_id)
						var vd = [
							Vector3(-1, 0, 0), Vector3(1, 0, 0),
							Vector3(0, -1, 0), Vector3(0, 1, 0),
							Vector3(0, 0, -1), Vector3(0, 0, 1)
						]
						for v in vd:
							var neighbour_pos = block_position + v
							if !(chunk_composition.keys().has(neighbour_pos)) || chunk_composition[neighbour_pos] == 0:
								var texture_id = "%s:0" % [block_id] # TODO Proper texture loading
								var face = BaseBlockFace.new(block_position, v, texture_id)
								face_array.append(face)
	
	var block_array = []
	for id in block_ids:
		if id != "void":
			block_array.append(materialo_entities.BLOCK_LIST[id])
	var chunk_texture = ChunkMeshTexture.new(block_array)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in face_array:
		_add_face_to_mesh(surface_tool, face, chunk_texture)
	surface_tool.generate_normals()
	chunk_mesh = surface_tool.commit(chunk_mesh)
	
	var texture = chunk_texture.get_chunk_texture()
	var chunk_material = ShaderMaterial.new()
	chunk_material.set_shader(CHUNK_SHADER)
	chunk_material.set_shader_param("atlas_size", chunk_texture.get_texture_dimensions())
	chunk_material.set_shader_param("chunk_texture", texture)
	chunk_material.set_shader_param("texture_size", MaterialoConstants.BLOCK_TEXTURE_SIZE)
	if chunk_mesh.get_surface_count() > 0:
		chunk_mesh.surface_set_material(0, chunk_material)
	
	return chunk_mesh

func _add_face_to_mesh(st:SurfaceTool, face:BaseBlockFace, texture:ChunkMeshTexture):
	var pos = texture.get_texture_pos(face.get_texture_id())
	var posd = MaterialoConstants.BLOCK_TEXTURE_SIZE * texture.get_texture_dimensions()
	var pos0 = Vector2(pos.x, pos.y) / posd
	var pos1 = Vector2(pos.x + MaterialoConstants.BLOCK_TEXTURE_SIZE, pos.y + MaterialoConstants.BLOCK_TEXTURE_SIZE) / posd
	
	# First triangle
	st.add_uv(Vector2(pos0.x, pos0.y))
	st.add_vertex(face.get_vertex(0))
	st.add_uv(Vector2(pos1.x, pos0.y))
	st.add_vertex(face.get_vertex(1))
	st.add_uv(Vector2(pos1.x, pos1.y))
	st.add_vertex(face.get_vertex(2))
	# Second triangle
	st.add_uv(Vector2(pos0.x, pos0.y))
	st.add_vertex(face.get_vertex(0))
	st.add_uv(Vector2(pos1.x, pos1.y))
	st.add_vertex(face.get_vertex(2))
	st.add_uv(Vector2(pos0.x, pos1.y))
	st.add_vertex(face.get_vertex(3))
