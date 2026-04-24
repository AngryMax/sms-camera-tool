extends Control

var maxKeyframes: int:
	set(value):
		maxKeyframes = value
		%CurPointField.max_value = value

var keyframe: CamKeyframe:
	set(value):
		keyframe = value
		%CurPointField.set_value_no_signal(value.get_index() + 1)
		%Pos/X/Input.set_value_no_signal(value.smsPosition.x)
		%Pos/Y/Input.set_value_no_signal(value.smsPosition.y)
		%Pos/Z/Input.set_value_no_signal(value.smsPosition.z)
		%Target/X/Input.set_value_no_signal(value.smsTarget.x)
		%Target/Y/Input.set_value_no_signal(value.smsTarget.y)
		%Target/Z/Input.set_value_no_signal(value.smsTarget.z)
		%TravelTimeInput.set_value_no_signal(value.transitionTime)

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
