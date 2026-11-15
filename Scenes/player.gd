extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

const BANANA_SCENE = preload("res://Scenes/banana.tscn")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var facing := -1
var is_throwing := false
var banana: Node = null   # the banana currently in flight (boomerang: one at a time)


func _ready() -> void:
	if not InputMap.has_action("throw"):
		InputMap.add_action("throw")
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_F
		InputMap.action_add_event("throw", ev)

	anim.sprite_frames.set_animation_loop("Jump", false)
	anim.sprite_frames.set_animation_loop("ThrowLeft", false)
	anim.animation_finished.connect(_on_animation_finished)

	if not anim.sprite_frames.has_animation("Idle"):
		push_warning("No 'Idle' animation found - create one in the SpriteFrames panel.")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Can only throw if not mid-throw and the last banana has come back
	if Input.is_action_just_pressed("throw") and not is_throwing and not is_instance_valid(banana):
		_start_throw()

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		facing = int(sign(direction))
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_update_animation(direction)


func _start_throw() -> void:
	is_throwing = true
	anim.flip_h = facing > 0
	anim.play("ThrowLeft")
	_spawn_banana()


func _spawn_banana() -> void:
	banana = BANANA_SCENE.instantiate()
	banana.thrower = self
	banana.direction = Vector2(facing, 0)
	banana.global_position = global_position + Vector2(facing * 10, -2)
	# Add to the parent so the banana doesn't move with the player
	get_parent().add_child(banana)


func _update_animation(direction: float) -> void:
	if is_throwing:
		return

	anim.flip_h = false

	if not is_on_floor():
		if anim.animation != "Jump":
			anim.play("Jump")
	elif direction < 0:
		anim.play("RunningLeft")
	elif direction > 0:
		anim.play("RunningRight")
	elif anim.sprite_frames.has_animation("Idle"):
		anim.play("Idle")
	else:
		anim.stop()


func _on_animation_finished() -> void:
	if anim.animation == "ThrowLeft":
		is_throwing = false
		anim.flip_h = false
