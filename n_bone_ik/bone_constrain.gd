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
	new_ik.iterations_per_frame = 20
	new_ik.default_damp = deg_to_rad(45)
	new_ik.visible = false
	new_ik.constraint_mode = false
	skeleton.reset_bone_poses()
	var humanoid_profile : SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	var humanoid_bones : PackedStringArray = []
	for bone_i in humanoid_profile.bone_size:
		var bone_name : String = humanoid_profile.get_bone_name(bone_i)
		humanoid_bones.push_back(bone_name)
	var is_humanoid : bool = false
	var filter_bones : Array[StringName]  = [
		"LeftIndexProximal", "LeftLittleProximal", "LeftMiddleProximal", "LeftRingProximal", "LeftThumbMetacarpal",
		"RightIndexProximal", "RightLittleProximal", "RightMiddleProximal", "RightRingProximal", "RightThumbMetacarpal",
	]
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		if bone_name in humanoid_bones:
			is_humanoid = true
			continue
		new_ik.set_pin_weight(bone_i, 0)
		filter_bones.push_back(StringName(bone_name))
	new_ik.filter_bones = filter_bones
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		if is_humanoid:
			if bone_name in ["Hips", "Chest", "UpperChest"]:
				new_ik.set_pin_weight(bone_i, 1)
			if bone_name.begins_with("Spine"):
				new_ik.set_pin_weight(bone_i, 0.2)
			if not humanoid_bones.has(bone_name):
				new_ik.set_pin_weight(bone_i, 0)
				continue
			if not bone_name in ["Root", "Hips", "Head", "LeftFoot", "RightFoot", "LeftHand", "RightHand",]:
				continue
			if bone_name in ["LeftFoot", "RightFoot"]:
				new_ik.set_pin_passthrough_factor(bone_i, 0)
		if bone_name in ["Hips"]:
			new_ik.set_pin_passthrough_factor(bone_i, 1)
			new_ik.set_pin_weight(bone_i, 1)
		var node_3d : BoneAttachment3D = BoneAttachment3D.new()
		node_3d.name = bone_name
		node_3d.bone_name = bone_name
		node_3d.bone_idx = bone_i
		node_3d.set_use_external_skeleton (true)
		node_3d.set_external_skeleton("../" + str(new_ik.get_path_to(skeleton)))
		new_ik.add_child(node_3d, true)
		if bone_name in ["Head"]:
			# Move slightly higher to avoid the crunching into the body effect.
			node_3d.transform.origin = node_3d.transform.origin + Vector3(0, 0.1, 0)
		if bone_name in ["LeftHand"]:
			# Move slightly higher to avoid the crunching into the body effect.
			node_3d.transform.origin = node_3d.transform.origin + Vector3(0.1, 0, 0)
		if bone_name in ["RightHand"]:
			# Move slightly higher to avoid the crunching into the body effect.
			node_3d.transform.origin = node_3d.transform.origin - Vector3(0.1, 0, 0)
		node_3d.owner = root
		new_ik.set_pin_nodepath(bone_i, bone_name)
		var node_global_transform = node_3d.global_transform
		var marker_3d : Marker3D = Marker3D.new()
		marker_3d.name = bone_name
		marker_3d.global_transform = node_global_transform
		node_3d.replace_by(marker_3d, true)
		
	var bone_name_from_to_twist : Dictionary = {
		# Spine
		"Root": Vector2(deg_to_rad(371.3), deg_to_rad(33.4)),
		"Hips": Vector2(deg_to_rad(340.1), deg_to_rad(25)),
		"Spine": Vector2(deg_to_rad(355), deg_to_rad(30)),
		"Chest":  Vector2(deg_to_rad(355), deg_to_rad(30)),		
		"UpperChest": Vector2(deg_to_rad(355), deg_to_rad(30)),
		# Head
		"Head": Vector2(deg_to_rad(0), deg_to_rad(10)),
		"Neck": Vector2(deg_to_rad(356), deg_to_rad(10)),
		# Arms
		"LeftShoulder": Vector2(deg_to_rad(250), deg_to_rad(-10)),
		"RightShoulder": Vector2(deg_to_rad(77), deg_to_rad(10)),
		"LeftUpperArm": Vector2(deg_to_rad(-120), deg_to_rad(-60)),
		"RightUpperArm": Vector2(deg_to_rad(120), deg_to_rad(60)),
		"LeftLowerArm": Vector2(deg_to_rad(-75), deg_to_rad(100)),
		"RightLowerArm": Vector2(deg_to_rad(75), deg_to_rad(-100)),
		"LeftHand": Vector2(deg_to_rad(-275), deg_to_rad(-10)),
		"RightHand": Vector2(deg_to_rad(275), deg_to_rad(10)),
		# Legs
		"LeftUpperLeg": Vector2(deg_to_rad(0), deg_to_rad(358)),
		"RightUpperLeg": Vector2(deg_to_rad(0), deg_to_rad(358)),
		"LeftLowerLeg": Vector2(deg_to_rad(180), deg_to_rad(20)),
		"RightLowerLeg": Vector2(deg_to_rad(180), deg_to_rad(20)),
		"LeftFoot": Vector2(deg_to_rad(180), deg_to_rad(350)),
		"RightFoot": Vector2(deg_to_rad(180), deg_to_rad(350)),
	}
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		var keys : Array = bone_name_from_to_twist.keys()
		if keys.has(bone_name):
			var twist : Vector2 = bone_name_from_to_twist[bone_name]
			new_ik.set_kusudama_twist(bone_i, twist)

	var bone_name_cones : Dictionary = {
		"Head": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(30)}],
		"Root": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(2)}],
		"Neck": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(30)}],
		"Chest": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(10)}],
		"Spine": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(10)}],
		"UpperChest": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(5)}],
		"LeftShoulder": [{"center": Vector3(1, 0, 0), "radius": deg_to_rad(15)}],
		"RightShoulder": [{"center": Vector3(-1, 0, 0), "radius": deg_to_rad(15)}],
		"LeftUpperArm":  [
			{"center": Vector3(1, 1, 1), "radius": deg_to_rad(50)},
			{"center": Vector3(2, 0.5, -2), "radius": deg_to_rad(65)},
			{"center": Vector3(0, 1, -1), "radius": deg_to_rad(20)},
		],
		"RightUpperArm":  [
			{"center": Vector3(0, 1, -0.5), "radius": deg_to_rad(50)},
			{"center": Vector3(-2, 0.5, -0.2), "radius": deg_to_rad(65)},
			{"center": Vector3(0, 0.2, 1), "radius": deg_to_rad(20)},
		],
		"LeftLowerArm":  [
			{"center": Vector3(0, 1, 0), "radius": deg_to_rad(20)},
			{"center": Vector3(-1, 0, 0), "radius": deg_to_rad(20)},
			{"center": Vector3(0, 0.8, 0), "radius": deg_to_rad(20)},
		],
		"RightLowerArm":  [
			{"center": Vector3(0, 1, 0), "radius": deg_to_rad(20)},
			{"center": Vector3(1, 0, 0), "radius": deg_to_rad(20)},
			{"center": Vector3(0, 0.8, 0), "radius": deg_to_rad(20)},
		],
		"LeftHand":  [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(20)}],
		"RightHand":  [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(20)}],
		"LeftUpperLeg":  [{"center": Vector3(0, -1, 0), "radius": deg_to_rad(80)}],
		"RightUpperLeg":  [{"center": Vector3(0, -1, 0), "radius": deg_to_rad(80)}],
		"LeftLowerLeg":  [
			{"center": Vector3(0, 1, 0), "radius": deg_to_rad(10)},
			{"center": Vector3(0, -0.8, -1), "radius": deg_to_rad(10)},
		],
		"RightLowerLeg":  [
			{"center": Vector3(0, 1, 0), "radius": deg_to_rad(10)},
			{"center": Vector3(0, -0.8, -1), "radius": deg_to_rad(10)},
			
		],
		"LeftFoot":  [{"center": Vector3(1, 0, 0), "radius": deg_to_rad(90)}],
		"RightFoot":  [{"center": Vector3(1, 0, 0), "radius": deg_to_rad(90)}],
	}

	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		var keys : Array = bone_name_cones.keys()
		if keys.has(bone_name):
			var cones : Array = bone_name_cones[bone_name]
			new_ik.set_kusudama_limit_cone_count(bone_i, cones.size())
			for cone_i in range(cones.size()):
				var cone : Dictionary = cones[cone_i]
				if cone.keys().has("center"):
					new_ik.set_kusudama_limit_cone_center(bone_i, cone_i, cone["center"])
				if cone.keys().has("radius"):
					new_ik.set_kusudama_limit_cone_radius(bone_i, cone_i, cone["radius"])

	new_ik.visible = true
