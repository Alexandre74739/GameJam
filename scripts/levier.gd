extends Area2D

# On récupère l'AnimatedSprite2D pour jouer l'animation
@onready var animated_sprite = $AnimatedSprite2D 
@onready var map_chaude = get_node("../NavigationRegion2D/MapChaude")
@onready var map_froide = get_node("../NavigationRegion2D/MapFroide")
@onready var music_coin = get_node("/root/Game/MusicCoin")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# 1. On lance l'animation de déclenchement
		if animated_sprite:
			animated_sprite.play("default")
		
		# 2. On effectue le changement de décor
		if map_chaude and map_froide:
			exchange_worlds()
			play_coin_sound()
		else:
			print("Erreur : MapChaude ou MapFroide introuvable au chemin spécifié !")

func exchange_worlds():
	var temp_z = map_chaude.z_index
	map_chaude.z_index = map_froide.z_index
	map_froide.z_index = temp_z
	
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
	if music_coin:
		if music_coin.playing:
			music_coin.stop()
		music_coin.play()
