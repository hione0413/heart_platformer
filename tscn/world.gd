extends Node2D


@export var next_level: PackedScene

var level_time = 0.0
var start_level_msec = 0.0

# collision ploygon 은 tile 추가하면서 삭제함 -> tilemap이 자체적으로 충돌판정(물리 레이어) 가지고 있음
#@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
#@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted

@onready var start_in = %StartIn
@onready var start_in_label = %StartInLabel
@onready var animation_player = $AnimationPlayer
@onready var level_timer_label = %LevelTimerLabel


# My Plan
# 1: 기본적인 필드 및 플레이어 생성
# 2: 코요테 점프 구현
# 3: 플레이어 이동 데이터 객체 분리
# 4: 더블 점프, 벽 점프 구현
# 5: 함정 - 레이어 충돌
# 6: 게임의 목표, 클리어 추가
# 7: Autotile
# 8: Level transitions and inherited scenes
# 9: Controller support
#10: Start menu
#11: UI Theme
#12: Wall jump fix
#13: game start countdown 23/10/15 finish
#14: Level Timer 23/10/16 finish
#15: Victory screen


func _ready():
	# 다음 스테이지 없음 - 마지막 스테이지
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "Victory Screen"
		next_level = load("res://VictoryScreen/victory_screen.tscn")
	
#	RenderingServer.set_default_clear_color(Color.BLACK)
#	polygon_2d.polygon = collision_polygon_2d.polygon
	Events.level_completed.connect(show_level_completed)
	
	start_in.visible = true
	
	get_tree().paused = true # 타이머 실행 전에는 일단 멈춰 둠
	await LevelTransition.fade_from_black()
	animation_player.play("countdown")
	await animation_player.animation_finished
	get_tree().paused = false
	
	start_in.visible = false
	
	# 게임 시작까지 걸린 시간
	start_level_msec = Time.get_ticks_msec()
	
	
func _process(delta):
	# 게임 시작 후 시간 계산
	level_time = Time.get_ticks_msec() - start_level_msec
	level_timer_label.text = str(level_time / 1000.0)


func retry():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
#	var current_level = load(scene_file_path)
	get_tree().change_scene_to_file(scene_file_path)


func go_to_next_level():
	print('go_to_next_level')
	#   다음 레벨 없으면 return
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
#   다음레벨로 넘어감
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	

func show_level_completed():
	level_completed.show()
#	level_completed.retry_button.grab_focus()
	level_completed.next_level_button.grab_focus()
	get_tree().paused = true # 레벨 클리어 후 멈춤
	
	
func _on_level_completed_retry():
	retry()

# level_completed 가 가진 next_level(button) 시그널에서 신호를 받으면 동작
func _on_level_completed_next_level():
	go_to_next_level()
