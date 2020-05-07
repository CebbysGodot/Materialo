tool extends Spatial
class_name BaseWorld

var WORLD_CHUNKS:Dictionary
var WORLD_INIT_SIZE:int = 2
var WORLD_INIT_HEIGHT:int = 2
var WORLD_VIEW_DISTANCE:int = 2
var WORLD_NAME
export(Script) var WORLD_GENERATOR
var DISPLAY_CHUNKS:Spatial

var GEN_THREAD:Thread
var GEN_MUTEX:Mutex
var GEN_SEMAPHORE:Semaphore
var GEN_EXIT:bool
var GEN_GENERATING:bool

var GEN_CHUNKMAP:Dictionary
var GEN_POSITION:Vector3


const GEN_VIEW_RANGE = 1

func _ready():
	# Variable init
	GEN_THREAD = Thread.new()
	GEN_MUTEX = Mutex.new()
	GEN_SEMAPHORE = Semaphore.new()
	GEN_EXIT = false
	GEN_POSITION = Vector3(-1, -1, -1)
	
	add_child(DISPLAY_CHUNKS)
	
	GEN_THREAD.start(self, "t_update_chunkmap")
	update_chunkmap(Vector3(0, 0, 0))

func t_update_chunkmap(_void):
	print("Thread started")
	var _t_genque = []
	var _t_displaychunks = Dictionary()
	
	while true:
		GEN_SEMAPHORE.wait()
		
		GEN_MUTEX.lock()
		var exit = GEN_EXIT
		GEN_MUTEX.unlock()
		
		if exit: break
		
		print("Generating chunkmap")
		GEN_MUTEX.lock()
		var v = GEN_VIEW_RANGE
		var d = v * 2 + 1
		var g_pos = GEN_POSITION
		var t_chunkmap = GEN_CHUNKMAP.duplicate(true)
		GEN_MUTEX.unlock()
		
		var names = Dictionary()
		for y in range(d):
			for x in range(d):
				for z in range(d):
					var pos = Vector3(
						x - v + g_pos.x,
						y - v + g_pos.y,
						z - v + g_pos.z)
					names["%s_%s_%s" % [pos.x, pos.y, pos.z]] = pos
					if not t_chunkmap.has(pos) || (t_chunkmap.has(pos) and t_chunkmap[pos] == null):
						var chunk = ChunkOld.new(pos)
						t_chunkmap[pos] = chunk
		
#		print("Instancing data")
#		for child in DISPLAY_CHUNKS.get_children():
#			var c_name = child.get_name()
#			print("Erasing [%s]" % [c_name])
#			if not names.keys().has(c_name):
#				DISPLAY_CHUNKS.call_deferred("remove_child", child)
#			else: names.erase(c_name)

		print("Adding children")
		for n in names.keys():
			var n_chunk = t_chunkmap[names[n]]
			n_chunk.set_name(n)
			DISPLAY_CHUNKS.call_deferred("add_child", n_chunk)

#		GEN_MUTEX.lock()
#		GEN_CHUNKMAP = t_chunkmap.duplicate(true)
#		GEN_MUTEX.unlock()
		print("Generation finished")

func update_chunkmap(pos:Vector3):
	GEN_MUTEX.lock()
	GEN_POSITION = pos
	GEN_MUTEX.unlock()
	GEN_SEMAPHORE.post()

func _init(world_name:String):
	WORLD_NAME = world_name
	DISPLAY_CHUNKS = Spatial.new()

func load_world(player_chunk_pos:Vector3):
	var pos = Vector3(
		int(player_chunk_pos.x),
		int(player_chunk_pos.y),
		int(player_chunk_pos.z)
	)
	update_chunkmap(pos)

func _exit_tree():
	print("Exiting")
	GEN_MUTEX.lock()
	GEN_EXIT = true
	GEN_MUTEX.unlock()
	GEN_SEMAPHORE.post()
	GEN_THREAD.wait_to_finish()
