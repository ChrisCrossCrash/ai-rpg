extends CharacterBody2D

@export var speed := 60

var direction := Vector2.ZERO
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

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
