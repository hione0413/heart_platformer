extends ColorRect

signal retry()
signal next_level()

@onready var retry_button = %RetryButton
@onready var next_level_button = %NextLevelButton



func _on_retry_button_pressed():
	retry.emit()

func _on_next_level_button_pressed():
	# warn! LevelCompleted 의 Process mode 를 Always 로 변경해줘야 작동함 이유는 모름
#	print('_on_next_level_button_pressed')
	next_level.emit()
