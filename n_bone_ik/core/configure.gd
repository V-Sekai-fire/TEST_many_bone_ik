# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# configure_ik.gd
# SPDX-License-Identifier: MIT

@tool
extends EditorScript


func euclidean_distance(p1, p2):
	return p1.distance_to(p2)

func chamfer_distance(set_A, set_B):
	var total_distance = 0.0

	for point_A in set_A:
		var min_distance = INF
		for point_B in set_B:
			var distance = euclidean_distance(point_A, point_B)
			if distance < min_distance:
				min_distance = distance
		total_distance += min_distance

	for point_B in set_B:
		var min_distance = INF
		for point_A in set_A:
			var distance = euclidean_distance(point_B, point_A)
			if distance < min_distance:
				min_distance = distance
		total_distance += min_distance

	return total_distance / (set_A.size() + set_B.size())


func test_chamfer_distance():
	var set_A = [Vector2(1, 2), Vector2(3, 4), Vector2(5, 6)]
	var set_B = [Vector2(7, 8), Vector2(9, 10), Vector2(11, 12)]
	print(chamfer_distance(set_A, set_B))


class LimitCone:
	var direction: Vector3
	var angle: float

	func _init(direction: Vector3, angle: float):
		self.direction = direction
		self.angle = angle

class BoneConstraint:
	var twist_from: float
	var twist_range: float
	var swing_limit_cones: Array
	var resistance: float

	func _init(twist_from: float = 0, twist_range : float = TAU, swing_limit_cones: Array = [], resistance: float = 0):
		self.twist_from = twist_from
		self.twist_range = twist_range
		self.swing_limit_cones = swing_limit_cones
		self.resistance = resistance

var bone_names = ["Root", "Hips", "Spine", "Chest", "UpperChest", "Neck", "Head", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot", "LeftShoulder", "RightShoulder", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand", "LeftThumb", "RightThumb"]
# **Rotation Twist**
# | Body Part       | Description                                                                                                                                                                                                                   |
# |-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
# | Head            | The head can rotate side-to-side up to 60-70 degrees, enabling the character to look left and right.                                                                                                   |
# | Neck            | The neck can rotate side-to-side up to 50-60 degrees for looking left and right.                                                                                                       |
# | [Side]UpperLeg  | The upper leg can rotate slightly up to 5-10 degrees for sitting.                                                                                                  |
# | [Side]UpperArm  | The upper arm can also rotate slightly up to 30-40 degrees for more natural arm movement.                                                                             |
# | [Side]Hand      | The wrist can also rotate slightly up to 20-30 degrees, enabling the hand to twist inward or outward for grasping and gesturing.                             |
# | Hips            | The hips can rotate up to 45-55 degrees, allowing for twisting and turning movements.                                                                                                      |
# | Spine           | The spine can rotate up to 20-30 degrees, providing flexibility for bending and twisting.                                                                                                 |
# | Chest           | The chest can rotate up to 15-25 degrees, contributing to the twisting motion of the upper body.                                                                                       |
# | UpperChest      | The upper chest can rotate up to 10-20 degrees, aiding in the overall rotation of the torso.
# | [Side]UpperLeg  | The upper leg can rotate up to 30-40 degrees, allowing for movements such as kicking or stepping.                                                                                                  |
# | [Side]LowerLeg  | The lower leg can rotate slightly up to 10-15 degrees, providing flexibility for running or jumping.                                                                                                 |
# | [Side]Foot      | The foot can rotate inward or outward (inversion and eversion) up to 20-30 degrees, enabling balance and various stances.         |
# | [Side]Shoulder  | The shoulder can rotate up to 90 degrees in a normal range of motion. This allows for movements such as lifting an arm or throwing. However, with forced movement, it can rotate beyond this limit. |
#
# **Rotation Swing**
# | Body Part       | Description                                                                                                                                                                                                                   |
# |-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
# | Hips            | The hips can tilt forward and backward up to 20-30 degrees, allowing the legs to swing in a wide arc during walking or running. They can also move side-to-side up to 10-20 degrees, enabling the legs to spread apart or come together.                               |
# | UpperChest      | The upper chest can tilt forward and backward up to 10-20 degrees, allowing for natural breathing and posture adjustments.                                                                                                                         |
# | Chest           | The chest can tilt forward and backward up to 10-20 degrees, allowing for natural breathing and posture adjustments.                                                                                                                               |
# | Spine           | The spine can tilt forward and backward up to 35-45 degrees, allowing for bending and straightening of the torso.                                                                                                                                  |
# | [Side]UpperLeg  | The upper leg can swing forward and backward up to 80-90 degrees, allowing for steps during walking and running.                                                                                                  |
# | [Side]LowerLeg  | The knee can bend and straighten up to 110-120 degrees, allowing the lower leg to move towards or away from the upper leg during walking, running, and stepping.                                                                                     |
# | [Side]Foot      | The ankle can tilt up (dorsiflexion) up to 10-20 degrees and down (plantarflexion) up to 35-40 degrees, allowing the foot to step and adjust during walking and running.          |
# | [Side]Shoulder  | The shoulder can tilt forward and backward up to 160 degrees, allowing the arms to swing in a wide arc. They can also move side-to-side up to 40-50 degrees, enabling the arms to extend outwards or cross over the chest.                                       |
# | [Side]UpperArm  | The upper arm can swing forward and backward up to 110-120 degrees, allowing for reaching and swinging motions.                                                                             |
# | [Side]LowerArm  | The elbow can bend and straighten up to 120-130 degrees, allowing the forearm to move towards or away from the upper arm during reaching and swinging motions.                                                                                       |
# | [Side]Hand      | The wrist can tilt up and down up to 50-60 degrees, allowing the hand to move towards or away from the forearm.

