extends ImmediateMesh
class_name axisGizmo

var mi: MeshInstance3D

# TODO: perhaps add screen space thickness
func _init() -> void:
	
	var length = 10000.0
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	
	surface_begin(Mesh.PRIMITIVE_LINES, mat)

	# x axis
	surface_set_color(Color(1,0,0))
	surface_add_vertex(Vector3(-length, 0, 0))
	surface_add_vertex(Vector3( length, 0, 0))
	
	# y axis
	surface_set_color(Color(0,1,0))
	surface_add_vertex(Vector3(0, -length, 0))
	surface_add_vertex(Vector3(0,  length, 0))
	
	# z axis
	surface_set_color(Color(0,0,1))
	surface_add_vertex(Vector3(0, 0, -length))
	surface_add_vertex(Vector3(0, 0,  length))

	surface_end()
	_makeMeshInstance()


func _makeMeshInstance():
	
	mi = MeshInstance3D.new()
	mi.mesh = self


func toggleVisible(toggle: bool):
	mi.visible = toggle
