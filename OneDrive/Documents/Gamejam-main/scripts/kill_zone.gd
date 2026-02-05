extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# On vérifie si c'est bien le joueur qui est tombé
	if body.name == "Player":
		print("Le joueur est tombé !")
		die_and_restart()

func die_and_restart():
	# Option 1 : Recharger la scène complète (plus simple)
	get_tree().reload_current_scene()
	
	# Option 2 : Téléporter le joueur au début (plus fluide)
	# body.position = Vector2(100, 100) # Remplacez par vos coordonnées de départ
