tool

class Face:
	var _vertices
	var _inverted
	var _texture

	func _init(pos:Vector3, dir:Vector3, name:String):
		_vertices = []
		_texture = name
		_inverted = (dir.x == -1 || dir.y == -1 || dir.z == -1)
		var neg = _inverted
		
		var ax1 = Vector3(dir.z, dir.x, dir.y)
		var ax2 = Vector3(dir.y, dir.z, dir.x)
		
		if neg:
			_vertices.append(pos)
			_vertices.append(pos - ax1)
			_vertices.append(pos - ax1 - ax2)
			_vertices.append(pos - ax2)
		else:
			_vertices.append(pos + dir)
			_vertices.append(pos + dir + ax1)
			_vertices.append(pos + dir + ax1 + ax2)
			_vertices.append(pos + dir + ax2)
	
	func get_vertex(id:int) -> Vector3:
		if id < 0: id = 0
		if id >= _vertices.size(): id = _vertices.size()
		return _vertices[id]

	func is_inverted() -> bool:
		return !_inverted
	
	func get_texture_name() -> String:
		return _texture

class ChunkTexture:
	const _texture_size:int = 64
	var image_resource = load("res://Game/Resources/Textures.res")
	
	var _texture:ImageTexture
	var _image_dict:Dictionary
	var _pos_names:Dictionary
	var _texture_dimensions:int
	
	func _init(block_types:Array):
		_texture = ImageTexture.new()
		_image_dict = Dictionary()
		_pos_names = Dictionary()
		
		var d = 0; while (d * d) < block_types.size(): d = d + 1
		_texture_dimensions = d
		for i in range(block_types.size()):
			var x = int(floor(i / d))
			var y = int(i % d)
			var name = block_types[i]
			_pos_names[name] = Vector2(x, y)
			_image_dict[name] = image_resource.images[name + "_block"]
			
		var dimensions = _texture_size * d
		if dimensions > 0:
			var image = Image.new()
			image.create(dimensions, dimensions, false, 16)
			for name in block_types:
				var src_image = _image_dict[name]
				var src_rect = Rect2(Vector2(0, 0), Vector2(_texture_size, _texture_size))
				var src_pos = _pos_names[name] * _texture_size
				image.blit_rect(src_image, src_rect, Vector2(src_pos.x, src_pos.y))
			_texture.create_from_image(image, 2048)

	func print_texture_names():
		print(_pos_names)
		print(_image_dict)
	
	func get_texture_pos(name:String) -> Vector2:
		if _pos_names.has(name):return _pos_names[name]
		else: return Vector2(0, 0)
	
	func get_chunk_texture():
		return _texture
	
	func get_texture_dimensions():
		return _texture_dimensions

func update_mesh(_chunk:Chunk, _chunk_material:ShaderMaterial = null):
	var surface_tool = SurfaceTool.new()
	
	var chunk_blocks = _chunk.CHUNK_BLOCKS
	var chunk_size = _chunk.CHUNK_SIZE
	
	var chunk_mesh = ArrayMesh.new()
	var face_array = []
	var texture_types = Dictionary()
	
	for y in range(chunk_size):
		for x in range(chunk_size):
			for z in range(chunk_size):
				if chunk_blocks.has(Vector3(x, y, z)):
					
					var block = chunk_blocks[Vector3(x, y, z)].get_block_name()
					if not texture_types.has(block): texture_types[block] = texture_types.size()
					
					if x > 0 || true:
						if not chunk_blocks.has(Vector3(x - 1, y, z)):
							var face = Face.new(Vector3(x, y, z), Vector3(-1, 0, 0), block)
							face_array.append(face)
					if x < chunk_size - 1 || true:
						if not chunk_blocks.has(Vector3(x + 1, y, z)):
							var face = Face.new(Vector3(x, y, z), Vector3(1, 0, 0), block)
							face_array.append(face)
					
					if y > 0 || true:
						if not chunk_blocks.has(Vector3(x, y - 1, z)):
							var face = Face.new(Vector3(x, y, z), Vector3(0, -1, 0), block)
							face_array.append(face)
					if y < chunk_size - 1 || true:
						if not chunk_blocks.has(Vector3(x, y + 1, z)):
							var face = Face.new(Vector3(x, y, z), Vector3(0, 1, 0), block)
							face_array.append(face)
					
					if z > 0 || true:
						if not chunk_blocks.has(Vector3(x, y, z - 1)):
							var face = Face.new(Vector3(x, y, z), Vector3(0, 0, -1), block)
							face_array.append(face)
					if z < chunk_size - 1 || true:
						if not chunk_blocks.has(Vector3(x, y, z + 1)):
							var face = Face.new(Vector3(x, y, z), Vector3(0, 0, 1), block)
							face_array.append(face)
	
	var chunk_texture = ChunkTexture.new(texture_types.keys())
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in face_array:
		_add_face_to_mesh(surface_tool, face, chunk_texture)
	surface_tool.generate_normals()
	surface_tool.commit(chunk_mesh)
	
	var texture = chunk_texture.get_chunk_texture()
	_chunk_material.set_shader_param("atlas_size", chunk_texture.get_texture_dimensions())
	_chunk_material.set_shader_param("chunk_texture", texture)
	_chunk_material.set_shader_param("texture_size", 64)
	if chunk_mesh.get_surface_count() > 0:
		chunk_mesh.surface_set_material(0, _chunk_material)
	
	return chunk_mesh

func _add_face_to_mesh(st:SurfaceTool, face:Face, texture:ChunkTexture):
	var dim = texture.get_texture_dimensions()
	var pos = texture.get_texture_pos(face.get_texture_name())
	
	var d = 1.0 / dim
	var x0 = pos.x * d
	var x1 = x0 + d
	var y0 = pos.y * d
	var y1 = y0 + d
	
	if face.is_inverted(): 
		# First triangle
		st.add_uv(Vector2(x0, y0))
		st.add_vertex(face.get_vertex(0))
		st.add_uv(Vector2(x1, y0))
		st.add_vertex(face.get_vertex(3))
		st.add_uv(Vector2(x1, y1))
		st.add_vertex(face.get_vertex(2))
		# Second triangle
		st.add_uv(Vector2(x0, y0))
		st.add_vertex(face.get_vertex(0))
		st.add_uv(Vector2(x1, y1))
		st.add_vertex(face.get_vertex(2))
		st.add_uv(Vector2(x0, y1))
		st.add_vertex(face.get_vertex(1))
	else:
		# First triangle
		st.add_uv(Vector2(x0, y0))
		st.add_vertex(face.get_vertex(0))
		st.add_uv(Vector2(x1, y0))
		st.add_vertex(face.get_vertex(1))
		st.add_uv(Vector2(x1, y1))
		st.add_vertex(face.get_vertex(2))
		# Second triangle
		st.add_uv(Vector2(x0, y0))
		st.add_vertex(face.get_vertex(0))
		st.add_uv(Vector2(x1, y1))
		st.add_vertex(face.get_vertex(2))
		st.add_uv(Vector2(x0, y1))
		st.add_vertex(face.get_vertex(3))
