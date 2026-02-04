extends Control
@onready var level1 = preload("res://scenes/game.tscn")


func _on_btncommencer_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")



func _on_règle_button_down() -> void:
	pass # Replace with function body.


func _on_quitter_button_down() -> void:
	get_tree().quit()
