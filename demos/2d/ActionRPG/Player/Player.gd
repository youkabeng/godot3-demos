extends KinematicBody2D
const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500
const PLAYER_HURT_SOUND = preload("res://Player/AudioStreamPlayer.tscn")

enum STATE {
	MOVE,
	ROLL,
	ATTACK
}

var velocity = Vector2.ZERO
var state = STATE.MOVE
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitBox = $HitBoxPosition/SwordHitBox
onready var hurtbox = $HurtBox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitBox.knockback_vector = roll_vector

func _process(delta):
	match state:
		STATE.MOVE:
			state_move(delta)
		
		STATE.ROLL:
			state_roll(delta)
			
		STATE.ATTACK:
			state_attack()

func state_move(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitBox.knockback_vector = roll_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animationState.travel("Idle")
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("attack"):
		velocity = Vector2.ZERO
		state = STATE.ATTACK
	
	if Input.is_action_just_pressed("roll"):
		velocity = Vector2.ZERO
		state = STATE.ROLL


func state_attack():
	velocity = Vector2.ZERO
	animationState.travel("Attack")


func state_roll(delta):
	velocity = roll_vector * MAX_SPEED * 1.5
	animationState.travel("Roll")
	move_and_slide(velocity)


func roll_animation_finished():
	velocity = Vector2.ZERO
	state = STATE.MOVE


func attack_animation_finished():
	state = STATE.MOVE


func _on_HurtBox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(0.6)
	hurtbox.show_hit_effect()
	var playerHurtSound = PLAYER_HURT_SOUND.instance()
	get_tree().current_scene.add_child(playerHurtSound)


func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
