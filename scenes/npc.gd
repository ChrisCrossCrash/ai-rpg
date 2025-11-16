extends CharacterBody2D

@export var npc_name := "Buddy"

func interact(_player: CharacterBody2D) -> void:
	var dialog_box := get_tree().current_scene.get_node("CanvasLayer/DialogBox")
	var message = "Hi! I'm " + npc_name
	dialog_box.show_dialog(message)
