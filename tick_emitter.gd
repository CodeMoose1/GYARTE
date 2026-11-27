extends Node

signal tick(count: int)

@export var tick_interval: float = 0.05 # 20 ticks per second

var _accumulator: float = 0.0
var _tick_count: int = 0

func _physics_process(delta: float) -> void:
	_accumulator += delta
	while _accumulator >= tick_interval:
		_accumulator -= tick_interval
		_tick_count += 1
		tick.emit(_tick_count)
