extends Node2D


@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted



# 1강: 기본적인 필드 및 플레이어 생성
# 2강: 코요테 점프 구현
# 3강: 플레이어 이동 데이터 객체 분리
# 4강: 더블 점프, 벽 점프 구현
# 5강: 함정 - 레이어 충돌
# 6강: 게임의 목표, 클리어 추가

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon_2d.polygon = collision_polygon_2d.polygon
	Events.level_completed.connect(show_level_completed)
	

func show_level_completed():
	level_completed.show()
	get_tree().paused = true
	
