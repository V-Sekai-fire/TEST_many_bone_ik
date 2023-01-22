@tool
extends EditorScript

const split_splerger_const = preload("res://addons/splerger/split_splerger.gd")
const merge_splerger_const = preload("res://addons/splerger/merge_splerger.gd")


func _run():
	var root = get_editor_interface().get_edited_scene_root()
	split_splerger_const.traverse_root_and_split(root, 0.64, 0.64)
