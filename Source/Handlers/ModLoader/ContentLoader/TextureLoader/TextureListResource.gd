tool extends Resource
class_name MaterialoTextureListTemplate

export(Dictionary) var BLOCK_TEXTURE_LIST

func get_textures_from_block(block:BaseBlock) -> Dictionary:
    var textures = Dictionary()
    for id in block.get_block_textures().keys():
        var string = "%s:%s" % [block.get_block_id(), id]
        textures[string] = BLOCK_TEXTURE_LIST[string]
    return textures