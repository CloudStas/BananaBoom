extends Area2D

const SPEED = 250.0          # starting speed going out
const OUT_TIME = 1         # seconds spent flying out before turning around
const RETURN_ACCEL = 600.0   # how fast it speeds up on the way back
const RETURN_MAX_SPEED = 300.0
const CATCH_DISTANCE = 10.0  # how close to the thrower counts as "caught"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var direction := Vector2.LEFT   # set by the player when thrown
var thrower: Node2D             # set by the player when thrown

var returning := false
var time := 0.0
var return_speed := 0.0


func _ready() -> void:
	anim.play("Spinning")
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if not returning:
		# Fly outward, slowing down until it stops, then turn around
		time += delta
		var t: float = clamp(time / OUT_TIME, 0.0, 1.0)
		global_position += direction * SPEED * (1.0 - t) * delta
		if t >= 1.0:
			returning = true
	else:
		# Home in on the thrower (even if they've moved)
		if not is_instance_valid(thrower):
			queue_free()
			return
		var to_thrower := thrower.global_position - global_position
		if to_thrower.length() <= CATCH_DISTANCE:
			queue_free()  # caught!
			return
		return_speed = min(return_speed + RETURN_ACCEL * delta, RETURN_MAX_SPEED)
		global_position += to_thrower.normalized() * return_speed * delta


func _on_body_entered(body: Node) -> void:
	if body == thrower:
		return
	# Hurt anything that knows how to take a hit; the banana keeps flying
	if body.has_method("take_hit"):
		body.take_hit()
