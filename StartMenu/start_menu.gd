extends CenterContainer

@onready var start_game_button = %StartGameButton
@onready var quit_button = %QuitButton



func _ready():
	start_game_button.grab_focus()
	pass


func _on_start_game_button_pressed():
	await LevelTransition.fade_to_black()
	# *** Scene 변경! 
	get_tree().change_scene_to_file("res://Level/level_01.tscn")
	LevelTransition.fade_from_black()
	

func _on_quit_button_pressed():
	get_tree().quit()



	
