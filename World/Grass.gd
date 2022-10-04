extends Sprite

func create_grass_effect():
	var grass_effect = load("res://Effects/GrassEffect.tscn").instance()
	grass_effect.global_position = global_position
	get_tree().current_scene.add_child(grass_effect)		
	
func _on_Hurtbox_area_entered(area):
	create_grass_effect()
	queue_free()
