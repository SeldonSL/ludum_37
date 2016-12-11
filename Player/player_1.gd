# Keyboard + mouse player
extends KinematicBody2D

# Actions
export var speed = 3 # player speed
export var life = 200 # player life
var isShooting = false
var shootAngle = 0
var last_angle = Vector2(0,0)
var mousePos = Vector2(0,0)
var currentLife = life
var is_dead = false
var weapon_1 = preload("res://Weapons/weapon_1.tscn")
#onready var sound = get_node("/root/menu_music/SamplePlayer")


# Keyboard Movement actions
var move_actions = { "K_MOVE_LEFT":Vector2(-1,0), "K_MOVE_RIGHT":Vector2(1,0), "K_MOVE_UP":Vector2(0,-1), "K_MOVE_DOWN":Vector2(0,1) }

var dir = Vector2(0,0)
var dir_slide = Vector2(0,0)

func _ready():
	set_process(true)
	set_process_input(true)
#	maze_tilemap = get_node("/root/TestLevel/Maze/Navigation2D/TileMap")
	
func _process(delta):	
	
	# Movement
	#make character slide nicely through the world	
	var slides_attemps = 5
	if(is_colliding() and slides_attemps > 0):
		dir = get_collision_normal().slide(dir)
		dir = move(dir.normalized()*speed*delta*0.5)
		slides_attemps -= 1
	else:
		dir = Vector2(0,0)
	
	for ac in move_actions:
		if Input.is_action_pressed(ac):
			dir += move_actions[ac]
			
	move(dir.normalized() * speed * delta)
	if dir == Vector2(0,0):
		var rot = Vector2(0,0).angle_to_point(last_angle)-3.14159
		set_rot(rot )
	else:
		last_angle = dir
		var rot = Vector2(0,0).angle_to_point(last_angle)-3.14159
		set_rot(rot )
	

	# Shooting
	if Input.is_action_pressed("M_SHOOT"):
		look_at(mousePos)
		last_angle = mousePos
		shootAngle = get_pos().angle_to_point(mousePos)

		shootAngle = - (shootAngle - 3.14159/2) + 3.141519
		isShooting = true	
		get_node("Weapon").fire_weapon(shootAngle)
		
	else:
		isShooting = false
	
func _input(ev):
		# Mouse rotation		
	if (ev.type==InputEvent.MOUSE_MOTION):
		mousePos =  get_global_mouse_pos()
	
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
		

func draw_circle_arc( center, radius, angle_from, angle_to, color ):
    var nb_points = 32
    var points_arc = Vector2Array()

    for i in range(nb_points+1):
        var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
        var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
        points_arc.push_back( point )

    for indexPoint in range(nb_points):
        draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color, 4)

	
