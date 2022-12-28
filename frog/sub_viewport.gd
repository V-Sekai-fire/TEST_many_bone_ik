extends Control

var lasso_db : LassoDB = LassoDB.new()

var points : Array[Node3D] = []

func _ready():
#	DisplayServer.window_set_mouse_passthrough($Path2D.curve.get_baked_points())
	set_process_input(true)
	var hips : Node3D = $SubViewportContainer/SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/Hips
	var head : Node3D = $SubViewportContainer/SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/Head
	var left_hand : Node3D = $SubViewportContainer/SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/LeftHand
	var right_hand : Node3D = $SubViewportContainer/SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/RightHand
	var left_foot : Node3D = $SubViewportContainer/SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/LeftFoot
	var right_foot : Node3D = $SubViewportContainer/SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/RightFoot
	points.append_array([hips, head, left_hand, right_hand, left_foot, right_foot])

	for point in points:
		var lasso_point : LassoPoint = LassoPoint.new()
		point.lasso_point = lasso_point
		lasso_point.register_point(lasso_db, point)

var dragging = false

func _input(event):	
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
		elif event.button_mask == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false

	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT and dragging:
		var motion = event.relative * 0.0008
		var pointer : Node3D = $SubViewportContainer/SubViewport/Pointer
		pointer.global_transform.origin = pointer.global_transform.origin + Vector3(motion.x, -motion.y, 0.0)

	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_RIGHT and dragging:
		var motion = event.relative * 0.0005
		var pointer : Node3D = $SubViewportContainer/SubViewport/Pointer
		var viewport : Transform3D = $SubViewportContainer/SubViewport/Camera3D.get_camera_transform()
		var snapped_nodes : Array = lasso_db.calc_top_two_snapping_power(pointer.global_transform, pointer, 0, 0, false)
		for snapped_point in snapped_nodes:
			var snapped_node = snapped_point.get_origin()
			$SubViewportContainer/SubViewport/Label3D.text = snapped_node.get_name()
			snapped_node.global_transform.origin = snapped_node.global_transform.origin + Vector3(motion.x, -motion.y, 0.0)
			break
