extends CharacterBody2D
class_name Ennemy

const SPEED = 80.0
const JUMP_VELOCITY = -300.0 

@onready var nav_agent = $NavigationAgent2D
@onready var _animated_sprite = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("Player")

var is_dead = false

func _on_killzone_body_entered(body: Node2D) -> void:
	if is_dead: return
	if body is Player:
		body.die()

func _physics_process(delta):
	if is_dead: return

	# 1. Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# 2. IA de suivi avec Saut
	if player:
		nav_agent.target_position = player.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_path_pos = nav_agent.get_next_path_position()
			var direction = (next_path_pos - global_position).normalized()
			
			# Saut intelligent si obstacle ou plateforme
			if next_path_pos.y < global_position.y - 20 and is_on_floor():
				velocity.y = JUMP_VELOCITY
			
			velocity.x = direction.x * SPEED
			_animated_sprite.flip_h = velocity.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	update_animations()

func update_animations():
	if not is_on_floor():
		_animated_sprite.play("jump")
	elif velocity.x != 0:
		_animated_sprite.play("walk")
	else:
		_animated_sprite.play("idle")

# CETTE FONCTION EST APPELÉE PAR LE PLAYER
func die_pnj():
	if is_dead: return
	is_dead = true
	
	# 1. Prévenir le WaveManager immédiatement
	if WaveManager:
		WaveManager.enemy_died()
	
	# 2. Désactiver physiquement l'ennemi (il ne peut plus toucher ni être touché)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	velocity = Vector2.ZERO
	
	# 3. Animation et Disparition
	if _animated_sprite.sprite_frames.has_animation("death"):
		_animated_sprite.play("death")
		# On attend la fin de l'animation OU 0.5 seconde max par sécurité
		await get_tree().create_timer(0.5).timeout
	
	queue_free() # SUPPRIME l'ennemi de la scène
