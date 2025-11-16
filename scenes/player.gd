extends CharacterBody2D

@export var speed := 60

var direction_input := Vector2.ZERO
var direction_facing := Vector2.DOWN
var nearby_interactables: Array = []
var current_target: Node = null

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("interactable"):
		nearby_interactables.append(body)
		_update_current_target()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("interactable"):
		nearby_interactables.erase(body)
		_update_current_target()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearby_interactables.append(area)
		_update_current_target()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearby_interactables.erase(area)
		_update_current_target()

func _update_current_target() -> void:
	if nearby_interactables.is_empty():
		current_target = null
		return
	# TODO: Get the closest one, not just the first one.
	current_target = nearby_interactables[0]

func _try_interact() -> void:
	if current_target and current_target.has_method("interact"):
		current_target.interact(self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()

func _update_animation() -> void:
	var anim := ""
	var is_moving := velocity != Vector2.ZERO
	var interact_area = $InteractArea

	if abs(direction_facing.x) > abs(direction_facing.y):
		interact_area.rotation = -PI/2 if direction_facing.x > 0 else PI/2
		if is_moving:
			anim = "right_walk" if direction_facing.x > 0 else "left_walk"
		else:
			anim = "right_idle" if direction_facing.x > 0 else "left_idle"
	else:
		interact_area.rotation = 0.0 if direction_facing.y > 0 else PI
		if is_moving:
			anim = "down_walk" if direction_facing.y > 0 else "up_walk"
		else:
			anim = "down_idle" if direction_facing.y > 0 else "up_idle"
		
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)
		

func _physics_process(_delta: float) -> void:
	direction_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction_input != Vector2.ZERO:
		direction_facing = direction_input
	velocity = direction_input * speed
	move_and_slide()
	
	_update_animation()
