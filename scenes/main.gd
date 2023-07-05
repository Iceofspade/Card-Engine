extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$"Card controler".create_hand()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("draw_card"):
		$"Card controler".create_card($"Card controler".DECK)
		$"Card controler".reorganiseHand()
	if Input.is_action_just_pressed("shift_card"):
		if  $"Card controler".get_node("Deck").get_children().size() > 0 :
			var card = $"Card controler".get_node("Deck").get_children()[0]
			print(card.get_node("Label").text)
			$"Card controler".transfer_card_to($"Card controler".DECK,$"Card controler".HAND,card)
		pass
	pass
