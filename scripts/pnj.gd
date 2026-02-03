extends CharacterBody2D
class_name Ennemy

const SPEED = 80.0
@onready var nav_agent = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("Player")

func _on_killzone_body_entered(body: Node2D) -> void:
	if body is Player: # Utilise la class_name que tu as créée
		print("Le joueur est touché !")
		body.die()

func _physics_process(delta):
	# 1. Gravité
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	# 2. IA de suivi
	if player:
		nav_agent.target_position = player.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_path_pos = nav_agent.get_next_path_position()
			var direction = (next_path_pos - global_position).normalized()
			velocity.x = direction.x * SPEED
			$AnimatedSprite2D.flip_h = velocity.x < 0
	
	move_and_slide()

func die_pnj():
	if WaveManager: # Vérifie que l'Autoload existe
		WaveManager.enemy_died()
	queue_free()
