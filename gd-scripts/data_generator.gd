extends Node
class_name DataGenerator

@onready var chunk_manager: ChunkManager = $"../ChunkManager"

enum TERRAIN_TYPE {HEIGHT_MAP, _3D, PLANET}

@export var type: TERRAIN_TYPE

@export_group("HeightMapValues", "hm_")
@export var hm_height: float = 30.0
@export var hm_noise: FastNoiseLite

@export_group("3DTerrainValues", "_3d_")
@export var _3d_noise: FastNoiseLite
@export var _3d_cutoff: float

@export_group("PlanetValues", "p_")
@export var p_radius: float
@export var p_noise: FastNoiseLite
@export var p_height: float

func _world_pos(chunk: Vector3i, voxel: Vector3i) -> Vector3:
	return Vector3(chunk*chunk_manager.chunk_size + voxel) * chunk_manager.voxel_size

func generate_data(chunk: Vector3i) -> PackedFloat32Array:
	var data: PackedFloat32Array = []
	data.resize(chunk_manager.chunk_size.x * chunk_manager.chunk_size.y * chunk_manager.chunk_size.z)
	match type:
		TERRAIN_TYPE.HEIGHT_MAP:
			var noise_values: Dictionary[Vector2i, float] = {}
			for x in range(chunk_manager.chunk_size.x):
				for z in range(chunk_manager.chunk_size.z):
					var pos: Vector2 = Vector2(chunk.x*chunk_manager.chunk_size.x+x, chunk.z*chunk_manager.chunk_size.z+z)*chunk_manager.voxel_size
					var value: float = hm_noise.get_noise_2dv(pos) + 1.0
					noise_values[Vector2i(x, z)] = value
			
			var index: int = 0
			for z in range(chunk_manager.chunk_size.z):
				for y in range(chunk_manager.chunk_size.y):
					var voxel_height: float = (chunk.y*chunk_manager.chunk_size.y+y)*chunk_manager.voxel_size
					for x in range(chunk_manager.chunk_size.x):
						data[index] = clampf((noise_values[Vector2i(x, z)] * hm_height)/4 - voxel_height/4, 0.0, 1.0)
						index += 1
			
		TERRAIN_TYPE._3D:
			var index: int = 0
			for z: int in range(chunk_manager.chunk_size.z):
				for y: int in range(chunk_manager.chunk_size.y):
					for x: int in range(chunk_manager.chunk_size.x):
						var value: float = clampf(_3d_noise.get_noise_3dv(_world_pos(chunk, Vector3i(x, y, z)))/2 + 0.5, 0.0, 1.0)
						data[index] = value
						index += 1
			
		TERRAIN_TYPE.PLANET:
			var index: int = 0
			for z in range(chunk_manager.chunk_size.z):
				for y in range(chunk_manager.chunk_size.y):
					for x in range(chunk_manager.chunk_size.x):
						var global_voxel_pos = _world_pos(chunk, Vector3i(x, y, z))
						var surface_pos: Vector3 = global_voxel_pos.normalized()*p_radius
						data[index] = clampf(p_noise.get_noise_3dv(surface_pos) * p_height + p_radius - global_voxel_pos.length(), 0.0, 1.0)
						
						index += 1
			
	return data
