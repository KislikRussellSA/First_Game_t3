extends Node2D

var stopped = 0
var time_elapsed = 0
var damage = false
var inventory = false
var com = true
var mouse_in_inv = false
var mouse_in_up = false
var mouse_in_down = false
var mouse_in_atk = false
var mouse_in_def = false
var mouse_in_health = false
var Difficulty = 1
var attack = 1
var defense = 0
var health = 1
var stats = true
var in_stats = false
var drop_gold = .05
var drop_silver = .05
var drop_copper = .85
var dropped = 1
var rng = RandomNumberGenerator.new()
var vx = 0
var vy = 0
var dir = 0
var vel = Vector2()
var c : Node
var val_g = 10000
var val_s = 100
var val_c = 1
var can_a = true
var mon = 0
var mon_a = "Attack_dog"
var mon_d = "Death_dog"
var factor = 1
@export var game: String:
	set = set_type
@export var coin: PackedScene = preload("res://coin.tscn")
@export var coins : Dictionary = {"Copper": 0, "Silver": 0, "Gold": 0}
# Called when the node enters the scene tree for the first time.

func set_type(_type):
	game = _type
	
	
func _ready() -> void:
	rng.randomize()
	$MainHealth.max_value = 25
	$EnemyHealth.max_value = 10
	$MainHealth.value = 25
	$EnemyHealth.value = 10
	$Label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	factor = floor((attack + defense + health)/100)
	if factor == 0:
		factor = 1
	if $TextureButton/atk/a_cost.text != "Cost: " + str(((attack+1)**2)*factor):
		$TextureButton/atk/a_cost.text = "Cost: " + str(((attack+1)**2)*factor)
	if $TextureButton/def/d_cost.text != "Cost: " + str(((defense+1)**2)*factor):
		$TextureButton/def/d_cost.text = "Cost: " + str(((defense+1)**2)*factor)
	if $TextureButton/health/h_cost.text != "Cost: " + str(((health+1)**2)*factor):
		$TextureButton/health/h_cost.text = "Cost: " + str(((health+1)**2)*factor)
	if Difficulty != 0:
		mon_a = determine_attack()
		mon_d = determine_death()
	if coins["Copper"] < 0:
		coins["Silver"] -= 1
		coins["Copper"] += 100
	if coins["Silver"] < 0:
		coins["Gold"] -= 1
		coins["Silver"] += 100
	can_a = true
	var total = coins["Copper"]*val_c + coins["Silver"]*val_s + coins["Gold"]*val_g
	check_up(total)
	$gold/g_amnt.text = str(coins["Gold"])
	$silver/s_amnt.text = str(coins["Silver"])
	$copper/c_amnt.text = str(coins["Copper"])
	if Difficulty <= 60:
		drop_gold = .006*Difficulty
		drop_silver = .04+.01*(Difficulty-1)
		drop_copper = 1-drop_gold-drop_silver
	else:
		drop_silver = .64 - .006*(Difficulty-6)
		drop_gold = .006*Difficulty
	if stopped == 0:
		if Difficulty != 0:
			$Sprite2D.visible = true
		else:
			$Sprite2D.visible = false
		if Difficulty > 1:
			$Sprite2D2.visible = true
		else:
			$Sprite2D2.visible = false
		if Input.is_action_just_pressed("click") and mouse_in_inv:
			if inventory:
				inventory = false
				com = true
			else:
				inventory = true
		if Input.is_action_just_pressed("click") and mouse_in_up and $Sprite2D.visible == true:
			if game == "s":
				if Difficulty == 100:
					$Sprite2D.visible = false
					$Sprite2D2.visible = false
					Difficulty = 0
					$Label2.text = "Difficulty: Boss"
					mon_a = "Attack_boss"
					mon_d = "Death_boss"
					$EnemyHealth.max_value = 10000*floor(factor/10)
					$EnemyHealth.value = 10000*floor(factor/10)
				$Enemy.scale.x = 3 + .1*(Difficulty%10)
				$Enemy.scale.y = 3 + .1*(Difficulty%10)
				mon = floor(Difficulty/10)
			else:
				mon = rng.randi_range(0, 9)
			if Difficulty != 0:
				Difficulty += 1
				$Label2.text = "Difficulty: " + str(Difficulty)
				$EnemyHealth.max_value = 10*Difficulty
				$EnemyHealth.value = 10*Difficulty
		if Input.is_action_just_pressed("click") and mouse_in_down  and $Sprite2D2.visible == true:
			if Difficulty > 1:
				Difficulty -= 1
				$Label2.text = "Difficulty: " + str(Difficulty)
				$EnemyHealth.value = 10*Difficulty - ($EnemyHealth.max_value - $EnemyHealth.value)
				$EnemyHealth.max_value = 10*Difficulty
		if Input.is_action_just_pressed("click") and mouse_in_atk and $TextureButton/atk.visible == true:
			coins["Copper"] -= ((attack+1)**2)*factor
			attack += 1
			$TextureButton/atk.text = "Atk: " + str(attack)
			$TextureButton/atk/a_cost.text = "Cost: " + str(((attack+1)**2)*factor)
		if Input.is_action_just_pressed("click") and mouse_in_def and $TextureButton/def.visible == true:
			coins["Copper"] -= ((defense+1)**2)*factor
			defense += 1
			$TextureButton/def.text = "Def: " + str(defense)
			$TextureButton/def/d_cost.text = "Cost: " + str(((defense+1)**2)*factor)
		if Input.is_action_just_pressed("click") and mouse_in_health and $TextureButton/health.visible == true:
			coins["Copper"] -= ((health+1)**2)*factor
			
			health += 1
			$MainHealth.max_value = 25 * health
			$MainHealth.value = 25 * health
			$TextureButton/health.text = "Health: " + str(health * 25)
			$TextureButton/health/h_cost.text = "Cost: " + str(((health+1)**2)*factor)
	if com:
		$Node2D2.visible = true
		$gold.visible = false
		$silver.visible = false
		$copper.visible = false
		$TextureButton.visible = true
		$Enemy.visible = true
		$Node2D.visible = false
		$Label2.visible = true
		Input.set_custom_mouse_cursor(load("res://kenney_ui-pack-rpg-expansion/PNG/cursorSword_silver.png"))
		combat(delta, Difficulty)
	if inventory:
		$Node2D2.visible = false
		$gold.visible = true
		$silver.visible = true
		$copper.visible = true
		Input.set_custom_mouse_cursor(load("res://kenney_ui-pack-rpg-expansion/PNG/cursorHand_grey.png"))
		$Enemy.visible = false
		$TextureButton.visible = false
		$Label2.visible = false
		$Sprite2D.visible = false
		$Sprite2D2.visible = false
		$Node2D.visible = true
		com = false
		
