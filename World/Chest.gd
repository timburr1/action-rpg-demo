extends Node2D

onready var animated_sprite = $AnimatedSprite

func _on_Hitbox_area_entered(area):
	animated_sprite.playing = true
	
func game_over():
	get_tree().change_scene("GameOver.tscn")
	
 
