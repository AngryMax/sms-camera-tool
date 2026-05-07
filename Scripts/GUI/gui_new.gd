extends Control

@export var editViewportCamera: Camera3D

var keyframe: CamKeyframe:
	set(value):
		keyframe = value
		%CurPointField.set_value_no_signal(value.get_index() + 1)
		%Pos/X/Input.set_value_no_signal(value.cameraPoint.smsPosition.x)
		%Pos/Y/Input.set_value_no_signal(value.cameraPoint.smsPosition.y)
		%Pos/Z/Input.set_value_no_signal(value.cameraPoint.smsPosition.z)
		%Target/X/Input.set_value_no_signal(value.targetPoint.smsPosition.x)
		%Target/Y/Input.set_value_no_signal(value.targetPoint.smsPosition.y)
		%Target/Z/Input.set_value_no_signal(value.targetPoint.smsPosition.z)
		#%TravelTimeInput.set_value_no_signal(value.transitionTime)
		%EasingOptions.select(value.easeDirection)
		%CamEdit/LabelAndHold/HoldField.set_value_no_signal(value.cameraPoint.holdTime)
		%TargetEdit/LabelAndHold/HoldField.set_value_no_signal(value.targetPoint.holdTime)

var posField: Vector3:
	set(value):
		%Pos/X/Input.value = value.x
		%Pos/Y/Input.value = value.y
		%Pos/Z/Input.value = value.z
	get:
		return Vector3(%Pos/X/Input.value, %Pos/Y/Input.value, %Pos/Z/Input.value)

var targetField: Vector3:
	set(value):
		%Target/X/Input.value = value.x
		%Target/Y/Input.value = value.y
		%Target/Z/Input.value = value.z
	get:
		return Vector3(%Target/X/Input.value, %Target/Y/Input.value, %Target/Z/Input.value)


func _ready() -> void:
	%BG.size.x = %KeyframeGUI.size.x
	%BG.size.y = DisplayServer.window_get_size().y


func _process(_delta: float) -> void:
	
	%SpringArm3D.rotation = editViewportCamera.rotation
	
	# I for the life of me couldn't get anchoring to work with the SubViewportContainer,
	# so we're just doing it through code. I think it might be bugged.
	%SubViewportContainer.global_position.y = DisplayServer.window_get_size().y - 100
	%SubViewportContainer.global_position.x = 0


func _on_shrink_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%AnimationPlayer.play("close_expand_gui")
		%ShrinkButton.text = "<"
	else:
		%AnimationPlayer.play_backwards("close_expand_gui")
		%ShrinkButton.text = ">"
