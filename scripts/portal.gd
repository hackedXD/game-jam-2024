extends Node3D
class_name Portal

@export var player: Player
@export var other_portal: Portal

@export var shader: Shader


@onready var display = $Portal
@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera = $SubViewport/Camera3D
@onready var area_3d: Area3D = $Area3D
var tracked = {}

func _ready():
	if other_portal and other_portal.is_node_ready():	
		display.set_layer_mask_value(2, true)
		camera.set_cull_mask_value(2, false)
		
		other_portal.display.set_layer_mask_value(3, true)
		other_portal.camera.set_cull_mask_value(3, false)
		
		display.material.set_shader_parameter("source", other_portal.sub_viewport.get_texture())
		other_portal.display.material.set_shader_parameter("source", sub_viewport.get_texture())
		
		#other_portal.display.visible = false
	sub_viewport.size = get_viewport().size
	
	
func _process(delta):
	if not other_portal: return
	camera.global_transform = self.global_transform * other_portal.global_transform.affine_inverse() * player.head.global_transform
	camera.near = max((position - camera.position).length() - 1.5, 0.05)
	for body in tracked.keys():
		var normal = global_basis.z
		var dir = player.global_position - global_position
		
		var portalSide = sign(normal.dot(dir))
		var oldPortalSide = sign(normal.dot(tracked[body]))
		
		tracked[body] = dir
		if (portalSide != oldPortalSide):
			tracked.erase(body)
			
			if body is Player:
				other_portal.display.visible = false
				var old_orientation = Vector2(body.head.rotation.x, body.rotation.y)
				var old_rotation = body.rotation
				
				body.global_transform = other_portal.global_transform * self.global_transform.affine_inverse() * body.global_transform
				
				body.rotation = old_rotation
				
				var relative_rotation = (other_portal.global_basis * global_basis.inverse())
				body.velocity = relative_rotation * body.velocity
				body.direction = relative_rotation * body.direction
				
				relative_rotation = relative_rotation.get_euler()
				
				body.rotation_target.x += relative_rotation.x
				body.head.rotation.x = old_orientation.x + relative_rotation.x
				
				body.rotation_target.y += relative_rotation.y
				body.rotation.y = old_orientation.y + relative_rotation.y
				
				#if shader:
					#body.shader_mesh.mesh.material.shader = shader
			else:
				body.global_transform = other_portal.global_transform * self.global_transform.affine_inverse() * body.global_transform
				
				
			


func _on_area_3d_body_entered(body):	
	if not other_portal: return
	#other_portal.display.visible = false
	#display.visible = false
	#
	if body is PhysicsBody3D:
		body.set_collision_mask_value(1, false)
	
	
	if body.is_in_group("teleportable"):
		#display.size.z = 2
		tracked[body] = body.global_position - global_position

func _on_area_3d_body_exited(body):
	if not other_portal: return
	#other_portal.display.visible = true
	#display.visible = true
	#display.size.z = 0.5
	#other_portal.display.size.z = 0.5
	
	if body is PhysicsBody3D:
		body.set_collision_mask_value(1, true)
		
	if tracked.has(body):
		tracked.erase(body)
	display.visible = true
