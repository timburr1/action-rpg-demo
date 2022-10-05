extends Area2D

export(bool) var show_hit = true

const HitEffect = preload("res://Effects/HitEffect.tscn")

func _on_Hurtbox_area_entered(area):
	if show_hit:
		var hit_effect = HitEffect.instance()
		get_tree().current_scene.add_child(hit_effect)
		hit_effect.global_position = global_position

