extends Area2D

func _ready():
	visible = false
	monitoring = false

func appear():
	visible = true
	monitoring = true
	print("PORTAIL ACTIF!")

func _on_body_entered(body):
	print("TELEPORTATION!")
	get_tree().change_scene_to_file("res://scenes/world_story.tscn")
