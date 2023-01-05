@tool
extends EditorScript


# The order of tuning human bodies.
# 0. Root
# 1. Root to Hips
# 2. Root to Head
# 3. UpperChest to Hands
# 4. Hips to Legs

class ManyboneIKResource extends Resource:
	@export var bone_position: Dictionary
	@export var bone_rotation: Dictionary
	@export var bone_rest_position: Dictionary
	@export var bone_rest_rotation: Dictionary
	@export var skeleton : Skeleton3D
	@export var many_bone_ik : ManyBoneIK3D
	@export var bone_name_from_to_twist : Dictionary
	@export var bone_name_cones : Dictionary


func _run():
	var root : Node3D = get_editor_interface().get_edited_scene_root()
	if root == null:
		return
	var properties : Array[Dictionary] = root.get_property_list()
	for property in properties:
		if property["name"] == "update_in_editor":
			root.set("update_in_editor", true)
	var iks : Array[Node] = root.find_children("*", "ManyBoneIK3D")
	for ik in iks:
		ik.free()
	var new_ik : ManyBoneIK3D = ManyBoneIK3D.new()
	var skeletons : Array[Node] = root.find_children("*", "Skeleton3D")
	var skeleton : Skeleton3D = skeletons[0]
	skeleton.add_child(new_ik, true)
	new_ik.skeleton_node_path = ".."
	new_ik.owner = root
	new_ik.iterations_per_frame = 15
	new_ik.default_damp = deg_to_rad(10)
	new_ik.visible = false
#	new_ik.queue_print_skeleton()
#	new_ik.constraint_mode = true
	skeleton.reset_bone_poses()
	var humanoid_profile : SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	var humanoid_bones : PackedStringArray = []
	for bone_i in humanoid_profile.bone_size:
		var bone_name : String = humanoid_profile.get_bone_name(bone_i)
		humanoid_bones.push_back(bone_name)
	var is_humanoid : bool = false
	var is_filtering : bool = true

	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		if bone_name in humanoid_bones:
			is_humanoid = true
			continue
		if is_humanoid:
			new_ik.filter_bones.push_back(bone_name)
	for bone_i in humanoid_profile.bone_size:
		var skeleton_bone_name = humanoid_profile.get_bone_name(bone_i)
		if skeleton_bone_name.ends_with("Eye"):
			continue
		if skeleton_bone_name.find("Thumb") != -1:
			continue
		if skeleton_bone_name.find("Index") != -1:
			continue
		if skeleton_bone_name.find("Ring") != -1:
			continue
		if skeleton_bone_name.find("Little") != -1:
			continue
		if skeleton_bone_name.find("Middle") != -1:
			continue
		var bone_id = skeleton.find_bone(skeleton_bone_name)
		if bone_id == -1:
			continue
		if not skeleton_bone_name in ["Hips", "Root", "Head", "LeftFoot", "RightFoot", "LeftHand", "RightHand"]:
			continue
		tune_bone(new_ik, skeleton, skeleton_bone_name, bone_id)
	new_ik.visible = true

func tune_bone(new_ik : ManyBoneIK3D, skeleton, bone_name, bone_i):
	var node_3d : BoneAttachment3D = BoneAttachment3D.new()
	node_3d.name = bone_name
	node_3d.bone_name = bone_name
	node_3d.bone_idx = bone_i
	node_3d.set_use_external_skeleton (true)
	node_3d.set_external_skeleton("../" + str(new_ik.get_path_to(skeleton)))
	new_ik.add_child(node_3d, true)
	node_3d.owner = new_ik.owner
	new_ik.set_pin_nodepath(bone_i, NodePath(bone_name))
	var node_global_transform = node_3d.global_transform
	var marker_3d : Marker3D = Marker3D.new()
	marker_3d.name = bone_name
	marker_3d.global_transform = node_global_transform
	node_3d.replace_by(marker_3d, true)

