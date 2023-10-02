extends Area2D


func _on_body_entered(body):
	queue_free()
	var hearts = get_tree().get_nodes_in_group("Hearts")
	if hearts.size() == 1:
#		전역의 Events 에게 시그널을 보냄
		Events.level_completed.emit()
		print('level complete')
		
	
	
