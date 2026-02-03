extends Node

signal wave_changed(wave_number)

var current_wave = 1
# On n'a plus forcément besoin de "enemies_alive" pour bloquer, 
# puisque ça spawn à l'infini selon tes morts.

func _ready():
	# Petit délai pour laisser la scène charger
	await get_tree().create_timer(1.0).timeout
	wave_changed.emit(current_wave)
	# On commence avec un premier ennemi pour lancer la boucle
	spawn_enemy()

func spawn_enemy():
	var enemy_scene = load("res://scenes/pnj.tscn")
	var enemy = enemy_scene.instantiate()
	
	# Trouve le nœud contenant les Marker2D
	var spawn_node = get_tree().current_scene.get_node_or_null("SpawnPoints")
	if spawn_node:
		var points = spawn_node.get_children()
		if points.size() > 0:
			var random_point = points.pick_random()
			enemy.global_position = random_point.global_position
			get_tree().current_scene.add_child(enemy)

func enemy_died():
	# Dès qu'un ennemi meurt (tué ou vide), on en crée 2
	spawn_enemy()
	spawn_enemy()
	
	# Optionnel : On augmente le compteur de score/vague tous les X morts
	# ou on considère que chaque mort fait progresser la difficulté.
