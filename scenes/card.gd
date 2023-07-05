extends Control

class_name CardTemplate

signal has_been_selected

@onready var line2d := $Arrow 
var originalPos = Vector2(0,0)
var originalRot = Vector2(0,0)
var is_disabled = false

func _ready():
	line2d.position = size/2
	
	pass # Replace with function body.

func _process(_delta):
	pass

func disable_card(state:bool):
	is_disabled = state
	$TextureButton.disabled = state

func _on_arrow_contact(target):
	print("Arrow is touching: "+str(target))
	pass # Replace with function body.

func _on_arrow_released():
	print("Arrow was Released")
	pass # Replace with function body.
	
func _on_arrow_hovering():
	print("Arrow is hovering")
	pass # Replace with function body.

func _on_arrow_stop_hovering():
	print("Arrow has stop hovering")
	pass # Replace with function body.

func _on_texture_button_mouse_entered():
	print("Mouse Entered")
	if !is_disabled:
		z_index+=1
		var tweener := create_tween().set_parallel(true)
		tweener.tween_property(self,"position",position+Vector2(0,-150),0.25)
		tweener.tween_property(self,"scale",Vector2(1.5,1.5),0.25,)
		tweener.tween_property(self,"rotation",0,0.25)
		tweener.play()
	pass # Replace with function body.

func _on_texture_button_mouse_exited():
	print("Mouse Exited")
	if !is_disabled:
		z_index-=1
		var tweener := create_tween().set_parallel(true)
		tweener.tween_property(self,"position",originalPos,0.25)
		tweener.tween_property(self,"scale",Vector2(1,1),0.25)
		tweener.tween_property(self,"rotation",originalRot,0.25,)
		tweener.play()
	pass # Replace with function body.

func _on_texture_button_button_up():
	print("Clicked Up")
	if !$TextureButton.disabled or !is_disabled:
		$Arrow.set_is_arrow_disabled(true)
		$Arrow.emit_signal("arrow_released")
	pass # Replace with function body.

func _on_texture_button_button_down():
	print("Clicked Down")
	if !$TextureButton.disabled or !is_disabled:
		$Arrow.set_is_arrow_disabled(false)
		$Arrow.emit_signal("arrow_hovering")
	pass # Replace with function body.
