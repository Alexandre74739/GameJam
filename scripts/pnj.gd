extends CharacterBody2D

const SPEED = 60
var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# 1. Gestion de la gravité
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. Détection du vide (Mort du PNJ)
	# Si la position Y dépasse une certaine limite (ex: 500), le PNJ meurt
	if global_position.y > 500: 
		die_pnj()

	# 3. Détection des murs pour changer de direction
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	# 4. Application du mouvement
	velocity.x = direction * SPEED
	move_and_slide()

# Fonction pour la mort du PNJ
func die_pnj():
	print("mort pnj")
	queue_free() # Supprime le PNJ du jeu

# Détection du joueur via l'Area2D
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("die"):
			body.die() # Déclenche la mort du joueur (avec l'attente de 3s)
