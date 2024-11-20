extends CharacterBody3D
class_name Player

@export var mouse_sensitivity: float = 700
@export var movement_speed: float = 10
@export var jump_velocity: float = 8

@onready var shader_mesh = $Head/Camera3D/MeshInstance3D

@onready var head = $Head
@onready var rotation_target: Vector3 = head.rotation
@onready var blaster = $Head/Camera3D/Blaster
@onready var raycast = $Head/Camera3D/RayCast3D

var current_portal_is_portal_1 = true
var portal1: Portal
var portal2: Portal

var direction: Vector3 = Vector3.ZERO
var input_mouse: Vector2 = Vector2.ZERO

func enable_gun():
	var end_pos = blaster.position
	blaster.position.y -= 1
	blaster.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(blaster, "position", end_pos, 0.5).set_trans(Tween.TRANS_CUBIC)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 20 * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = direction.lerp((transform.basis * Vector3(input.x, 0, input.y)).normalized(), delta * 10)
	
	var applied_velocity = velocity.lerp(direction * movement_speed, delta * 10)
	applied_velocity.y = velocity.y
	
	velocity = applied_velocity
	
	head.rotation.z = lerp_angle(head.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	head.rotation.x = lerp_angle(head.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("skip"):
		position = Vector3(0, 5, 100)
	
	if Input.is_action_just_pressed("shoot") and blaster.visible:
		print("shoot")
		var old_pos = blaster.position
		blaster.position.z += 0.2
		
		var tween = get_tree().create_tween()
		tween.tween_property(blaster, "position", old_pos, 0.1).set_trans(Tween.TRANS_CUBIC)
		
		head.rotation.x += 0.025
		
		raycast.force_raycast_update()
		var point = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		
		print(normal)

		var normal_rotation = {
			Vector3.UP: Vector3(PI / 2, 0, 0),
			Vector3.DOWN: Vector3(- PI / 2, 0, 0),
			Vector3.RIGHT: Vector3(0, -PI / 2, 0),
			Vector3.LEFT: Vector3(0, PI / 2, 0),
			Vector3.FORWARD: Vector3(0, 0, 0), # works
			Vector3.BACK: Vector3(0, 0, 0)
		}[normal]
		
		
		if current_portal_is_portal_1:
			if not portal1:
				portal1 = preload("res://scenes/portal.tscn").instantiate()
				portal1.player = self
				portal1.top_level = true
				
				add_child(portal1)
				
			#portal1.rotate_y(PI)
			portal1.rotation = normal_rotation
			portal1.position = point
		else:
			if not portal2:
				portal2 = preload("res://scenes/portal.tscn").instantiate()
				portal2.player = self
				portal2.top_level = true
				
				portal1.other_portal = portal2
				portal2.other_portal = portal1
				
				add_child(portal2)
				
			portal2.rotation = -normal_rotation
			portal2.position = point
			
		current_portal_is_portal_1 = !current_portal_is_portal_1
		
		

func _input(event):
	if event is InputEventMouseMotion:
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity	
