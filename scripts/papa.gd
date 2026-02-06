extends CharacterBody2D

@onready var bulle_papa = $BullePapa
@onready var texte_papa = $BullePapa/textePapa

var dialogue_actif = false
var dialogue_termine = false
var player_ref = null

# Les dialogues alternés (qui parle, texte)
var dialogues = [
	{"speaker": "fils", "text": "Papa ! L'eau arrive ! Elle va nous emporter !"},
	{"speaker": "papa", "text": "Je sais, mon fils. C'est fini maintenant."},
	{"speaker": "fils", "text": "Non ! On peut encore..."},
	{"speaker": "papa", "text": "Tu t'es bien battu. On a survécu le plus longtemps possible."},
	{"speaker": "fils", "text": "Papa... J'ai peur..."},
	{"speaker": "papa", "text": "Moi aussi... Mais on est ensemble jusqu'à la fin."}
]

var index_dialogue = 0

func _ready():
	# Connecter le signal de la zone
	$ZoneDialogue.body_entered.connect(_on_zone_dialogue_body_entered)

func _on_zone_dialogue_body_entered(body):
	if body.name == "Player" and not dialogue_termine and not dialogue_actif:
		player_ref = body
		dialogue_actif = true
		# Attendre 2 secondes avant de commencer le dialogue
		await get_tree().create_timer(2.0).timeout
		afficher_dialogue()

func calculer_duree_lecture(texte: String) -> float:
	# Calcul professionnel: ~15 caractères par seconde de lecture
	# Minimum 4 secondes, maximum 8 secondes
	var duree = max(4.0, float(texte.length()) / 15.0)
	return min(duree, 8.0)

func afficher_dialogue():
	if index_dialogue < dialogues.size():
		var dialogue = dialogues[index_dialogue]
		
		# Cacher les deux bulles
		bulle_papa.visible = false
		if player_ref and player_ref.has_node("BulleFils"):
			player_ref.get_node("BulleFils").visible = false
		
		# Afficher la bonne bulle selon qui parle
		if dialogue["speaker"] == "papa":
			bulle_papa.visible = true
			texte_papa.text = dialogue["text"]
		elif dialogue["speaker"] == "fils" and player_ref and player_ref.has_node("BulleFils"):
			var bulle_fils = player_ref.get_node("BulleFils")
			bulle_fils.visible = true
			bulle_fils.get_node("texteFils").text = dialogue["text"]
		
		# Calculer la durée selon la longueur du texte
		var duree = calculer_duree_lecture(dialogue["text"])
		await get_tree().create_timer(duree).timeout
		index_dialogue += 1
		afficher_dialogue()
	else:
		# Dialogue terminé - cacher les bulles
		dialogue_termine = true
		bulle_papa.visible = false
		if player_ref and player_ref.has_node("BulleFils"):
			player_ref.get_node("BulleFils").visible = false
		
		# Attendre 1 seconde puis lancer le rideau de fin
		await get_tree().create_timer(1.0).timeout
		lancer_fin()

func lancer_fin():
	# Récupérer le rideau de fin depuis la scène
	var rideau_fin = get_tree().current_scene.get_node_or_null("RideauFin")
	
	if rideau_fin:
		var noir = rideau_fin.get_node_or_null("Noir")
		var texte_fin = rideau_fin.get_node_or_null("texte fin")
		
		# Afficher le rideau
		rideau_fin.visible = true
		
		# Fondu noir progressif (3 secondes)
		if noir:
			var temps_fondu = 3.0
			var etapes = 60
			var increment = 1.0 / etapes
			
			for i in range(etapes):
				noir.modulate.a = i * increment
				await get_tree().create_timer(temps_fondu / etapes).timeout
		
		# Attendre 1 seconde
		await get_tree().create_timer(1.0).timeout
		
		# Afficher le texte final au centre
		if texte_fin:
			texte_fin.visible = true
			print("✅ Texte final affiché")
		else:
			print("❌ Texte final introuvable!")
		
		# Attendre 5 secondes puis retour au menu
		await get_tree().create_timer(5.0).timeout
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
