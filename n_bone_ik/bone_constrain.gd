@tool
extends EditorScript

func _run():
	var root : Node3D = get_editor_interface().get_edited_scene_root()
	if root == null:
		return
	var iks : Array[Node] = root.find_children("*", "ManyBoneIK3D")
	for ik in iks:
		ik.free()
	var new_ik : ManyBoneIK3D = ManyBoneIK3D.new()
	var skeletons : Array[Node] = root.find_children("*", "Skeleton3D")
	var skeleton : Skeleton3D = skeletons[0]
	root.add_child(new_ik, true)
	new_ik.skeleton_node_path = "../" + str(root.get_path_to(skeleton))
	new_ik.owner = root

	new_ik.visible = false
	skeleton.reset_bone_poses()
	var humanoid_profile : SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	var humanoid_bones : PackedStringArray = []
	for bone_i in humanoid_profile.bone_size:
		var bone_name : String = humanoid_profile.get_bone_name(bone_i)
		humanoid_bones.push_back(bone_name)
		
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		if bone_name in ["Root"]:
			new_ik.set_pin_enabled(bone_i, false)
		if bone_name in ["LeftToes", "RightToes"]:
			new_ik.set_pin_weight(bone_i, 0)
			new_ik.set_pin_enabled(bone_i, true)
		if bone_name in ["Hips", "Spine", "Chest", "UpperChest"]:
			new_ik.set_pin_weight(bone_i, 0.2)
		for radius_i in range(3):
			new_ik.set_kusudama_limit_cone_radius(bone_i, radius_i, PI / 2)
		if not humanoid_bones.has(bone_name):
			continue
		if not bone_name in ["Head", "LeftHand", "RightHand", "LeftFoot", "RightFoot"]:
			continue
		if bone_name in ["LeftFoot", "RightFoot"]:
			new_ik.set_pin_passthrough_factor(bone_i, 0)
		var node_3d : BoneAttachment3D = BoneAttachment3D.new()
		node_3d.name = bone_name
		node_3d.bone_name = bone_name
		node_3d.bone_idx = bone_i
		node_3d.set_use_external_skeleton (true)
		node_3d.set_external_skeleton("../" + str(new_ik.get_path_to(skeleton)))
		new_ik.add_child(node_3d, true)
		node_3d.owner = root
		new_ik.set_pin_enabled(bone_i, true)
		new_ik.set_pin_nodepath(bone_i, bone_name)
		var node_global_transform = node_3d.global_transform
		var marker_3d : Marker3D = Marker3D.new()
		marker_3d.name = bone_name
		marker_3d.global_transform = node_global_transform
		node_3d.replace_by(marker_3d, true)

	new_ik.visible = true