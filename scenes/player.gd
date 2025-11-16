extends CharacterBody2D

@export var speed := 60

var direction := Vector2.ZERO
var direction_last_moved := Vector2.ZERO
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
	
	if direction_last_moved == Vector2.ZERO:
		anim = "down_idle"
	else:
		if abs(direction_last_moved.x) > abs(direction_last_moved.y):
			if velocity:
				anim = "right_walk" if direction_last_moved.x > 0 else "left_walk"
			else:
				anim = "right_idle" if direction_last_moved.x > 0 else "left_idle"
		else:
			if velocity:
				anim = "down_walk" if direction_last_moved.y > 0 else "up_walk"
			else:
				anim = "down_idle" if direction_last_moved.y > 0 else "up_idle"
		
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)
		

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		direction_last_moved = direction
	velocity = direction * speed
	move_and_slide()
	
	_update_animation()
