extends Line2D
# warning-ignore:unused_signal
signal arrow_released()
# warning-ignore:unused_signal
signal arrow_contact(target)
# warning-ignore:unused_signal
signal arrow_hovering()
# warning-ignore:unused_signal
signal arrow_stop_hovering()


@onready var lineOwner = get_parent()
@onready var head := $head
@export var maxPoints = 20

var is_arrow_disabled = true  : set = set_is_arrow_disabled, get = get_is_arrow_disabled 
var selected =  null : set = set_selected, get = get_selected

func _ready():

	pass # Replace with function body.

func _process(_delta):
	if !is_arrow_disabled:
		draw_curve()

func draw_curve():
	var card_half_size = lineOwner.scale/2
	var centerpos = global_position + card_half_size * scale
	clear_points()

	var final_point = get_global_mouse_position() \
			- (position + card_half_size)

	var curve = Curve2D.new()
	
	# Draws the body
	curve.add_point(to_local(centerpos),
			Vector2(0,0),Vector2(0,0))
			
#	curve.add_point(to_local(centerpos),
#			Vector2(0,0),
#			centerpos.direction_to(get_viewport().size/2) * curve_distance)
	# Bends near the head.
	curve.add_point(to_local(position + card_half_size + final_point),
			Vector2(0,-800) , Vector2(0, 0))
			
	set_points(curve.get_baked_points())
 
	head.position = get_point_position(
			get_point_count( ) - maxPoints)
			
	for _del in range(1,maxPoints):
		remove_point(get_point_count( ) - 1)
			
	head.rotation = get_point_position(
		get_point_count( ) - 1).direction_to(
		to_local(position  + final_point)).angle()
	pass

func get_selected():
	return selected

func set_selected(select):
	selected = select
	pass

func get_is_arrow_disabled():
	return is_arrow_disabled
	
func set_is_arrow_disabled(state):
	is_arrow_disabled = state
	$head/Area2D.monitoring = !state
	visible = !state

func _on_area_2d_body_entered(_body):
	print("body entered")
	emit_signal("arrow_contact",_body)
	set_selected(_body)
	pass # Replace with function body.

func _on_area_2d_body_exited(_body):
	set_selected(null)
	print("body exited")
	pass # Replace with function body.