func check_up(total: int):
	if total >= ((attack+1)**2)*factor:
		$TextureButton/atk/Sprite2D3.visible = true
	else:
		$TextureButton/atk/Sprite2D3.visible = false
	if total >= ((health+1)**2)*factor:
		$TextureButton/health/Sprite2D3.visible = true
	else:
		$TextureButton/health/Sprite2D3.visible = false
	if total >= ((defense+1)**2)*factor:
		$TextureButton/def/Sprite2D3.visible = true
	else:
		$TextureButton/def/Sprite2D3.visible = false
	

func determine_attack():
	$Enemy.flip_h = true
	if mon == 3:
		return "Attack_dog"
	if mon == 4:
		return "Attack_mush"
	if mon == 2:
		return "Attack_eye"
	if mon == 6:
		return "Attack_skeleton"
	if mon == 5:
		return "Attack_goblin"
	if mon == 1:
		return "Attack_rat"
	if mon == 7:
		$Enemy.flip_h = false
		return "Attack_slime"
	if mon == 8:
		return "Attack_golem"
	if mon == 9:
		return "Attack_agolem"
	if mon == 0:
		return "Attack_bat"

func determine_death():
	if mon == 3:
		return "Death_dog"
	if mon == 4:
		return "Death_mush"
	if mon == 2:
		return "Death_eye"
	if mon == 6:
		return "Death_skeleton"
	if mon == 5:
		return "Death_goblin"
	if mon == 1:
		return "Death_rat"
	if mon == 7:
		return "Death_slime"
	if mon == 8:
		return "Death_golem"
	if mon == 9:
		return "Death_agolem"
	if mon == 0:
		return "Death_bat"

