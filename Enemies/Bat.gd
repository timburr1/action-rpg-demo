extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELARATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum {IDLE, WANDER, CHASE}

var state = IDLE
var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var soft_collsion = $SoftCollision

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE: 
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER: pass
		
		CHASE: 
			var player = player_detection_zone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELARATION * delta)
			else:
				state = IDLE
				
			sprite.flip_h = velocity.x < 0
			
	if soft_collsion.is_colliding():
		velocity += soft_collsion.get_push_vector() * delta * 350
	velocity = move_and_slide(velocity)

func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 125
	# hurtbox.start_invincibility(0.1)
	hurtbox.create_hit_effect()

func _on_Stats_no_health():	
	queue_free()
	var enemy_death_effect = EnemyDeathEffect.instance()
	enemy_death_effect.global_position = global_position
	get_parent().add_child(enemy_death_effect)
	
