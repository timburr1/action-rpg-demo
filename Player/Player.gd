extends KinematicBody2D

const PlayerHurtSound = preload("res://Music and Sounds/PlayerHurtSound.tscn")

const ACCELERATION = 500
const MAX_SPEED = 80
const ROLL_SPEED = 1.2
const FRICTION = 500

enum {
	MOVE, ROLL, ATTACK
}

var state = MOVE 
var velocity = Vector2.ZERO
var roll_vector = Vector2.ZERO
var stats = PlayerStats

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blink_animation_player = $BlinkAnimationPlayer

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true
	sword_hitbox.knockback_vector = roll_vector	
	
	# We shouldn't need the following line, but I could not disable that hitbox in the IDE
	$HitboxPivot/SwordHitbox/CollisionShape2D.disabled = true
	# Similarly, make sure that the blink animation is off:
	blink_animation_player.play("Stop")

func _physics_process(_delta):
	match state:
		MOVE: move_state()
		ROLL: roll_state()
		ATTACK: attack_state()

func move_state():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")		
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		sword_hitbox.knockback_vector = input_vector
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)

	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("roll"):
		state = ROLL

func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

func attack_animation_finished():
	state = MOVE

func move():
	velocity = move_and_slide(velocity)
	
func roll_state():
	velocity = roll_vector * MAX_SPEED * ROLL_SPEED
	animation_state.travel("Roll")
	move()

func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
	var player_hurt_sound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(player_hurt_sound)

func _on_Hurtbox_invincibility_started():
	blink_animation_player.play("Start")

func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Stop")
