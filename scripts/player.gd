extends CharacterBody2D

const TILE_SIZE: Vector2 = Vector2(16,16)

var _sprite_node_pos_tween:Tween
var _target_position: Vector2
var _move_queue: Array = []

@export var is_moving :=false
@export var line: Line2D

func _ready():
	_target_position = global_position
	print("ok")
	
func _physics_process(delta:float)->void:
	path_visual()
	
func _unhandled_input(event): #se hace click con el raton
	if Input.is_action_just_pressed("LMB"):
		if not is_moving:
			var click_pos = get_global_mouse_position()
			_target_position = snap_to_grid(click_pos)
			calculate_path(_target_position)
			move_to_target()

func calculate_path(_target_position):
	var current_pos = snap_to_grid(global_position)
	var distance = snap_to_grid(_target_position)-current_pos
	var points: PackedVector2Array = PackedVector2Array()
	var line_pos: Vector2 = current_pos
	var steps_x = int(distance.x/TILE_SIZE.x)
	
	line.clear_points()
	_move_queue.clear()
	points.append(line_pos)

	for i in range(abs(steps_x)):
		line_pos += Vector2(sign(steps_x),0)*TILE_SIZE
		_move_queue.append(Vector2(sign(steps_x),0))
		points.append(line_pos)
		
	var steps_y = int(distance.y/TILE_SIZE.y)
	for i in range(abs(steps_y)):
		line_pos += Vector2(0,sign(steps_y))*TILE_SIZE
		_move_queue.append(Vector2(0,sign(steps_y)))
		points.append(line_pos)
		
	points.append(line_pos)
	
	for i in range(points.size()):
		line.add_point(points[i],i)

func move_to_target():
	var next_dir
	var raycast

	for i in range(0,_move_queue.size()):
		raycast = direccion_raycast(_move_queue[i])
		if (raycast.is_colliding()):
			_move_queue.clear()
			break
		line.remove_point(0)
		_move(_move_queue[i])
		await get_tree().create_timer(0.2).timeout
		
	is_moving = false;
	
func path_visual():
	var mouse_pos = snap_to_grid(get_global_mouse_position())
	if not is_moving:
		calculate_path(mouse_pos)
	
func _move(dir: Vector2):
	is_moving = true
	global_position += dir*TILE_SIZE
	$Icon.global_position -= dir*TILE_SIZE

	if _sprite_node_pos_tween: 
		_sprite_node_pos_tween.kill()
	_sprite_node_pos_tween=create_tween()
	_sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_sprite_node_pos_tween.tween_property($Icon, "global_position", global_position,0.185).set_trans(Tween.TRANS_SINE)

func snap_to_grid(pos: Vector2) -> Vector2: #casilla mas cercana al ratón
	var tile_coord = Vector2(
		floor(pos.x / TILE_SIZE.x),
		floor(pos.y / TILE_SIZE.y)
	)
	return tile_coord * TILE_SIZE + TILE_SIZE/2

func direccion_raycast(dir: Vector2)->RayCast2D:
	if dir.y <0: return $up
	if dir.y>0: return $down
	if dir.x<0: return $left
	return $right
