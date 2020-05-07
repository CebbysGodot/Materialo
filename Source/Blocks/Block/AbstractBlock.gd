tool extends Spatial

var BLOCK_BODY = StaticBody.new()
var BLOCK_COLLIDER = CollisionShape.new()
var BLOCK_MESH = MeshInstance.new()

var _block_name:String

func _init(name:String = "block"):
	_block_name = name
	# Node naming
	set_name(_block_name)
	BLOCK_BODY.set_name("block_body")
	BLOCK_COLLIDER.set_name("block_collider")
	BLOCK_MESH.set_name("block_mesh")
	# Node Parenting
	add_child(BLOCK_BODY)
	BLOCK_BODY.add_child(BLOCK_COLLIDER)
	BLOCK_COLLIDER.add_child(BLOCK_MESH)
	# Node init
	var mesh = load("res://Resource/Models/block_aaaaaa.obj")
	BLOCK_MESH.mesh = mesh
	var material = ShaderMaterial.new()
	# material.shader = load("res://Resource/Blocks/Shader/%s.tres" % [_block_name])
	material.shader = load("res://Resource/Blocks/Shader/cobblestone.tres")
	material.set_shader_param("block_texture", load("res://Resource/Blocks/Texture/%s.png" % [_block_name]))
	BLOCK_MESH.mesh.surface_set_material(0, material)

func get_block_name():
	return _block_name
