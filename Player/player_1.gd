# SquadMember
extends KinematicBody2D

# Atributes
export var speed = 100 # player speed
export var life = 100 # player life
export var stimpacks = 1

# State
var currentLife = life
var is_dead = false
var isMoving = false
var new_pos
var isHealing = false
var isUsingPowerup = false
var isAiming = false
var shootAngle = PI/2
var current_stimpacks = 0
# Resources
var weapon_1 = preload("res://Weapons/weapon_1.tscn")
onready var action_menu = get_node("ActionMenu")
#onready var sound = get_node("/root/menu_music/SamplePlayer")

func _ready():
	set_process(false)


func _process(delta):
	# Movement
	var dir = (new_pos-get_pos()).normalized()*speed
	move(dir) # add delta on tilemap navigation
	var rot = Vector2(0,0).angle_to_point(dir)-3.14159
	set_rot(rot)
	if new_pos.distance_squared_to(get_pos()) <10:
		get_node("ActionMenu").set_rot(-rot)
		shootAngle = -(rot - PI/2)
		set_process(false)
		get_node("Timer").start()
		

func _unhandled_input(event):
	# Motion
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed and isMoving:
		new_pos = get_global_mouse_pos()
		set_process(true)
		set_process_unhandled_input(false) 
		isMoving = false
	
	# Aiming
	if event.type == InputEvent.MOUSE_MOTION \
    and isAiming:
		var mousePos = get_global_mouse_pos() 
		shootAngle = get_pos().angle_to_point(mousePos)
		shootAngle = - (shootAngle - PI/2) + PI
		look_at(mousePos)
		get_node("ActionMenu").set_rot(shootAngle - PI/2)

	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed and isAiming:
		isAiming = false
		get_node("Timer").start()
		set_process_unhandled_input(false) 
	

func _input_event(viewport, event, shape_idx):
    if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed and not isMoving and not isAiming:
        action_menu.show()

func add_life(lifeValue):
	if is_dead:
		return
		
	currentLife += lifeValue
	if currentLife > life:
		currentLife = life
		
	if currentLife <= 0:
		get_node("Particles2D").set_emitting(true)
		set_process(false)

		#sound.play("Laser_05", true)
		get_node("Sprite").hide()
		is_dead = true

#################### Action MENU ##################33

func _on_move_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
		print("Move")
		isMoving = true
		action_menu.hide()
		set_process_unhandled_input(true) 
		get_node("Timer").stop()

func _on_aim_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
		print("Aim")
		action_menu.hide()
		set_process_unhandled_input(true) 
		isAiming = true
		get_node("Timer").stop()

func _on_heal_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
		print("Heal")
		action_menu.hide()
		if current_stimpacks < stimpacks:
			currentLife += int(life/3)
			currentLife = min(currentLife, life)
			current_stimpacks += 1
		if current_stimpacks == stimpacks:
			get_node("ActionMenu/Heal").hide()
		

func _on_powerup_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.MOUSE_BUTTON \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
		print("Powerup")
		action_menu.hide() 


func draw_circle_arc( center, radius, angle_from, angle_to, color ):
    var nb_points = 32
    var points_arc = Vector2Array()

    for i in range(nb_points+1):
        var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
        var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
        points_arc.push_back( point )

    for indexPoint in range(nb_points):
        draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color, 4)


func _on_shoot_timeout():
	get_node("Weapon").fire_weapon(shootAngle)

