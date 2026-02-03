extends Control


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

# On récupère les références des nodes
@onready var rules_panel = $RulesPanel

func _on_rules_button_pressed():
	rules_panel.show() # Affiche le panneau quand on clique sur Règles

func _on_back_button_pressed(): 
	# (Crée un bouton "Retour" dans ton RulesPanel si ce n'est pas fait)
	rules_panel.hide() # Cache le panneau
