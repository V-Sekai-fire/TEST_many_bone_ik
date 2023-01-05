@tool
extends EditorScript


class ManyboneIKResource extends Resource:
	var bone_position: Dictionary
	var bone_rotation: Dictionary
	var bone_rest_position: Dictionary
	var bone_rest_rotation: Dictionary
	@export var skeleton : Skeleton3D
	@export var many_bone_ik : ManyBoneIK3D
	@export var in_bounds : bool = true :
		set (value):
			return false
		get:
			bone_position.clear()
			bone_rest_position.clear()
			bone_rotation.clear()
			bone_rest_rotation.clear()
			for bone in skeleton.get_bone_count():
				bone_position[bone] = skeleton.get_bone_pose_position(bone)
				bone_rotation[bone] = skeleton.get_bone_pose_rotation(bone)

			skeleton.reset_bone_poses()
			for bone in skeleton.get_bone_count():
				bone_rest_position[bone] = skeleton.get_bone_pose_position(bone)
				bone_rest_rotation[bone] = skeleton.get_bone_pose_rotation(bone)
			var test_in_bounds : bool = false
			for bone in skeleton.get_bone_count():
				if bone_rest_position[bone].is_equal_approx(bone_position[bone]):
					print("bone position is different %s %s" % [bone_rest_position[bone], bone_position[bone]])
					test_in_bounds = true
				var dot = bone_rest_rotation[bone].dot(bone_rotation[bone])
				if is_equal_approx(1.0, dot):
					print("bone rotation is different %s %s" % [bone_rest_rotation[bone], bone_rotation[bone]])
					test_in_bounds = true
			return test_in_bounds

	@export var config : Dictionary = {"bone_name_from_to_twist": Dictionary(), "bone_name_cones": Dictionary() } :
		set (value):
			var bone_name_from_to_twist : Dictionary
			var bone_name_cones : Dictionary
			for bone_i in skeleton.get_bone_count():
				var bone_name : String = skeleton.get_bone_name(bone_i)
				var keys : Array = bone_name_from_to_twist.keys()
				if keys.has(bone_name):
					var twist : Vector2 = bone_name_from_to_twist[bone_name]
					many_bone_ik.set_kusudama_twist(bone_i, twist)
				keys = bone_name_cones.keys()
				if keys.has(bone_name):
					var cones : Array = bone_name_cones[bone_name]
					many_bone_ik.set_kusudama_limit_cone_count(bone_i, cones.size())
					for cone_i in range(cones.size()):
						var cone : Dictionary = cones[cone_i]
						if cone.keys().has("center"):
							many_bone_ik.set_kusudama_limit_cone_center(bone_i, cone_i, cone["center"])
						if cone.keys().has("radius"):
							many_bone_ik.set_kusudama_limit_cone_radius(bone_i, cone_i, cone["radius"])
			config["bone_name_from_to_twist"] = bone_name_from_to_twist
			config["bone_name_cones"] = bone_name_cones
		get:
			var bone_name_from_to_twist : Dictionary = config["bone_name_from_to_twist"]
			var bone_name_cones : Dictionary = config["bone_name_cones"]
			for bone_i in skeleton.get_bone_count():
				var bone_name : String = skeleton.get_bone_name(bone_i)
				bone_name_from_to_twist[bone_name] = many_bone_ik.get_kusudama_twist(bone_i)
				var cones : Array
				cones.resize(many_bone_ik.get_kusudama_limit_cone_count(bone_i))
				for cone_i in range(cones.size()):
					var cone : Dictionary
					cone["center"] = many_bone_ik.get_kusudama_limit_cone_center(bone_i, cone_i)
					cone["radius"] = many_bone_ik.get_kusudama_limit_cone_radius(bone_i, cone_i)
					cones[cone_i] = cone
				bone_name_cones[bone_name] = cones
			config["bone_name_from_to_twist"] = bone_name_from_to_twist
			config["bone_name_cones"] = bone_name_cones
			return config

func _run():
	var data : ManyboneIKResource = ManyboneIKResource.new()
	var root : Node3D = get_editor_interface().get_edited_scene_root()
	if root == null:
		return false
	var skeletons : Array[Node] = root.find_children("*", "Skeleton3D")
	var skeleton : Skeleton3D = skeletons[0]
	data.skeleton = skeleton
	var many_bone_iks : Array[Node] = root.find_children("*", "ManyBoneIK3D")
	var many_bone_ik : ManyBoneIK3D = many_bone_iks[0]
	data.many_bone_ik = many_bone_ik
	data.many_bone_ik.constraint_mode = true
	while 1000:
		for bone_i in skeleton.get_bone_count():
			many_bone_ik.set_kusudama_limit_cone_count(bone_i, 4)
			many_bone_ik.set_kusudama_twist(bone_i, generate_vector2_random())
			var cone : Vector4 = generate_vector4_random()
			for limit_i in many_bone_ik.get_kusudama_limit_cone_count(bone_i):
				many_bone_ik.set_kusudama_limit_cone_center(bone_i, limit_i, Vector3(cone.x,cone.y,cone.z))
				many_bone_ik.set_kusudama_limit_cone_radius(bone_i, limit_i, cone.w)
		skeleton.reset_bone_poses()
		if data.in_bounds:
			break
	var file = FileAccess.open("res://data.txt", FileAccess.WRITE)
	print(data.config)
	file.store_string(var_to_str(data.config))

func generate_vector4_random():
	var vector : Vector4
	var crypto : Crypto = Crypto.new()
	vector.x = crypto.generate_random_bytes(4).decode_s32(0)
	vector.y = crypto.generate_random_bytes(4).decode_s32(0)
	vector.z = crypto.generate_random_bytes(4).decode_s32(0)
	vector.w = crypto.generate_random_bytes(4).decode_s32(0)
	vector = vector.normalized()
	vector.w = abs(vector.w)
	vector.w = vector.w * PI
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
	vector.y = vector.y * TAU
	return vector