func combat(delta: float, Difficulty) -> void:
	time_elapsed += delta
	if time_elapsed>1 and stopped == 0:
		if Difficulty*factor-defense > 0 and Difficulty != 0:
			$MainHealth.value -= (Difficulty*factor-defense)
		if Difficulty == 0:
			if 10000*factor-defense > 0:
				$MainHealth.value -= (10000*floor(factor/10)-defense)
		time_elapsed = 0
	if $EnemyHealth.value > 0 and stopped == 0:
		$Enemy.play(mon_a)
	if $EnemyHealth.max_value != $EnemyHealth.value:
		if Input.is_action_just_pressed("click") and stopped == 0:
			$MainChar.play("Attack")
			damage = true
	else:
		if Input.is_action_just_pressed("click") and stopped == 0 and area_detect() and can_a:
			$MainChar.play("Attack")
			damage = true
	if $MainHealth.value <= 0:
		if stopped == 0:
			$Enemy.stop()
			stopped += 1
			$MainChar.play("Death")
			$Enemy.stop()
		await $MainChar.animation_looped
		$MainChar.frame = 27
		$Label.visible = true
		$MainChar.play("Death")
		$Label.visible = true
	if $EnemyHealth.value <= 0 and Difficulty != 0:
		if stopped == 0:
			c = coin.instantiate()
			c._picked_up.connect(add_coin)
			$Enemy.stop()
			stopped += 1
			$Enemy.play(mon_d)
			$Node2D2.add_child(c)
			c.type = rng.rand_weighted([drop_copper, drop_silver, drop_gold])
			c.position.x = 798
			c.position.y = 360
			$MainHealth.value += 15 * health
			vx = rng.randf_range(100, 350)
			vy = rng.randf_range(100, 350)
			dir = rng.randi_range(0, 1)
		if vx>0:
			if dir == 1:
				c.global_position.x += vx*delta
			if dir == 0:
				c.global_position.x -= vx*delta
			c.global_position.y -= vy*delta
			vx -= .3
			vy -= 5
		await $Enemy.animation_looped
		if game == "s":
			$Enemy.scale.x = 3 + .1*(Difficulty%10)
			$Enemy.scale.y = 3 + .1*(Difficulty%10)
			mon = floor(Difficulty/10)
		else:
			mon = rng.randi_range(0, 9)
		$Enemy.play(mon_d)
		$EnemyHealth.value = 10*Difficulty
		$Enemy.speed_scale = 1
		stopped = 0
	if $EnemyHealth.value <= 0 and Difficulty == 0:
		$Enemy.play(mon_d)
		$Label.text = "YOU WIN!"
		$Label.visible = true
		stopped = 1
	await $MainChar.animation_looped
	if damage:
		$EnemyHealth.value -= attack
	damage = false
	$MainChar.stop()

func area_detect():
	if mouse_in_atk:
		return false
	if mouse_in_inv:
		return false
	if mouse_in_up:
		return false
	if mouse_in_down:
		return false
	if mouse_in_health:
		return false
	if mouse_in_def:
		return false
	if in_stats:
		return false
	return true
	
func add_coin():
	can_a = false
	if c.type == 0:
		coins["Copper"] += 1
	if c.type == 1:
		coins["Silver"] += 1
	if c.type == 2:
		coins["Gold"] += 1

func _on_bag_area_mouse_entered() -> void:
	mouse_in_inv = true


func _on_bag_area_mouse_exited() -> void:
	mouse_in_inv = false # Replace with function body.


func _on_up_area_mouse_entered() -> void:
	mouse_in_up = true


func _on_up_area_mouse_exited() -> void:
	mouse_in_up = false


func _on_down_area_mouse_entered() -> void:
	mouse_in_down = true


func _on_down_area_mouse_exited() -> void:
	mouse_in_down = false


func _on_texture_button_pressed() -> void:
	if stats:
		$TextureButton.flip_h = true
		stats = false
		$TextureButton/atk.visible = false
		$TextureButton/def.visible = false
		$TextureButton/health.visible = false
	else:
		$TextureButton.flip_h = false
		stats = true
		$TextureButton/atk.visible = true
		$TextureButton/def.visible = true
		$TextureButton/health.visible = true


func _on_atk_area_mouse_entered() -> void:
	mouse_in_atk = true


func _on_atk_area_mouse_exited() -> void:
	mouse_in_atk = false


func _on_def_area_mouse_entered() -> void:
	mouse_in_def = true
	

func _on_def_area_mouse_exited() -> void:
	mouse_in_def = false

func _on_health_area_mouse_entered() -> void:
	mouse_in_health = true


func _on_health_area_mouse_exited() -> void:
	mouse_in_health = false


func _on_texture_button_mouse_entered() -> void:
	in_stats = true


func _on_texture_button_mouse_exited() -> void:
	in_stats = false
