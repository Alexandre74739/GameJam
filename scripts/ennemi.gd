extends CharacterBody2D

@export var speed = 150.0
@export var jump_velocity = -400.0
@onready var nav_agent = $NavigationAgent2D
@onready var player = get_tree().root.find_child("Player", true, false)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Appliquer la gravité
	if not is_on_floor():
		velocity.y += gravity * delta

	if player:
		# Mise à jour de la cible
		nav_agent.target_position = player.global_position
		
		# Calcul de la direction vers le prochain point du chemin
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		
		velocity.x = direction.x * speed
		
		# Logique de saut si obstacle devant (mur ou plateforme)
		if is_on_wall() and is_on_floor():
			velocity.y = jump_velocity

	move_and_slide()
