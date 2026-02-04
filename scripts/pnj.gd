extends CharacterBody2D
class_name Ennemy

const SPEED = 80.0
const JUMP_VELOCITY = -300.0 
const VOID_LIMIT = 1000.0

@onready var nav_agent = $NavigationAgent2D
@onready var _animated_sprite = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("Player")

var is_dead = false
var is_cold_world = false

func _ready():
	# Trouver le levier et se connecter à son signal
	await get_tree().process_frame
	var lever = find_lever(get_tree().root)
	
	if lever:
		if lever.has_signal("world_changed"):
			lever.world_changed.connect(set_world_state)
			print("✅ PNJ '", name, "' connecté au levier")
		else:
			print("❌ Le levier n'a pas de signal 'world_changed'")
	else:
		print("❌ PNJ '", name, "' : Levier introuvable !")

func find_lever(node: Node) -> Node:
	# Chercher un node de type Area2D qui a le signal world_changed
	if node is Area2D and node.has_signal("world_changed"):
		return node
	
	for child in node.get_children():
		var result = find_lever(child)
		if result:
			return result
	
	return null

# ... reste du code identique ...

func _on_killzone_body_entered(body: Node2D) -> void:
	if is_dead: return
	if body is Player:
		body.die()

func _physics_process(delta):
	if is_dead: return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if global_position.y > VOID_LIMIT:
		die_pnj()
		return
	
	if player:
		nav_agent.target_position = player.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_path_pos = nav_agent.get_next_path_position()
			var direction = (next_path_pos - global_position).normalized()
			
			if next_path_pos.y < global_position.y - 20 and is_on_floor():
				velocity.y = JUMP_VELOCITY
			
			velocity.x = direction.x * SPEED
			_animated_sprite.flip_h = velocity.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	update_animations()

func update_animations():
	var suffix = "-cold" if is_cold_world else ""
	
	if not is_on_floor():
		play_animation_with_fallback("jump", suffix)
	elif velocity.x != 0:
		play_animation_with_fallback("walk", suffix)
	else:
		play_animation_with_fallback("idle", suffix)

func play_animation_with_fallback(base_name: String, suffix: String):
	var anim_name = base_name + suffix
	
	if _animated_sprite.sprite_frames.has_animation(anim_name):
		_animated_sprite.play(anim_name)
	else:
		_animated_sprite.play(base_name)

func set_world_state(is_cold: bool):
	is_cold_world = is_cold
	print("🎭 PNJ '", name, "' passe en mode ", "FROID ❄️" if is_cold else "CHAUD 🔥")
	update_animations()

func die_pnj():
	if is_dead: return
	is_dead = true
	
	if WaveManager:
		WaveManager.enemy_died()
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	velocity = Vector2.ZERO
	
	var death_anim = "death-cold" if is_cold_world else "death"
	
	if _animated_sprite.sprite_frames.has_animation(death_anim):
		_animated_sprite.play(death_anim)
	elif _animated_sprite.sprite_frames.has_animation("death"):
		_animated_sprite.play("death")
	
	print(get_tree().get_nodes_in_group("HUD"))
	get_tree().call_group("HUD", "add_kill")
	await get_tree().create_timer(1).timeout
	queue_free()
