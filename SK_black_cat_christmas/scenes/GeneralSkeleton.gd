extends Skeleton3D

class ManyboneIKResource extends Resource:
	@export var bone_position: Dictionary
	@export var bone_rotation: Dictionary
	@export var bone_rest_position: Dictionary
	@export var bone_rest_rotation: Dictionary
	@export var skeleton : Skeleton3D
	@export var many_bone_ik : ManyBoneIK3D
	@export var config : Dictionary = {"bone_name_from_to_twist": {}, "bone_name_cones": {}}

func _process(_delta):
	var data : ManyboneIKResource = ManyboneIKResource.new()
	var skeletons : Array[Node] = owner.find_children("*", "Skeleton3D")
	var skeleton : Skeleton3D = skeletons[0]
	data.skeleton = skeleton
	var many_bone_iks : Array[Node] = owner.find_children("*", "ManyBoneIK3D")
	var many_bone_ik : ManyBoneIK3D = many_bone_iks[0]
	data.many_bone_ik = many_bone_ik
	data.many_bone_ik.constraint_mode = true
	for bone_i in skeleton.get_bone_count():
		many_bone_ik.set_kusudama_limit_cone_count(bone_i, 0)
		many_bone_ik.set_kusudama_twist(bone_i, Vector2(0, TAU))
	skeleton.reset_bone_poses()
	
	var humanoid_profile : SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	var humanoid_bones : PackedInt32Array = []
	for bone_i in humanoid_profile.bone_size:
		var bone_name : String = humanoid_profile.get_bone_name(bone_i)
		var skeleton_bone_i = skeleton.find_bone(bone_name)
		if skeleton_bone_i == -1:
			continue
		humanoid_bones.push_back(skeleton_bone_i)
		data.bone_rest_position[skeleton_bone_i] = skeleton.get_bone_pose_position(skeleton_bone_i)
		data.bone_rest_rotation[skeleton_bone_i] = skeleton.get_bone_pose_rotation(skeleton_bone_i)
		
	for bone_i in humanoid_bones:
		var test_in_bounds : bool = true
		while 1000:
			var bone_name : String = skeleton.get_bone_name(bone_i)
			skeleton.reset_bone_poses()
			data.bone_position[bone_i] = skeleton.get_bone_pose_position(bone_i)
			data.bone_rotation[bone_i] = skeleton.get_bone_pose_rotation(bone_i)
			many_bone_ik.set_kusudama_twist(bone_i, generate_vector2_random())
			if not data.bone_rest_position[bone_i].is_equal_approx(data.bone_position[bone_i]):
				test_in_bounds = false
			var dot = data.bone_rest_rotation[bone_i].dot(data.bone_rotation[bone_i])
			if not is_equal_approx(1.0, dot):
				test_in_bounds = false
			if test_in_bounds:
				data.config.bone_name_cones[bone_name] = []
				data.config.bone_name_from_to_twist[bone_name] = many_bone_ik.get_kusudama_twist(bone_i)
				break
	for bone_i in humanoid_bones:
		var test_in_bounds : bool = true
		while 1000:
			var bone_name : String = skeleton.get_bone_name(bone_i)
			skeleton.reset_bone_poses()
			data.bone_position[bone_i] = skeleton.get_bone_pose_position(bone_i)
			data.bone_rotation[bone_i] = skeleton.get_bone_pose_rotation(bone_i)
			many_bone_ik.set_kusudama_limit_cone_count(bone_i, 5)
			var new_cones : Array
			new_cones.resize(many_bone_ik.get_kusudama_limit_cone_count(bone_i))
			for limit_i in range(many_bone_ik.get_kusudama_limit_cone_count(bone_i)):
				var cone : Vector4 = generate_vector4_random()
				many_bone_ik.set_kusudama_limit_cone_center(bone_i, limit_i, Vector3(cone.x,cone.y,cone.z))
				many_bone_ik.set_kusudama_limit_cone_radius(bone_i, limit_i, cone.w)
				if not data.bone_rest_position[bone_i].is_equal_approx(data.bone_position[bone_i]):
					test_in_bounds = false
					break
				var dot = data.bone_rest_rotation[bone_i].dot(data.bone_rotation[bone_i])
				if not is_equal_approx(1.0, dot):
					data.config.bone_name_from_to_twist[bone_name] = many_bone_ik.get_kusudama_twist(bone_i)
					test_in_bounds = false
					break
				for cone_i in range(new_cones.size()):
					var cone_dict : Dictionary = {}
					cone_dict["center"] = many_bone_ik.get_kusudama_limit_cone_center(bone_i, cone_i)
					cone_dict["radius"] = many_bone_ik.get_kusudama_limit_cone_radius(bone_i, cone_i)
					new_cones[cone_i] = cone_dict
			if test_in_bounds:
				data.config.bone_name_cones[bone_name] = new_cones
				break
	var file : FileAccess = FileAccess.open("res://data.txt", FileAccess.WRITE)
	file.store_string(var_to_str(data.config))
	get_tree().quit()

func generate_vector4_random():
	var vector : Vector4
	var crypto : Crypto = Crypto.new()
	vector.x = crypto.generate_random_bytes(4).decode_s32(0)
	vector.y = crypto.generate_random_bytes(4).decode_s32(0)
	vector.z = crypto.generate_random_bytes(4).decode_s32(0)
	vector.w = crypto.generate_random_bytes(4).decode_s32(0)
	vector = vector.normalized()
	vector.w = abs(vector.w)
	vector.w = vector.w * TAU
	return vector
	
func generate_vector2_random():
	var vector : Vector2
	var crypto : Crypto = Crypto.new()
	vector.x = crypto.generate_random_bytes(4).decode_s32(0)
	vector.y = crypto.generate_random_bytes(4).decode_s32(0)
	vector.x= abs(vector.x)
	vector.y= abs(vector.y)
	vector = vector.normalized()
	vector.x = vector.x * TAU
	vector.y = vector.y * PI
	return vector
