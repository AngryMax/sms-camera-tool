extends Node3D

func _process(_delta: float) -> void:
	if get_parent().visible == false:
		print("not vis")
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED

func _physics_process(delta: float) -> void:
	%Camera3D.rotate_y(delta / 2.0)