func _run():
	var root: Node = get_scene()
	var nodes : Array[Node] = root.find_children("*", "ManyBoneIK3D")
	if nodes.is_empty():
		return
	var many_bone_ik: ManyBoneIK3D = nodes[0]
	var markers: Array[Node] = many_bone_ik.find_children("*", "Marker3D")
	for marker in markers:
		marker.free()

	many_bone_ik.set_process_thread_group(Node.PROCESS_THREAD_GROUP_SUB_THREAD)
	many_bone_ik.set_process_thread_group_order(100)
	many_bone_ik.set_constraint_count(0)
	var bones: Array = [
		"Hips",
		"Chest",
		#"LeftLowerArm",
		"LeftHand",
		#"LeftThumbProximal",
		#"LeftIndexProximal",
		#"LeftMiddleProximal",
		#"LeftRingProximal",
		#"LeftLittleProximal",
		#"LeftThumbDistal",
		#"LeftIndexDistal",
		#"LeftMiddleDistal",
		#"LeftRingDistal",
		#"LeftLittleDistal",
		#"RightLowerArm",
		"RightHand",
		#"RightThumbProximal",
		#"RightIndexProximal",
		#"RightMiddleProximal",
		#"RightRingProximal",
		#"RightLittleProximal",
		#"RightThumbDistal",
		#"RightIndexDistal",
		#"RightMiddleDistal",
		#"RightRingDistal",
		#"RightLittleDistal",
		#"LeftLowerLeg",
		#"RightLowerLeg",
		"LeftFoot",
		"RightFoot",
		"Head",
	]
	many_bone_ik.active = false
	many_bone_ik.set_pin_count(0)
	many_bone_ik.set_pin_count(bones.size())

	var children: Array[Node] = many_bone_ik.get_node("..").get_children()
	for child in children:
		if child is BoneAttachment3D:
			child.queue_free()

	for pin_i in range(bones.size()):
		var bone_name: String = bones[pin_i]
		var targets_3d: Marker3D = Marker3D.new()
		targets_3d.gizmo_extents =  .05
		many_bone_ik.add_child(targets_3d, true)
		targets_3d.owner = root
		targets_3d.name = bone_name
		var skeleton: Skeleton3D = many_bone_ik.get_node("..")
		var bone_rest = skeleton.get_bone_global_rest(skeleton.find_bone(bone_name))
		targets_3d.transform = bone_rest
		many_bone_ik.set_effector_pin_node_path(pin_i, many_bone_ik.get_path_to(targets_3d))
		many_bone_ik.set_effector_bone_name(pin_i, bone_name)
		many_bone_ik.set_pin_weight(pin_i, 1)

		var motion_factor: int
		if ["Root"].has(bone_name):
			motion_factor = 0
		else:
			motion_factor = 1
		many_bone_ik.set_pin_motion_propagation_factor(pin_i, motion_factor)

	many_bone_ik.active = true

var bone_constraints: Dictionary

func get_bone_constraint(p_bone_name: String) -> BoneConstraint:
	if bone_constraints.has(p_bone_name):
		return bone_constraints[p_bone_name]
	else:
		return BoneConstraint.new()

func set_bone_constraint(many_bone_ik: ManyBoneIK3D, p_bone_name: String, p_twist_from: float, p_twist_range: float, p_swing_limit_cones: Array, p_resistance: float = 0.0):
	bone_constraints[p_bone_name] = BoneConstraint.new(p_twist_from, p_twist_range, p_swing_limit_cones, p_resistance)
	var constraint_count = many_bone_ik.get_constraint_count()
	many_bone_ik.set_constraint_count(constraint_count + 1)
	many_bone_ik.set_constraint_name(constraint_count, p_bone_name)
	many_bone_ik.set_kusudama_resistance(constraint_count, p_resistance)
	many_bone_ik.set_kusudama_twist(constraint_count, Vector2(p_twist_from, p_twist_range))
	many_bone_ik.set_kusudama_limit_cone_count(constraint_count, p_swing_limit_cones.size())
	#for cone_constraint_i: int in range(p_swing_limit_cones.size()):
		#var cone_constraint: LimitCone = p_swing_limit_cones[cone_constraint_i]
		#many_bone_ik.set_kusudama_limit_cone_center(constraint_count, cone_constraint_i, cone_constraint.direction)
		#many_bone_ik.set_kusudama_limit_cone_radius(constraint_count, cone_constraint_i, cone_constraint.angle)
