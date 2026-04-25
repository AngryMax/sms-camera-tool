extends ImmediateMesh
class_name gridGizmo

var mi: MeshInstance3D

# TODO: perhaps add screen space thickness
func _init() -> void:
	
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	surface_begin(Mesh.PRIMITIVE_LINES, mat)
	
	_makeLines(10, Color(1.0, 1.0, 1.0, 0.5))
	_makeLines(2, Color(1.0, 1.0, 1.0, 0.25))

	surface_end()
	_makeMeshInstance()

## Makes lines in a xz grid pattern. [br][br]
## [b]lineDistance[/b] is how far each line should be from each other [br][br]
## [b]color[/b] is of course the color of the line [br][br]
## [b]skipLine[/b] specifies if any lines should be skipped, where every skipLine line is skipped. [br][br]
## [b]length[/b] is how far out the line will draw. Since each line is technically two lines that start at 0 of their perpindicular axis, length is actually the half the total apparent length. [br][br]
func _makeLines(lineSeparation: int, color: Color, length := 10000, lineNum := 1000, skipLine := 7777777):
	
	surface_set_color(color)
	for i in lineNum:
		
		if i == 0 or i % skipLine == 0:
			continue
		
		var unit = i * lineSeparation
		surface_add_vertex(Vector3(length, 0, unit))
		surface_add_vertex(Vector3(-length, 0, unit))
		surface_add_vertex(Vector3(length, 0, -unit))
		surface_add_vertex(Vector3(-length, 0, -unit))
		#surface_add_vertex(Vector3(0, length, 0))
		#surface_add_vertex(Vector3(0, -length, 0))
		surface_add_vertex(Vector3(unit, 0, length))
		surface_add_vertex(Vector3(unit, 0, -length))
		surface_add_vertex(Vector3(-unit, 0, length))
		surface_add_vertex(Vector3(-unit, 0, -length))


func _makeMeshInstance():
	
	mi = MeshInstance3D.new()
	mi.mesh = self


func toggleVisible(toggle: bool):
	mi.visible = toggle
