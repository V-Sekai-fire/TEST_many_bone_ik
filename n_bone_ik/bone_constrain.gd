@tool
extends EditorScript

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
	var is_humanoid : bool = false
	
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		if bone_name in humanoid_bones:
			if bone_name == "Root":
				continue
			is_humanoid = true
			break
		
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		if bone_name in ["Root"]:
			new_ik.set_pin_enabled(bone_i, false)
			new_ik.set_pin_weight(bone_i, 0)
		if is_humanoid:
			if bone_name in ["LeftToes", "RightToes"]:
				new_ik.set_pin_weight(bone_i, 0)
				new_ik.set_pin_enabled(bone_i, true)
			if bone_name in ["Hips", "Chest", "UpperChest"]:
				new_ik.set_pin_weight(bone_i, 0)
			if bone_name.begins_with("Spine"):
				new_ik.set_pin_weight(bone_i, 0.2)
			if not humanoid_bones.has(bone_name):
				new_ik.set_pin_weight(bone_i, 0)
				continue
			if not bone_name in ["Head", "LeftHand", "RightHand", "LeftFoot", "RightFoot"]:
				continue
			if bone_name in ["LeftFoot", "RightFoot"]:
				new_ik.set_pin_passthrough_factor(bone_i, 0)
				new_ik.set_pin_enabled(bone_i, true)
			new_ik.set_pin_enabled(bone_i, true)
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
		
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		var twist_min = new_ik.get_kusudama_twist(bone_i).x
		if bone_name.ends_with("Root"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(371.3), deg_to_rad(33.4)))
		elif bone_name.ends_with("Hips"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(340.1), deg_to_rad(25)))
		elif bone_name.ends_with("Spine"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(355), deg_to_rad(30)))
		elif bone_name.ends_with("Chest"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(355), deg_to_rad(30)))
		elif bone_name.ends_with("UpperChest"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(355), deg_to_rad(30)))
		# HEAD ---------
		elif bone_name.ends_with("Head"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(0), deg_to_rad(10)))
		elif bone_name.ends_with("Neck"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(356), deg_to_rad(10)))
		# ARMS ---------
		elif bone_name.ends_with("RightShoulder"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(103), deg_to_rad(10)))
		elif bone_name.ends_with("LeftShoulder"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(295.1), deg_to_rad(10)))
		elif bone_name.ends_with("RightUpperArm"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(135.2), deg_to_rad(40)))
		elif bone_name.ends_with("LeftUpperArm"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(95), deg_to_rad(40)))
		elif bone_name.ends_with("RightLowerArm"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(77), deg_to_rad(20)))
		elif bone_name.ends_with("LeftLowerArm"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(250), deg_to_rad(20)))
#			elif bone_name.ends_with("RightHand"):
#				new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(281), deg_to_rad(10)))
#			elif bone_name.ends_with("LeftHand"):
#				new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(78.6), deg_to_rad(10)))
		# LEGS ---------
		elif bone_name.ends_with("LeftUpperLeg"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(0), deg_to_rad(358)))
		elif bone_name.ends_with("RightUpperLeg"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(0), deg_to_rad(358)))
		elif bone_name.ends_with("LeftLowerLeg"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(0), deg_to_rad(350)))
		elif bone_name.ends_with("RightLowerLeg"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(0), deg_to_rad(350)))
		elif bone_name.ends_with("LeftFoot"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(300), deg_to_rad(350)))
		elif bone_name.ends_with("RightFoot"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(240), deg_to_rad(350)))
		elif bone_name.ends_with("LeftToes"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(180), deg_to_rad(30)))
		elif bone_name.ends_with("RightToes"):
			new_ik.set_kusudama_twist(bone_i, Vector2(deg_to_rad(180), deg_to_rad(30)))

	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		if bone_name in ["Head"]:
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
		elif bone_name in ["Hips"]:
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(1))
		elif bone_name in ["Neck"]:
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(50))
		elif bone_name in ["UpperChest"]:
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(5))
		elif bone_name in ["Chest"]:
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(5))
		elif bone_name in ["Spine"]:
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(1))
		elif bone_name.ends_with("Shoulder"):
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(-1, 0, 0))
			if bone_name.begins_with("Left"):
				new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(1, 0, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(30))
		elif bone_name.ends_with("UpperArm"):
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(1))
		elif bone_name.ends_with("LowerArm"):
			new_ik.set_kusudama_limit_cone_count(bone_i, 3)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(1))
			new_ik.set_kusudama_limit_cone_center(bone_i, 1, Vector3(1, 0, 0))
			if bone_name.begins_with("Left"):
				new_ik.set_kusudama_limit_cone_center(bone_i, 1, Vector3(-1, 0, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 1, deg_to_rad(20))
			new_ik.set_kusudama_limit_cone_center(bone_i, 2, Vector3(0, -1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 2, deg_to_rad(20))
		elif bone_name.ends_with("Hand"):
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(20))
		elif bone_name.ends_with("UpperLeg"):
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, -1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(80))
		elif bone_name.ends_with("LowerLeg"):
			new_ik.set_kusudama_limit_cone_count(bone_i, 3)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(2))
			new_ik.set_kusudama_limit_cone_center(bone_i, 1, Vector3(0, 0, -1))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 1, deg_to_rad(2))
			new_ik.set_kusudama_limit_cone_center(bone_i, 2, Vector3(0, -1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 2, deg_to_rad(2))
		elif bone_name.ends_with("Foot"):
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 1, 0))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(200))
		elif bone_name.ends_with("Toes"):
			new_ik.set_kusudama_limit_cone_count(bone_i, 1)
			new_ik.set_kusudama_limit_cone_center(bone_i, 0, Vector3(0, 0, -1))
			new_ik.set_kusudama_limit_cone_radius(bone_i, 0, deg_to_rad(15))

	# Overwrite all previous twists.
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		new_ik.set_kusudama_twist(bone_i, Vector2(0, deg_to_rad(350)))
		
	new_ik.visible = true
