extends CharacterBody2D
class_name Ennemy

const SPEED = 80.0
const JUMP_VELOCITY = -300.0 
const VOID_LIMIT = 1000.0 # Ajuste cette valeur selon la profondeur de ton niveau

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

	# 1. Gestion de la Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# 2. Sécurité : Mort si chute dans le vide
	if global_position.y > VOID_LIMIT:
		die_pnj()
		return

	# 3. Intelligence Artificielle (Suivi et Saut)
	if player:
		nav_agent.target_position = player.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_path_pos = nav_agent.get_next_path_position()
			var direction = (next_path_pos - global_position).normalized()
			
			# Saut intelligent : si le prochain point est plus haut que nous
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

func die_pnj():
	if is_dead: return
	is_dead = true
	
	# Prévenir le WaveManager immédiatement pour passer à la vague suivante
	if WaveManager:
		WaveManager.enemy_died()
	
	# Désactiver les collisions et arrêter le mouvement
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	velocity = Vector2.ZERO
	
	# Animation de mort et suppression
	if _animated_sprite.sprite_frames.has_animation("death"):
		_animated_sprite.play("death")
		await get_tree().create_timer(0.5).timeout
	
	queue_free()
