extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELARATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var EPSILON = 4

enum {IDLE, WANDER, CHASE}

var state = IDLE
var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var soft_collsion = $SoftCollision
onready var wander_controller = $WanderController

func _ready():
	state = pick_random_state([IDLE, WANDER])
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE: 
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wander_controller.get_time_left() == 0:
				new_state()
				
		WANDER: 
			seek_player()
			if wander_controller.get_time_left() == 0:
				new_state()
				
			accelerate_toward(wander_controller.target_position, delta)
			
			if global_position.distance_to(wander_controller.target_position) <= EPSILON:
				new_state()
			
		CHASE: 
			var player = player_detection_zone.player
			if player != null:
				accelerate_toward(player.global_position, delta)
			else:
				state = IDLE
				
	if soft_collsion.is_colliding():
		velocity += soft_collsion.get_push_vector() * delta * 350
	velocity = move_and_slide(velocity)

func accelerate_toward(target_position, delta):
	var direction = global_position.direction_to(target_position)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELARATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE

func new_state():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_timer(rand_range(1, 3))
				
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
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
	
