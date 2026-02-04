extends Control

# On récupère les références des nodes en haut du script pour plus de clarté
@onready var rules_panel = $RulesPanel

func _on_play_button_pressed():
	# Le chemin vers game.tscn doit être exact (minuscules/majuscules)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_rules_button_pressed():
	rules_panel.show() # Affiche le panneau quand on clique sur Règles
	rules_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(rules_panel, "modulate:a", 1.0, 0.3)

func _on_back_button_pressed(): 
	rules_panel.hide() # Cache le panneau
	


func _on_back_button_button_down() -> void:
	get_tree().quit()
