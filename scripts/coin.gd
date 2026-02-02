extends Area2D

@onready var map_chaude = get_node("/root/Game/MapChaude")
@onready var map_froide = get_node("/root/Game/MapFroide")

# On ne récupère que la musique de la pièce ici
@onready var music_coin = get_node("/root/Game/MusicCoin")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		exchange_worlds()
		play_coin_sound() # On lance le son spécial

func exchange_worlds():
	# Échange des Z-index
	var temp_z = map_chaude.z_index
	map_chaude.z_index = map_froide.z_index
	map_froide.z_index = temp_z
	
	# Mise à jour des plateformes
	if map_chaude.z_index >= 0:
		update_platforms(map_chaude, true)
		update_platforms(map_froide, false)
	else:
		update_platforms(map_chaude, false)
		update_platforms(map_froide, true)

func update_platforms(map_node: Node2D, is_active: bool):
	var platforms = map_node.get_node_or_null("Platforms")
	if platforms:
		platforms.z_index = map_node.z_index
		platforms.process_mode = PROCESS_MODE_INHERIT if is_active else PROCESS_MODE_DISABLED
		if platforms is CanvasItem:
			platforms.visible = is_active

func play_coin_sound():
	# On joue le son de la pièce sans arrêter la musique générale
	if music_coin.playing:
		music_coin.stop() # On recommence le son si on touche une autre pièce vite
	music_coin.play()
