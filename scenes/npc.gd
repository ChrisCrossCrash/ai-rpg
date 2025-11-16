extends CharacterBody2D

@export var npc_name := "Buddy"

func interact(_player: CharacterBody2D) -> void:
	var dialog_box := get_tree().current_scene.get_node("CanvasLayer/DialogBox")
	print(dialog_box)
	var first_line := "Hi! I'm %s! What's your name, traveller?" % npc_name
	dialog_box.start_conversation(first_line)
