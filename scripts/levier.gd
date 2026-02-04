extends Area2D

# Signal pour prévenir tous les PNJ
signal world_changed(is_cold: bool)

@onready var animated_sprite = $AnimatedSprite2D 
@onready var map_chaude = get_node("../NavigationRegion2D/MapChaude")
@onready var map_froide = get_node("../NavigationRegion2D/MapFroide")
@onready var music_coin = get_node("/root/Game/MusicCoin")

var is_cold_world_active = false

func _ready():
	# Connecter tous les ennemis au signal dès le départ
	connect_all_enemies()

func connect_all_enemies():
	# Attendre que tous les nodes soient prêts
	await get_tree().process_frame
	
	# Trouver tous les ennemis dans la scène
	var enemies = find_all_enemies(get_tree().root)
	print("🔍 Ennemis trouvés : ", enemies.size())
	
	for enemy in enemies:
		if enemy.has_method("set_world_state"):
			world_changed.connect(enemy.set_world_state)
			print("✅ Ennemi connecté : ", enemy.name)

func find_all_enemies(node: Node) -> Array:
	var enemies = []
	
	# Si c'est un ennemi, on l'ajoute
	if node is Ennemy:
		enemies.append(node)
	
	# Parcourir tous les enfants récursivement
	for child in node.get_children():
		enemies.append_array(find_all_enemies(child))
	
	return enemies

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# 1. Animation du levier
		if animated_sprite:
			animated_sprite.play("default")
		
		# 2. Changement de décor
		if map_chaude and map_froide:
			exchange_worlds()
			play_coin_sound()
		else:
			print("❌ Erreur : MapChaude ou MapFroide introuvable !")

func exchange_worlds():
	var temp_z = map_chaude.z_index
	map_chaude.z_index = map_froide.z_index
	map_froide.z_index = temp_z
	
	# Inverser l'état du monde
	is_cold_world_active = not is_cold_world_active
	
	print("🌍 Monde actif : ", "FROID ❄️" if is_cold_world_active else "CHAUD 🔥")
	
	# Émettre le signal pour prévenir TOUS les ennemis
	world_changed.emit(is_cold_world_active)
	
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
