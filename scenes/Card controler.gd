extends Node2D

class_name Card_Controler
@onready var card_template = preload("res://scenes/card.tscn")
@onready var empty_holder = $Empty
@onready var hand_holder = $Hand
@onready var deck_holder = $Deck


@onready var centrelCardOval = get_viewport().size * (Vector2i(0,(get_viewport().size.y/400))) as Vector2
@onready var horRad = get_viewport().size.x
@onready var verRad = get_viewport().size.y

enum {HAND,DECK,EMPTY}

var angle = deg_to_rad(90)
var ovalAngleVector = Vector2(0,0)
@export var cardSpread = 0.1

var hand:Array
var deck:Array
var empty:Array

var count = 0
@export var hand_size_limit = 12
@export var draw_set_size = 5

func _ready():
	randomize()

func create_hand():
	for i in draw_set_size:
		create_card(HAND)
	reorganiseHand()


func create_card(spawn_area:int):
	var newCard:CardTemplate = card_template.instantiate()
	ovalAngleVector = Vector2(horRad * cos(angle), -verRad * sin(angle))
	count+=1
	match spawn_area:
		HAND:
			hand_holder.add_child(newCard)
			hand.append(newCard)
		DECK:
			deck_holder.add_child(newCard)
			deck.append(newCard)
		EMPTY:
			empty_holder.add_child(newCard)
			empty.append(newCard)
#	newCard.visible = false
	newCard.get_node("Label").text += "\n "+str(count)
	newCard.originalPos = (centrelCardOval + ovalAngleVector) - Vector2(0,0)
	newCard.originalRot = (90 - rad_to_deg(angle))/8
	
	newCard.position = newCard.originalPos
#	newCard.rotation = newCard.originalRot
	newCard.scale = Vector2(0.25,0.25)
	print("Created Card at: "+str(newCard.position))	
	return newCard
	
func reorganiseHand():
	var cardNum = 0
	
	if hand.size() >= 9:
		cardSpread = 0.07
	else:
		cardSpread = 0.1
	
	for card in hand:
		angle = PI/2 + cardSpread*(float(hand.size())/2 - cardNum)
		ovalAngleVector = Vector2(horRad * cos(angle), - verRad * sin(angle))
		
		card.originalPos = (centrelCardOval + ovalAngleVector) 
		card.originalRot = (90 - rad_to_deg(angle))/180
		
		await animate_card_tranision(card,card.originalPos,card.originalRot)
#		card.position = card.originalPos
#		card.rotation = card.originalRot
#		card.scale = Vector2(0.25,0.25)
		cardNum += 1

func reorganiseneighbors(card:CardTemplate,left:bool,spacer:int):
	if left:
#		card.tweener.interpolate_property(card,"position",card.position,card.originalPos-(spread*Vector2(65.0,0)),0.5,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
		card.position -= spacer*Vector2(65.0,0)
	else:
#		card.tweener.interpolate_property(card,"position",card.position,card.originalPos+(spread*Vector2(65.0,0)),0.5,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
		card.position += spacer*Vector2(65.0,0)
	card.tweener.start()

func disable_cards(state:bool):
	for card in get_children():
		card.body_button.disabled = state
	for card in empty_holder.get_children():
		card.body_button.disabled = state
 
func base_trasfer(taker_arr:Array,recicer_arr:Array,taker_node,recicer_node,card:CardTemplate):
	taker_node.remove_child(card)
	recicer_node.add_child(card)
	
	recicer_arr.append(card)
	taker_arr.erase(card)


# Transfer a card from one collection to another 
# Return true if transfer was successfull.
func transfer_card_to(from:int,to:int,card):
	match from:
		HAND:
			var active_card = hand.find(card,0)
			if to == DECK and active_card != -1:
				card.disable_card(true)
				base_trasfer(hand,deck,hand_holder,empty_holder,card)
#				
				reorganiseHand()
			elif to == EMPTY and active_card != -1:
				card.disable_card(true)
				base_trasfer(hand,deck,hand_holder,empty_holder,card)
				
				reorganiseHand()
			else:
				return false
		DECK:
			var active_card = deck.find(card,0)
			if deck.size() == 0:
				refill_deck()
			if to == HAND and active_card != -1:
				base_trasfer(deck,hand,deck_holder,hand_holder,card)
				card.disable_card(false)
				reorganiseHand()
			elif to == EMPTY and active_card != -1:
				base_trasfer(deck,empty,deck_holder,empty_holder,card)
			else:
				return false
		EMPTY:
			var active_card = empty.find(card,0)
			if to == DECK and active_card != -1:
				base_trasfer(empty,deck,empty_holder,deck_holder,card)
			elif to == HAND and active_card != -1:
				card.disable_card(false)
				base_trasfer(empty,hand,empty_holder,hand_holder,card)
	
				reorganiseHand()
			else:
				return false

	return true
 
func animate_card_tranision(card:CardTemplate,pos:Vector2,rot:int):
	var tweener := create_tween().set_parallel(true)
	var time_lasp = 0.05

	tweener.tween_property(card,"position",pos,time_lasp)
	tweener.tween_property(card,"scale",Vector2(1,1),time_lasp)
	tweener.tween_property(card,"rotation",rot,time_lasp,)
	tweener.play()
	await tweener.finished
	card.scale = Vector2(1,1)
#	card.visible = true

func shuffel_deck():
	var new_card_set = []
	for _card in range(deck.size()):
		new_card_set.append(deck.pop_at(randi()%deck.size()))
	deck = new_card_set
	
func refill_deck():
	var pile = empty_holder.duplicate()
	for card in pile:
		transfer_card_to(EMPTY,DECK,card)
	shuffel_deck()

func draw_set():
	for _i in range(draw_set_size):
		draw_card()
		
func draw_card():
	if deck.size() == 0:
		refill_deck()
	transfer_card_to(DECK,HAND,deck[0])

func discard_hand():
	var hand_set = hand.duplicate()
	for card in hand_set:
		transfer_card_to(HAND,EMPTY,card)
		await get_tree().create_timer(0.01).timeout
