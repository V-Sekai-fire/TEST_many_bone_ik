@tool
extends EditorScript


# The order of tuning human bodies.
# 0. Root
# 1. Root to Hips
# 2. Root to Head
# 3. UpperChest to Hands
# 4. Hips to Legs

var is_humanoid : bool = true
var is_filtering : bool = true
	
@export var targets : PackedStringArray = [
#	"Root", 
	"Hips", "Head", 
#	"LeftLowerLeg", 
	"LeftFoot", 
#	"RightLowerLeg", 
	"RightFoot", 
#	"RightToes",
#	"LeftLowerArm", 
	"LeftHand",
##	"RightLowerArm", 
	"RightHand",
#	"RightToes"
	]
@export	var config : Dictionary = {
		"bone_name_from_to_twist": {
			# Don't put constraints on the root or hip bone.
			"Spine": Vector2(deg_to_rad(355), deg_to_rad(30)),
			"Chest":  Vector2(deg_to_rad(355), deg_to_rad(30)),
			"UpperChest": Vector2(deg_to_rad(355), deg_to_rad(30)),
			"Head": Vector2(deg_to_rad(0), deg_to_rad(10)),
			"Neck": Vector2(deg_to_rad(356), deg_to_rad(10)),
			"LeftShoulder": Vector2(deg_to_rad(-250), deg_to_rad(-40)),
			"LeftUpperArm": Vector2(deg_to_rad(-120), deg_to_rad(-60)),
			"LeftLowerArm": Vector2(deg_to_rad(-75), deg_to_rad(-60)),
			"LeftHand": Vector2(deg_to_rad(-275), deg_to_rad(-20)),
			"LeftUpperLeg": Vector2(deg_to_rad(00), deg_to_rad(350)),
			"LeftLowerLeg": Vector2(deg_to_rad(90), deg_to_rad(20)),
			"LeftFoot": Vector2(deg_to_rad(180), deg_to_rad(5)),
			"RightShoulder": Vector2(deg_to_rad(250), deg_to_rad(-40)),
			"RightUpperArm": Vector2(deg_to_rad(120), deg_to_rad(60)),
			"RightLowerArm": Vector2(deg_to_rad(75), deg_to_rad(60)),
			"RightHand": Vector2(deg_to_rad(275), deg_to_rad(20)),
			"RightUpperLeg": Vector2(deg_to_rad(00), deg_to_rad(350)),
			"RightLowerLeg": Vector2(deg_to_rad(90), deg_to_rad(20)),
			"RightFoot": Vector2(deg_to_rad(180), deg_to_rad(5)),
		},
		"bone_name_cones": {
			# Don't put constraints on the root or hip bone
			"Spine": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(10)}],
			"UpperChest": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(5)}],
			"Chest": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(10)}],
			"Neck": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(15)}],
			"Head": [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(15)}],
			"LeftShoulder": [{"center": Vector3(1, 0, 0), "radius": deg_to_rad(15)}],
			"LeftUpperArm":  [
				{"center": Vector3(0.2, 1, -0.5), "radius": deg_to_rad(40)},
				{"center": Vector3(1, 0, 0), "radius": deg_to_rad(20)},
			],
			"LeftLowerArm":  [
				{"center": Vector3(0, 0, 1), "radius": deg_to_rad(20)},
				{"center": Vector3(0, 0.8, 0), "radius": deg_to_rad(20)},
			],
			"LeftHand":  [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(20)}],
			"LeftUpperLeg":  [
				{"center": Vector3(0, 1, 0), "radius": deg_to_rad(160)}
			],
			"LeftLowerLeg":  [
				{"center": Vector3(0, 1, 0), "radius": deg_to_rad(10)},
				{"center": Vector3(0, -0.8, 1), "radius": deg_to_rad(40)},
			],
			"LeftFoot":  [{"center": Vector3(0, -1, 0), "radius": deg_to_rad(20)}],
			"LeftToes":  [{"center": Vector3(1, 0, 0), "radius": deg_to_rad(5)}],
			"RightShoulder": [{"center": Vector3(-1, 0, 0), "radius": deg_to_rad(15)}],
			"RightUpperArm":  [
				{"center": Vector3(-0.2, 1, -0.5), "radius": deg_to_rad(40)},
				{"center": Vector3(-1, 0, 0), "radius": deg_to_rad(20)},
			],
			"RightLowerArm":  [
				{"center": Vector3(0, 0, 1), "radius": deg_to_rad(20)},
				{"center": Vector3(0, 0.8, 0), "radius": deg_to_rad(20)},
			],
			"RightHand":  [{"center": Vector3(0, 1, 0), "radius": deg_to_rad(20)}],
			"RightUpperLeg":  [
				{"center": Vector3(0, 1, 0), "radius": deg_to_rad(160)}
			],
			"RightLowerLeg":  [
				{"center": Vector3(0, 1, 0), "radius": deg_to_rad(10)},
				{"center": Vector3(0, -0.8, 1), "radius": deg_to_rad(40)},
			],
			"RightFoot":  [{"center": Vector3(0, -1, 0), "radius": deg_to_rad(20)}],
			"RightToes":  [{"center": Vector3(1, 0, 0), "radius": deg_to_rad(5)}],
		},
	}

