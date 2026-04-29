## This script is responsible for all interactions that involve both Sunshine and
## SMSCT. Basically, this is the connective tissue between the GDInterface and
## the keyframe editor. No other script or object should be calling GDInterface!

extends Node
class_name SMSCameraInterface

@export var GDInterface: Node
@export var camKeyframesNode: Node3D


var previewMode := false		# TODO: make previewMode and playbackMode into a state machine
var playbackMode := false:
	set(value):
		playbackMode = value
		if value == true:
			_preparingPlayback = true

var position: Vector3:
	get:
		return _getCameraPosition()
var target: Vector3:
	get:
		return _getCameraTargetPosition()

var _keyframes: Array[CamKeyframe]
var _preparingPlayback := true	## Used in _replayKeyframes to track state. This will get refactored as an Enter() func in the state machine update
var _lerpPow := 0.0:				## lerpPow is my personal convention for what to call t in the lerp() equation.
	set(value):
		_lerpPow = clampf(value, 0.0, 1.0)	# Perhaps unnecessary, since the way I'm coding this it should basically be auto-clamped
var _fromKeyframe: CamKeyframe	## The keyframe we're lerping from. Set through _keyframeIdx's setter
var _toKeyframe: CamKeyframe	## The keyframe we're lerping to. Set through _keyframeIdx's setter
var _keyframeIdx := 0:
	set(value):
		value = clampi(value, 0, _keyframes.size() - 1)
		if _toKeyframe == null:
			_fromKeyframe = _keyframes[0]
		else: _fromKeyframe = _toKeyframe
		_toKeyframe = _keyframes[value]
		_keyframeIdx = value
var _playbackStartTimer := 0.0

### Override Funcs ##

func _ready() -> void:
	GDInterface = %GDInterface
	GDInterface.Hook()


func _process(delta: float) -> void:
	_previewKeyframe(Globals.currentKeyframe)
	_replayKeyframes(delta)


### Public Funcs ###

func getCoord(lambda: String) -> float:
	var callFunc := Callable(GDInterface, lambda)
	return callFunc.call()


### Private Funcs ###

func _replayKeyframes(delta: float):
	
	if not playbackMode:
		return
	
	if _preparingPlayback:
		_preparePlayback()
		return
	
	var curPos: Vector3
	var curTarget: Vector3
	#curPos = _fromKeyframe.cameraPoint.smsPosition.lerp(_toKeyframe.cameraPoint.smsPosition, _lerpPow)
	#curTarget = _fromKeyframe.targetPoint.smsPosition.lerp(_toKeyframe.targetPoint.smsPosition, _lerpPow)
	
	curPos = _interpolateCubic(_fromKeyframe.cameraPoint.smsPosition, _toKeyframe.cameraPoint.smsPosition, _lerpPow)
	curTarget = _interpolateCubic(_fromKeyframe.targetPoint.smsPosition, _toKeyframe.targetPoint.smsPosition, _lerpPow)
	
	GDInterface.writeCamData(curPos, curTarget)
	setSMSCamRepTransform(curPos / Globals.UNIT_DIVIDE_RATIO, curTarget / Globals.UNIT_DIVIDE_RATIO)
	
	const WAIT_AT_START_TIMER = 0.5
	if _playbackStartTimer > WAIT_AT_START_TIMER:	# Hold 0.5 seconds on the first keyframe before moving
		_lerpPow += delta / _fromKeyframe.transitionTime	# It's kinda weird but we want to add on delta AFTER doing our lerping
	
	_playbackStartTimer += delta
	
	
	if _toKeyframe == _keyframes.back() and _lerpPow >= 1.0:
		GDInterface.restoreCameraCode()
		playbackMode = false
		return
	
	if _lerpPow >= 1.0:
		_keyframeIdx += 1
		_lerpPow = 0.0
		return


func setSMSCamRepTransform(setPos: Vector3, setTarget: Vector3) -> void:
	%Timer.start()
	if not %SMSCameraRepresantation.visible:
		%SMSCameraRepresantation.visible = true
		print("vis")
	%CamModel.position = setPos
	%CamModel.look_at(setTarget)
	%TargetModel.position = setTarget
	


## Sets the _keyframes array + other playback prep work.
func _preparePlayback() -> void:
	
	_keyframes.clear()
	
	# Set our keyframe array
	for i in camKeyframesNode.get_child_count():
		_keyframes.append(camKeyframesNode.get_child(i))
	
	# Misc prep work
	GDInterface.nopOutCameraCode()
	_preparingPlayback = false
	_lerpPow = 0
	_toKeyframe = null
	_fromKeyframe = null
	_keyframeIdx = 1
	previewMode = false
	_playbackStartTimer = 0.0


var _lastState := false
func _previewKeyframe(keyframe: CamKeyframe):
	
	if _lastState == true and previewMode == false:
		GDInterface.restoreCameraCode()
		_lastState = false
	
	if not previewMode:
		return
	
	_lastState = true
	
	GDInterface.nopOutCameraCode()
	GDInterface.writeCamData(keyframe.cameraPoint.smsPosition, keyframe.targetPoint.smsPosition)


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
func _interpolateCubic(from: Vector3, to: Vector3, lerpPow: float, easeDirection := Globals.EaseDirection.NONE) -> Vector3:	# TODO: actually figure this out lol
	
	var pre_from := from
	var pre_to := to
	
	match easeDirection:
		
		Globals.EaseDirection.IN:
			pre_from += Vector3.ONE
		Globals.EaseDirection.OUT:
			pre_to += Vector3.ONE
		Globals.EaseDirection.BOTH:
			pre_from += Vector3.ONE
			pre_to += Vector3.ONE
		
	return from.cubic_interpolate(to, pre_from, pre_to, lerpPow)


## Smooth camera interpolation (also cubic) | Only to be called by replayPoints()
func _interpolateSmooth(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:
	lerpPow = smoothstep(0, 1, lerpPow)
	return from.lerp(to, lerpPow)


func _on_timer_timeout() -> void:
	%SMSCameraRepresantation.visible = false
	%Timer.stop()
