extends Node

signal wave_changed(wave_number)

var current_wave = 0
var enemies_alive = 0

func start_next_wave():
	current_wave += 1
	enemies_alive = current_wave + 1  # Ta règle : Manche + 1
	wave_changed.emit(current_wave)
	spawn_wave()

func spawn_wave():
	for i in range(enemies_alive):
		spawn_enemy()

func spawn_enemy():
	var enemy_scene = load("res://scenes/pnj.tscn")
	var enemy = enemy_scene.instantiate()
	
	# Il va chercher dans le groupe de points que tu viens de créer
	var spawn_node = get_tree().current_scene.get_node("SpawnPoints")
	var points = spawn_node.get_children()
	var random_point = points.pick_random()
	
	enemy.global_position = random_point.global_position
	get_tree().current_scene.add_child(enemy)

func enemy_died():
	enemies_alive -= 1
	if enemies_alive <= 0:
		start_next_wave()
