extends Node

signal wave_changed(wave_number)
signal all_enemies_defeated

var current_wave = 0
var enemies_alive = 0
var spawn_points = []

# Chemin corrigé
var enemy_scene = preload("res://scenes/pnj.tscn")

func start_next_wave():
	current_wave += 1
	var enemies_to_spawn = current_wave + 1
	
	emit_signal("wave_changed", current_wave)
	print("=== VAGUE ", current_wave, " : ", enemies_to_spawn, " ennemis ===")
	
	# Spawn des ennemis
	for i in range(enemies_to_spawn):
		spawn_enemy()
	
	enemies_alive = enemies_to_spawn

func spawn_enemy():
	if spawn_points.size() == 0:
		push_error("Aucun point de spawn défini !")
		return
	
	# Choisir un point de spawn aléatoire
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	
	# Créer l'ennemi
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position
	
	# L'ajouter à la scène principale
	get_tree().current_scene.add_child(enemy)

func enemy_died():
	enemies_alive -= 1
	print("Ennemi mort ! Restants : ", enemies_alive)
	
	if enemies_alive <= 0:
		print("=== VAGUE TERMINÉE ===")
		emit_signal("all_enemies_defeated")
		# Attendre 2 secondes avant la prochaine vague
		await get_tree().create_timer(2.0).timeout
		start_next_wave()

func set_spawn_points(points: Array):
	spawn_points = points
	print("Points de spawn configurés : ", spawn_points.size())
