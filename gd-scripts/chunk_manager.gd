extends Node
class_name ChunkManager

var chunk_scene: PackedScene = preload("res://scenes/chunk.tscn")

@onready var data_generator: DataGenerator = $"../DataGenerator"
@onready var chunk_gen_timer: ChunkGenTimer = $"../ChunkGenTimer"

@export var world_chunks: Vector3i
@export var chunks_start: Vector3i
@export var chunk_size: Vector3i
@export var voxel_size: float = 1.0

@export var n_threads: int = 4
var thread: Thread = Thread.new()
#var remeshing_chunks: Dictionary[Vector3i, bool] = {}

var chunk_data: Dictionary[Vector3i, PackedFloat32Array] = {}
var chunks: Dictionary[Vector3i, Chunk] = {}

func _ready() -> void:
	thread.start(generate_world)

func generate_world() -> void:
	for x: int in range(chunks_start.x-1, world_chunks.x+chunks_start.x+1):
		for y: int in range(chunks_start.y-1, world_chunks.y+chunks_start.y+1):
			for z: int in range(chunks_start.z-1, world_chunks.z+chunks_start.z+1):
				var pos: Vector3i = Vector3i(x, y, z)
				chunk_data[pos] = data_generator.generate_data(pos)
				
	for x: int in range(chunks_start.x, chunks_start.x+world_chunks.x):
		for y: int in range(chunks_start.y, chunks_start.y+world_chunks.y):
			for z: int in range(chunks_start.z, chunks_start.z+world_chunks.z):
				create_chunk(Vector3i(x, y, z))
	chunk_gen_timer.result()

func create_chunk(chunk_pos: Vector3i):
	for x: int in [-1, 0, 1]:
		for y: int in [-1, 0, 1]:
			for z: int in [-1, 0, 1]:
				if not chunk_data.has(Vector3i(chunk_pos.x+x, chunk_pos.y+y, chunk_pos.z+z)):
					return
	var chunk: Chunk = chunk_scene.instantiate()
	chunks[chunk_pos] = chunk
	chunk.position = Vector3(chunk_pos.x*chunk_size.x, chunk_pos.y*chunk_size.y, chunk_pos.z*chunk_size.z)*voxel_size
	chunk.init(self, chunk_pos)
	var start_time: int = Time.get_ticks_msec()
	chunk.create_mesh()
	chunk_gen_timer.add_chunk_time(Time.get_ticks_msec() - start_time)
	call_deferred("add_child", chunk)

func get_chunk(pos: Vector3) -> Vector3i:
	return Vector3i((pos / (chunk_size * voxel_size)).floor())

func dig(center: Vector3, radius: float) -> void:
	var affected_chunks: Array[Vector3i] = []
	var chunk_min: Vector3i = get_chunk(Vector3(center.x-radius, center.y-radius, center.z-radius))
	var chunk_max: Vector3i = get_chunk(Vector3(center.x+radius, center.y+radius, center.z+radius))
	
	for chunk_x: int in range(chunk_min.x, chunk_max.x+1):
		for chunk_y: int in range(chunk_min.y, chunk_max.y+1):
			for chunk_z: int in range(chunk_min.z, chunk_max.z+1):
				var chunk_pos: Vector3i = Vector3i(chunk_x, chunk_y, chunk_z)
				if not chunk_data.has(chunk_pos): 
					continue
				affected_chunks.append(chunk_pos)
	
	for chunk_pos in affected_chunks:
		for i in range(chunk_data[chunk_pos].size()):
			var x: int = i%(chunk_size.y)
			var y: int = floori(i/(chunk_size.x))%(chunk_size.x)
			var z: int = floori(i/((chunk_size.x) * (chunk_size.y)))
			var voxel_pos: Vector3 = (Vector3(x, y, z) + Vector3(chunk_pos * chunk_size)) * voxel_size
			var dist: float = sqrt((voxel_pos.x-center.x)**2 + (voxel_pos.y-center.y)**2 + (voxel_pos.z-center.z)**2)
			if dist < radius:
				chunk_data[chunk_pos][i] = clamp(chunk_data[chunk_pos][i] - 1 + dist/radius, 0, 1)
	
	for chunk_pos in affected_chunks:
		if not chunks.has(chunk_pos): 
			continue
		remesh_chunk(chunk_pos)

func remesh_chunk(chunk_pos: Vector3i):
	chunks[chunk_pos].create_mesh()
	chunks[chunk_pos].set_mesh()

func _exit_tree() -> void:
	thread.wait_to_finish()
