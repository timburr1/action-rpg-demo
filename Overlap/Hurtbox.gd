extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible

onready var timer = $Timer
onready var collision_shape = $CollisionShape2D
signal invincibility_started
signal invincibility_ended

func set_invincible(val):
	invincible = val
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var hit_effect = HitEffect.instance()
	get_tree().current_scene.add_child(hit_effect)
	hit_effect.global_position = global_position

func _on_Timer_timeout():
	self.invincible = false

func _on_Hurtbox_invincibility_started():
	collision_shape.set_deferred("disabled", true)
	
func _on_Hurtbox_invincibility_ended():
	collision_shape.set_deferred("disabled", false)