func _run():
	var root : Node3D = get_editor_interface().get_edited_scene_root()
	if root == null:
		return
	var properties : Array[Dictionary] = root.get_property_list()
	for property in properties:
		if property["name"] == "update_in_editor":
			root.set("update_in_editor", true)
	var iks : Array[Node] = root.find_children("*", "ManyBoneIK3D")
	var reniks : Array[Node] = root.find_children("*", "RenIK")
	var skeletons : Array[Node] = root.find_children("*", "Skeleton3D")
	var skeleton : Skeleton3D = skeletons[0]
	for ik in iks:
		var renik : RenIK = reniks[0]
		for node in skeleton.get_children():
			if str(node.name) in targets:
				node.free()
		renik.armature_head_target = "Head"
		renik.armature_left_hand_target = "LeftHand"
		renik.armature_right_hand_target = "RightHand"
		renik.armature_hip_target = "Hips"
		renik.armature_left_foot_target = "LeftFoot"
		renik.armature_right_foot_target = "RightFoot"
		ik.free()
	var new_ik : ManyBoneIK3D = ManyBoneIK3D.new()
	skeleton.add_child(new_ik, true)
	new_ik.skeleton_node_path = ".."
	new_ik.owner = root
	new_ik.iterations_per_frame = 1
	new_ik.default_damp = deg_to_rad(10)
	new_ik.filter_bones = []
	new_ik.queue_print_skeleton()
#	new_ik.constraint_mode = true
	skeleton.reset_bone_poses()
	var humanoid_profile : SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	var humanoid_bones : PackedStringArray = []
	for profile_i in humanoid_profile.bone_size:
		var bone_name : String = humanoid_profile.get_bone_name(profile_i)
		humanoid_bones.push_back(bone_name)
	
	var skeleton_profile = SkeletonProfileHumanoid.new()
	var human_bones : Array
	for bone_i in skeleton_profile.bone_size:
		var bone_name : String = skeleton_profile.get_bone_name(bone_i)
		human_bones.push_back(bone_name)
	new_ik.filter_bones.append_array(["LeftIndexProximal", "LeftLittleProximal", "LeftMiddleProximal", "LeftRingProximal", "LeftThumbMetacarpal",
	"RightIndexProximal", "RightLittleProximal", "RightMiddleProximal", "RightRingProximal", "RightThumbMetacarpal",
#			"LeftShoulder", "RightShoulder",
#			"LeftUpperLeg", "LeftUpperLeg",
#	"RightEye", "LeftEye",
#	"RightToes", "LeftToes",
	])
	var bone_name_from_to_twist = config["bone_name_from_to_twist"]
	var bone_name_cones = config["bone_name_cones"]
	for bone_i in skeleton.get_bone_count():
		var bone_name : String = skeleton.get_bone_name(bone_i)
		new_ik.set_kusudama_twist(bone_i, Vector2(0, TAU))
		new_ik.set_pin_weight(bone_i, 0)
		new_ik.set_kusudama_limit_cone_count(bone_i, 0)
		if not human_bones.has(bone_name):
			new_ik.filter_bones.push_back(bone_name)
		var keys : Array = bone_name_from_to_twist.keys()
		if keys.has(bone_name):
			new_ik.set_pin_weight(bone_i, 1)
			var twist : Vector2 = bone_name_from_to_twist[bone_name]
			new_ik.set_kusudama_twist(bone_i, twist)
		keys = bone_name_cones.keys()
		if keys.has(bone_name):
			new_ik.set_pin_weight(bone_i, 1)
			var cones : Array = bone_name_cones[bone_name]
			new_ik.set_kusudama_limit_cone_count(bone_i, cones.size())
			for cone_i in range(cones.size()):
				var cone : Dictionary = cones[cone_i]
				if cone.keys().has("center"):
					new_ik.set_kusudama_limit_cone_center(bone_i, cone_i, cone["center"])
				if cone.keys().has("radius"):
					new_ik.set_kusudama_limit_cone_radius(bone_i, cone_i, cone["radius"])
		if not bone_name in targets:
			continue
		tune_bone(new_ik, reniks[0], skeleton, bone_i)

func tune_bone(new_ik : ManyBoneIK3D, renik : RenIK, skeleton : Skeleton3D, bone_i : int):
	var node_3d : Marker3D = Marker3D.new()
	var bone_name = skeleton.get_bone_name(bone_i)
	node_3d.name = bone_name
	node_3d.transform = skeleton.get_bone_global_pose_no_override(bone_i)
	new_ik.add_child(node_3d, true)
	if bone_name in ["Root"]:
		new_ik.set_pin_passthrough_factor(bone_i, 0)
		new_ik.set_pin_weight(bone_i, 0)
	if bone_name in ["Hips"]:
		new_ik.set_pin_passthrough_factor(bone_i, 0)
		new_ik.set_pin_weight(bone_i, 0)
	if bone_name in ["Head"]:
		# Move slightly higher to avoid the crunching into the body effect.
		node_3d.transform.origin = node_3d.transform.origin + Vector3(0, 0.1, 0)
		new_ik.set_pin_passthrough_factor(bone_i, 1)
	if bone_name in ["LeftHand"]:
		new_ik.set_pin_passthrough_factor(bone_i, 0)
	if bone_name in ["RightHand"]:
		new_ik.set_pin_passthrough_factor(bone_i, 0)
	if bone_name in ["LeftFoot", "RightFoot"]:
		new_ik.set_pin_passthrough_factor(bone_i, 0)
		node_3d.global_transform.basis = Basis.from_euler(Vector3(0, PI, 0))
	node_3d.owner = new_ik.owner
	new_ik.set_pin_nodepath(bone_i, str(node_3d.name))
