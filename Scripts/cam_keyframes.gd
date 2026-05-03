# This script's purpose is to track the order in which children CamKeyframes have been added to this
# node for Globals.undoRedo. Since the child CamKeyframes aren't always guarenteed to be indexed in
# the order they're added in, we can't just call get_index() on the child or something to that degree.

extends Node3D

## The order in which keyframes have been added to CamKeyframes. Separate from the child index.
var camKeyframeOrder: Array[CamKeyframe]

func _notification(what: int) -> void:
	
	if what != NOTIFICATION_CHILD_ORDER_CHANGED:
		return
	
	# Check for and append newly added CamKeyframe children to camKeyframeOrder
	for child in get_children():
		
		if child is not CamKeyframe:
			continue
			
		if not camKeyframeOrder.has(child):
			camKeyframeOrder.append(child)
	
	# Check for and erase newly removed CamKeyframe children from camkeyframeOrder
	for keyframe: CamKeyframe in camKeyframeOrder:
		if not get_children().has(keyframe):
			camKeyframeOrder.erase(keyframe)
