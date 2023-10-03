extends Node2D


@export var next_level: PackedScene

# collision ploygon 은 tile 추가하면서 삭제함 -> tilemap이 자체적으로 충돌판정(물리 레이어) 가지고 있음
#@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
#@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted



# 1: 기본적인 필드 및 플레이어 생성
# 2: 코요테 점프 구현
# 3: 플레이어 이동 데이터 객체 분리
# 4: 더블 점프, 벽 점프 구현
# 5: 함정 - 레이어 충돌
# 6: 게임의 목표, 클리어 추가
# 7: Autotile
# 8: Level transitions and inherited scenes
# 9: Controller support

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
#	polygon_2d.polygon = collision_polygon_2d.polygon
	Events.level_completed.connect(show_level_completed)
	

func show_level_completed():
	level_completed.show()
	
#   다음 레벨 없으면 return
	if not next_level is PackedScene: return
	get_tree().paused = true
	await LevelTransition.fade_to_black()
#   다음레벨로 넘어감
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	await LevelTransition.fade_from_black()
	
#	get_tree().paused = true
	
