extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_replaybtn_button_down() -> void:
	# Enlever la pause et nettoyer avant de relancer
	get_tree().paused = false
	get_parent().queue_free()  # Supprimer le CanvasLayer
	$"/root/WaveManager".reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menubtn_button_down() -> void:
	# Enlever la pause et nettoyer avant de revenir au menu
	get_tree().paused = false
	get_parent().queue_free()  # Supprimer le CanvasLayer
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
