extends Node3D

@onready var blaster = $blasterR2

func _process(delta):
	blaster.rotate_z(delta * 4)


func _on_area_3d_body_entered(body):
	if body is Player and blaster.visible:
		body.enable_gun()
		blaster.visible = false
