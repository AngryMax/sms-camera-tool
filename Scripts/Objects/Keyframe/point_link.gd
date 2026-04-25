extends MeshInstance3D
class_name PointLink

var start: Vector3
var end: Vector3

var _mat: StandardMaterial3D

func _ready() -> void:
	
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.vertex_color_use_as_albedo = true
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh = ImmediateMesh.new()
	


func _process(_delta: float) -> void:
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, _mat)
	
	mesh.surface_add_vertex(start)
	mesh.surface_add_vertex(end)
	mesh.surface_end()
	
