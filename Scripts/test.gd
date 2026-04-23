extends Node3D

@export var pointDisplayDivScaler := 1000

const pointSpriteTex := preload("res://Resources/Images/3d view sprites/point2.png")

func _process(_delta: float) -> void:
	
	if get_parent().visible == false:
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	_control()


func _control() -> void:
	
	var movementVector := Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		movementVector.x += 1
	
	if Input.is_action_pressed("move_backward"):
		movementVector.x -= 1
	
	if Input.is_action_pressed("move_left"):
		movementVector.z -= 1
	
	if Input.is_action_pressed("move_right"):
		movementVector.z += 1
	
	if Input.is_action_pressed("move_up"):
		movementVector.y += 1
	elif Input.is_action_just_pressed("move_up"):	# Scrollwheel
		movementVector.y += 2
	
	if Input.is_action_pressed("move_down"):
		movementVector.y -= 1
	elif Input.is_action_just_pressed("move_down"):	# Scrollwheel
		movementVector.y -= 2
	
	if Input.is_action_pressed("move_slow"):
		movementVector *= 2.0
	
	movementVector /= 2.0
	
	%Camera3D.position += movementVector


func _getPoints() -> Array[Vector3]:
	
	var pointArray: Array[SMSCamPoint] = get_parent().get_parent().pointArray
	var posArray: Array[Vector3]
	
	for point in pointArray:
		posArray.append(point.position / pointDisplayDivScaler)
	
	return posArray


func _placePoints(posArray: Array[Vector3]) -> void:
	
	for point in posArray:
		var pointSprite := Sprite3D.new()
		pointSprite.texture = pointSpriteTex
		pointSprite.position = point
		pointSprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		%Points.add_child(pointSprite)
		
		%Path3D.curve.add_point(point)


func _setCamera(posArray: Array[Vector3]) -> void:
	
	var avgXZPos := Vector2.ZERO
	var highestY := posArray[0].y
	
	for pointPos in posArray:
		avgXZPos.x += pointPos.x
		avgXZPos.y += pointPos.z
		if pointPos.y > highestY:
			highestY = pointPos.y
	
	avgXZPos /= posArray.size()
	
	%Camera3D.position.x = avgXZPos.x
	%Camera3D.position.y = highestY + 20
	%Camera3D.position.z = avgXZPos.y

### Signals ###

func _on_d_view_popup_visibility_changed() -> void:
	var pointArray := _getPoints()
	_placePoints(pointArray)
	_setCamera(pointArray)
