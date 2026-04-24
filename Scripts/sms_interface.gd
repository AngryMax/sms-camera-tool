## This script is responsible for all interactions that involve both Sunshine and
## SMSCT. Basically, this is the connective tissue between the GDInterface and
## the keyframe editor. No other script or object should be calling GDInterface!

extends Node
class_name SMSCameraInterface

@export var GDInterface: Node

var selectedKeyframe: CamKeyframe
var previewMode := false
var position: Vector3:
	get:
		return _getCameraPosition()
var target: Vector3:
	get:
		return _getCameraTargetPosition()


### Override Funcs ##

func _ready() -> void:
	GDInterface = %GDInterface
	GDInterface.Hook()


func _process(_delta: float) -> void:
	previewKeyframe(selectedKeyframe)

### Public Funcs ###

func replayPoints(keyframes: Array[CamKeyframe]):
	
	#%PreviewPoint.button_pressed = false	!!!
	#%PreviewPoint.emit_signal("pressed")	!!!
	
	var keyNum = keyframes.size()
	
	GDInterface.nopOutCameraCode()
	GDInterface.writeCamData(keyframes.front().position, keyframes.front().target)
	await get_tree().create_timer(0.5).timeout
	print(keyframes.size())
	
	for i in keyNum:
		
		var fromPos: Vector3 = keyframes[i].position
		var curPos := fromPos
		var toPos: Vector3
		var fromTarget: Vector3 = keyframes[i].targetPosition
		var curTarget := fromTarget
		var toTarget: Vector3
		
		if i == keyNum - 1:		# If we're on the last point
			toPos = keyframes.back().position
			toTarget = keyframes.back().targetPosition
		else:
			toPos = keyframes[i + 1].targetPosition
			toTarget = keyframes[i + 1].target
		
		var startTime: float = Time.get_ticks_msec() / 1000.0
		
		print("Processing point ", i)
		print("Currently at ", curPos)
		print("Currently looking at ", curTarget)
		print("Going to ", toPos)
		print("Going to look at ", toTarget)
		
		var lastTime := 0.0
		while true:
			
			var curTime: float = Time.get_ticks_msec() / 1000.0
			
			if curTime - lastTime <= 1.0 / 60.0:	# Bootleg 60 ticks per second system
				continue
			
			lastTime = curTime
			
			var lerpPow: = curTime - startTime
			lerpPow /= keyframes[i].transitionTime
			if lerpPow >= 1.0:
				lerpPow = 1.0
			
			match keyframes[i].interpolation:
				CamKeyframe.InterpolationTypes.Linear:
					curPos = _interpolateLinear(fromPos, toPos, lerpPow)
					curTarget = _interpolateLinear(fromTarget, toTarget, lerpPow)
				CamKeyframe.InterpolationTypes.Cubic:
					curPos = _interpolateSmooth(fromPos, toPos, lerpPow)
					curTarget = _interpolateSmooth(fromTarget, toTarget, lerpPow)
				_:
					print("uh oh")
					push_error("Invalid interpolation type!")
			
			GDInterface.writeCamData(curPos, curTarget)
			
			if lerpPow >= 1.0:
				break


var _lastState := false
func previewKeyframe(keyframe: CamKeyframe):
	
	if _lastState == true and previewMode == false:
		GDInterface.restoreCameraCode()
		_lastState = false
	
	if not previewMode:
		return
	
	_lastState = true
	
	GDInterface.nopOutCameraCode()
	GDInterface.writeCamData(keyframe.smsPosition, keyframe.smsTarget)


### Private Funcs ###

## Get's Sunshine's camera position
func _getCameraPosition() -> Vector3:
	return Vector3(GDInterface.getCamPosX(), GDInterface.getCamPosY(), GDInterface.getCamPosZ())


## Get's Sunshine's camera target position
func _getCameraTargetPosition() -> Vector3:
	return Vector3(GDInterface.getCamTargetX(), GDInterface.getCamTargetY(), GDInterface.getCamTargetZ())
	

## Linear camera interpolation | Only to be called by replayPoints()
func _interpolateLinear(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:
	return from.lerp(to, lerpPow)


## Cubic camera interpolation | Only to be called by replayPoints()
func _interpolateCubic(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:	# TODO: actually figure this out lol
	return from.cubic_interpolate(to, to * 1.5, to * 0.75, lerpPow)


## Smooth camera interpolation (also cubic) | Only to be called by replayPoints()
func _interpolateSmooth(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:
	lerpPow = smoothstep(0, 1, lerpPow)
	return from.lerp(to, lerpPow)
