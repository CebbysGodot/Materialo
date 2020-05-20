tool extends Resource
class_name BaseBlock

export(String) var block_name
export(Resource) var block_model
export(String) var block_id

func get_class() -> String:
    return "BaseBlock"

func get_block_name() -> String:
    return block_name

func get_block_textures() -> Dictionary:
    return block_model.model_textures

func get_block_id() -> String:
    return block_id

func get_block_model():
    return block_model