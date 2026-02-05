extends Node

signal wave_changed(wave_number)

const MAX_ENEMIES = 20 # Limite pour éviter les lags
var current_enemies_count = 0
var total_kills = 0
var portal_unlocked = false

func reset ():
	current_enemies_count = 0
	total_kills = 0
	portal_unlocked = false

func _ready():
	await get_tree().create_timer(1.0).timeout
	spawn_enemy()
	spawn_enemy()

func spawn_enemy():
	if current_enemies_count >= MAX_ENEMIES:
		return

	var enemy_scene = load("res://scenes/pnj.tscn")
	var enemy = enemy_scene.instantiate()
	
	# Utilise tes points de spawn Marker2D
	var spawn_node = get_tree().current_scene.get_node_or_null("SpawnPoints")
	if spawn_node:
		var points = spawn_node.get_children()
		if points.size() > 0:
			var random_point = points.pick_random()
			enemy.global_position = random_point.global_position
			get_tree().current_scene.add_child(enemy)
			current_enemies_count += 1

func enemy_died():
	current_enemies_count -= 1
	total_kills += 1
	
	# CONDITION DE LA PORTE : Apparition à 10 kills
	if total_kills >= 10 and not portal_unlocked:
		# On cherche le nœud "Portal" dans toute la scène active
		var portal = get_tree().current_scene.find_child("Portal", true, false)
		
		if portal:
			portal.appear() # On appelle la fonction créée plus haut
			portal_unlocked = true
		else:
			print("Erreur : Nœud 'Portal' introuvable dans la scène !")
	
	# 1 mort = 2 nouveaux spawns (si la limite le permet)
	spawn_enemy()
	spawn_enemy()
