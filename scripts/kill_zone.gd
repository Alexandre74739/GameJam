extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Utilise call_deferred pour attendre que la physique soit finie
		call_deferred("die_and_restart")

func reset_game():
	get_tree().reload_current_scene()

func die_and_restart():
	# Option 1 : Recharger la scène complète (plus simple)
	get_tree().reload_current_scene()
	
	# Option 2 : Téléporter le joueur au début (plus fluide)
	# body.position = Vector2(100, 100) # Remplacez par vos coordonnées de départ
