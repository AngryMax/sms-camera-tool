extends StaticBody3D
class_name DragArrow

enum Axis {X, Y, Z}
var axis: Axis

var _sprite0: Sprite3D
var _sprite90: Sprite3D

func _ready() -> void:
	
	_makeSprites()
	add_child(_sprite0)
	add_child(_sprite90)
	
	var capsule := CapsuleShape3D.new()
	capsule.height = 1.0
	capsule.radius = 0.25
	
	var colShape := CollisionShape3D.new()
	colShape.shape = capsule
	colShape.debug_fill = true
	colShape.debug_color = _sprite0.modulate
	add_child(colShape)
	
	
	match (axis):
		Axis.X:
			position = Vector3(1, 0, 0)
			rotate_z(deg_to_rad(-90))
		Axis.Y:
			position = Vector3(0, 1, 0)
		Axis.Z:
			position = Vector3(0, 0, 1)
			rotate_x(deg_to_rad(90))
		_:
			print("Invalid axis! Deleting DragArrow self for debugging purposes!")
			queue_free()


func _makeSprites() -> void:
	
	for rotateBy in range(0, 91, 90):
		var sprite := Sprite3D.new()
		sprite.texture = preload("res://Resources/Images/3d view sprites/grabarrow.png")
		sprite.scale = Vector3(2, 2, 2)	
		sprite.rotation_degrees = Vector3(0, rotateBy, 0)
		sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
		
		match (axis):
			Axis.X:
				sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
			Axis.Y:
				sprite.modulate = Color(0.0, 1.0, 0.0, 1.0)
			Axis.Z:
				sprite.modulate = Color(0.0, 0.0, 1.0, 1.0)
		
		# Sets _sprit0 and _sprite90 to the newly created sprite
		set("_sprite" + str(rotateBy), sprite)
