class_name ChunkGenTimer
extends Node

var mutex: Mutex = Mutex.new()
var total_time_ms: int = 0
var n_chunks: int = 0

func add_chunk_time(time_ms: int) -> void:
	mutex.lock()
	total_time_ms += time_ms
	n_chunks += 1
	mutex.unlock()
	
func result() -> void:
	var avarage: float = float(total_time_ms) / float(n_chunks)
	print("The avarage time to build a mesh was ", snapped(avarage, 0.01), " ms")
