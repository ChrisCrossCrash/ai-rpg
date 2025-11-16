extends CharacterBody2D

@export var npc_name := "Buddy"

func interact(_player: CharacterBody2D) -> void:
	print("Hi! I'm " + npc_name)
