extends Node

@onready var child: Child = $Child

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	child.HelloWorld()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
