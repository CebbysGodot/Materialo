extends Resource
class_name Chunk

const chunk_size = 16
export(int) var chunk_x
export(int) var chunk_y
export(int) var chunk_z
# Multidimensional array, size of 2. First element of array is
# array (value:string block_name) index is latter used`id`. Second element
# is dictionary (key:Vector3 position in chunk, value:int id)
export(Array) var chunk_data
