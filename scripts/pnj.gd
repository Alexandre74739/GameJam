extends CharacterBody2D
class_name Ennemy

# Constantes de mouvement
const SPEED = 80.0
const JUMP_VELOCITY = -300.0 
const VOID_LIMIT = 1000.0

# Références aux nodes
@onready var nav_agent = $NavigationAgent2D
@onready var _animated_sprite = $AnimatedSprite2D
@onready var sfx_dead = $SfxDead
@onready var player = get_tree().get_first_node_in_group("Player")

# Variables d'état
var is_dead = false
var is_cold_world = false

func _ready():
	# Attendre que tous les nodes soient prêts
	await get_tree().process_frame
	
	# Trouver et se connecter au levier
	var lever = find_lever(get_tree().root)
	
	if lever:
		# Se connecter au signal de changement de monde
		if lever.has_signal("world_changed"):
			lever.world_changed.connect(_on_world_changed)
			
			# Récupérer l'état initial du monde
			if "is_cold_world_active" in lever:
				is_cold_world = lever.is_cold_world_active
				print("✅ PNJ '", name, "' spawn - Monde actuel : ", "FROID ❄️" if is_cold_world else "CHAUD 🔥")
			else:
				print("⚠️ PNJ '", name, "' - Impossible de récupérer l'état du monde")
		else:
			print("❌ Le levier n'a pas de signal 'world_changed'")
	else:
		print("❌ PNJ '", name, "' : Levier introuvable !")
	
	# Forcer l'animation de départ correcte
	call_deferred("_force_initial_animation")

func _force_initial_animation():
	# S'assurer que l'animation de départ correspond au monde actif
	update_animations()

func find_lever(node: Node) -> Node:
	# Chercher récursivement un Area2D avec le signal world_changed
	if node is Area2D and node.has_signal("world_changed"):
		return node
	
	for child in node.get_children():
		var result = find_lever(child)
		if result:
			return result
	
	return null

func _on_killzone_body_entered(body: Node2D) -> void:
	# Tuer le joueur s'il entre dans la zone de mort
	if is_dead:
		return
	
	if body is Player:
		body.die()

func _physics_process(delta):
	# Ne rien faire si mort
	if is_dead:
		return
	
	# Appliquer la gravité
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Sécurité : Se suicider si chute dans le vide
	if global_position.y > VOID_LIMIT:
		die_pnj()
		return
	
	# Intelligence artificielle : suivre le joueur
	if player:
		nav_agent.target_position = player.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_path_pos = nav_agent.get_next_path_position()
			var direction = (next_path_pos - global_position).normalized()
			
			# Sauter si le prochain point est plus haut
			if next_path_pos.y < global_position.y - 20 and is_on_floor():
				velocity.y = JUMP_VELOCITY
			
			# Se déplacer horizontalement
			velocity.x = direction.x * SPEED
			_animated_sprite.flip_h = velocity.x < 0
		else:
			# Ralentir si arrivé à destination
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Appliquer le mouvement
	move_and_slide()
	
	# Mettre à jour les animations
	update_animations()

func update_animations():
	# Déterminer le suffixe selon le monde actif
	var suffix = "-cold" if is_cold_world else ""
	
	# Choisir l'animation selon l'état du PNJ
	if not is_on_floor():
		_play_animation("jump", suffix)
	elif abs(velocity.x) > 10:  # En mouvement
		_play_animation("walk", suffix)
	else:  # Immobile
		_play_animation("idle", suffix)

func _play_animation(base_name: String, suffix: String):
	# Construire le nom de l'animation avec suffixe
	var anim_with_suffix = base_name + suffix
	
	# Essayer d'abord l'animation avec suffixe
	if _animated_sprite.sprite_frames.has_animation(anim_with_suffix):
		if _animated_sprite.animation != anim_with_suffix:
			_animated_sprite.play(anim_with_suffix)
	# Sinon utiliser l'animation de base
	elif _animated_sprite.sprite_frames.has_animation(base_name):
		if _animated_sprite.animation != base_name:
			_animated_sprite.play(base_name)
	else:
		push_warning("Animation manquante : ", anim_with_suffix, " et ", base_name)

func _on_world_changed(is_cold: bool):
	# Callback quand le levier change de monde
	is_cold_world = is_cold
	print("🎭 PNJ '", name, "' changement de monde : ", "FROID ❄️" if is_cold else "CHAUD 🔥")
	
	# Forcer le changement d'animation immédiatement
	update_animations()

func die_pnj():
	# Empêcher les morts multiples
	if is_dead:
		return
	
	is_dead = true
	
	if sfx_dead:
		sfx_dead.play()
	
	# Notifier le WaveManager
	if WaveManager:
		WaveManager.enemy_died()
	
	# Désactiver les collisions
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# Arrêter le mouvement
	velocity = Vector2.ZERO
	
	# Jouer l'animation de mort selon le monde
	var death_anim = "death-cold" if is_cold_world else "death"
	
	if _animated_sprite.sprite_frames.has_animation(death_anim):
		_animated_sprite.play(death_anim)
		print("💀 PNJ '", name, "' meurt avec : ", death_anim)
	elif _animated_sprite.sprite_frames.has_animation("death"):
		_animated_sprite.play("death")
		print("💀 PNJ '", name, "' meurt avec : death (fallback)")
	else:
		print("❌ Aucune animation de mort disponible pour ", name)
	
	# Incrémenter le compteur de kills
	get_tree().call_group("HUD", "add_kill")
	
	# Attendre la fin de l'animation puis se supprimer
	await get_tree().create_timer(1.0).timeout
	queue_free()
