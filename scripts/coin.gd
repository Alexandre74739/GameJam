extends Area2D

# On accède aux maps via le parent (Game)
@onready var map_chaude = get_node("/root/Game/MapChaude")
@onready var map_froide = get_node("/root/Game/MapFroide")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		exchange_worlds()
		# On ne met PAS de queue_free() ici pour que la pièce reste !

func exchange_worlds():
	# 1. Échange des Z-Index des maps parentes
	var temp_z = map_chaude.z_index
	map_chaude.z_index = map_froide.z_index
	map_froide.z_index = temp_z
	
	# 2. Mise à jour de l'état des plateformes
	# On active celle qui a le Z-index le plus haut (0 ou plus)
	if map_chaude.z_index >= 0:
		update_platforms(map_chaude, true)
		update_platforms(map_froide, false)
	else:
		update_platforms(map_chaude, false)
		update_platforms(map_froide, true)

func update_platforms(map_node: Node2D, is_active: bool):
	var platforms = map_node.get_node_or_null("Platforms")
	if platforms:
		# On aligne le Z-index du nœud Platforms sur celui de sa map
		platforms.z_index = map_node.z_index
		
		# On active/désactive la physique (Collision)
		platforms.process_mode = PROCESS_MODE_INHERIT if is_active else PROCESS_MODE_DISABLED
		
		# On rend visible ou invisible
		if platforms is CanvasItem:
			platforms.visible = is_active
