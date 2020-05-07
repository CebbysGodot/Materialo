extends KinematicBody

var camera
var init_speed = 5
var speed = init_speed
const sensitivity = 0.2
const accel = 10
var velocity = Vector3()

var CHUNK_POS:Vector3

func get_chunk_pos():
	return CHUNK_POS

func _ready():
	CHUNK_POS = Vector3(0, 0, 0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera = get_node("Camera")

func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	speed = init_speed
	if Input.is_action_pressed("move_slower"): speed = init_speed - 3
	elif Input.is_action_pressed("move_faster"): speed = init_speed + 10
	var target_dir = Vector2(0, 0)
	var should_move = false
	var up_dir = 1
	if Input.is_action_pressed("move_left"):
		target_dir.x -= 1
		should_move = true
		up_dir = 0
	if Input.is_action_pressed("move_right"):
		target_dir.x += 1
		should_move = true
		up_dir = 0
	if Input.is_action_pressed("move_forw"):
		target_dir.y -= 1
		should_move = true
		up_dir = 1
	if Input.is_action_pressed("move_back"):
		target_dir.y += 1
		should_move = true
		up_dir = -1
		
	target_dir = target_dir.normalized().rotated(-rotation.y)
	var lookup = 1 - abs(camera.rotation.x * 2 / PI)
	velocity.x = lerp(velocity.x, target_dir.x * speed * lookup, accel * _delta)
	velocity.y = lerp(velocity.y, camera.rotation.x * 2 / PI * speed * up_dir, accel * _delta)
	velocity.z = lerp(velocity.z, target_dir.y * speed * lookup, accel * _delta)
	
	if should_move:
		var _t = move_and_slide(velocity)
#		var pos = translation
#		if pos.x > 16: translation.x = 0
#		elif pos.x < 0: translation.x = 16
#		if pos.y > 16: translation.y = 0
#		elif pos.y < 0: translation.y = 16
#		if pos.z > 16: translation.z = 0
#		elif pos.z < 0: translation.z = 16
	CHUNK_POS = Vector3(
		floor(translation.x / 4),
		floor(translation.y / 4),
		floor(translation.z / 4)
	)

func _input(event):
	if event is InputEventMouseMotion:
		var dir = event.relative
		camera.rotation.x += -deg2rad(dir.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(-90), deg2rad(90))
		rotation.y += -deg2rad(dir.x * sensitivity)
