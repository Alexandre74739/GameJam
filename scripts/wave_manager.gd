extends Node

signal wave_changed(wave_number)

const MAX_ENEMIES = 20 # Limite maximale sur la carte
var current_enemies_count = 0
var total_kills = 0

func _ready():
	await get_tree().create_timer(1.0).timeout
	# On commence avec 2 ennemis pour lancer le défi
	spawn_enemy()
	spawn_enemy()

func spawn_enemy():
	# Si on a déjà trop d'ennemis, on n'en crée pas d'autre
	if current_enemies_count >= MAX_ENEMIES:
		return

	var enemy_scene = load("res://scenes/pnj.tscn")
	var enemy = enemy_scene.instantiate()
	
	var spawn_node = get_tree().current_scene.get_node_or_null("SpawnPoints")
	if spawn_node:
		var points = spawn_node.get_children()
		if points.size() > 0:
			var random_point = points.pick_random()
			enemy.global_position = random_point.global_position
			get_tree().current_scene.add_child(enemy)
			current_enemies_count += 1 # On augmente le compteur

func enemy_died():
	current_enemies_count -= 1 # Une place se libère
	total_kills += 1
	
	# On tente d'en faire apparaître 2 pour 1 mort (si la limite le permet)
	spawn_enemy()
	spawn_enemy()
	
	# Optionnel : émettre un signal si tu veux afficher le score (total_kills)
