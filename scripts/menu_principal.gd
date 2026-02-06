extends Control

func _on_play_button_pressed():
	# Le chemin vers game.tscn doit être exact (minuscules/majuscules)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_rules_button_pressed():
	# Affiche la page des crédits/règles
	get_tree().change_scene_to_file("res://scenes/page_crédits.tscn")

func _on_back_button_button_down() -> void:
	# Quitte le jeu proprement
	get_tree().quit()
