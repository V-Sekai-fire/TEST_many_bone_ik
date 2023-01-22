@tool
extends EditorScript

const splerger_const = preload("res://addons/splerger/merge_splerger.gd")


func _run():
	var root : Node3D = get_editor_interface().get_edited_scene_root()
	splerger_const.merge_suitable_meshes_across_branches(root)

