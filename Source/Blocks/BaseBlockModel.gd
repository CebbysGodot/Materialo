tool extends Resource
class_name BaseBlockModel

export(Dictionary) var model_textures
export(Array) var model_faces

func get_class() -> String:
    return "BaseBlockModel"

func get_face_texture_id(_face_index:int):
    pass