extends CharacterBody2D

@export var speed = 70.0 # Vitesse réduite pour plus de jouabilité
@export var jump_velocity = -300.0
@onready var nav_agent = $NavigationAgent2D
@onready var player = get_tree().root.find_child("Player", true, false)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 1. Appliquer la gravité
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. IA de poursuite
	if player:
		# Mise à jour de la cible pour le pathfinding
		nav_agent.target_position = player.global_position
		
		# Calcul du chemin (nécessite d'avoir cliqué sur "Précalculer")
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		
		velocity.x = direction.x * speed
		
		# Logique de saut automatique
		if is_on_wall() and is_on_floor():
			velocity.y = jump_velocity

	move_and_slide()

# --- LES FONCTIONS DE DÉTECTION DOIVENT ÊTRE EN DEHORS DE _PHYSICS_PROCESS ---

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# On vérifie que le joueur possède bien la fonction die() pour éviter un crash
		if body.has_method("die"):
			body.die()
