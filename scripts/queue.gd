extends Node
class_name Queue

var queue: Array = []
var queue_timers: Array[float] = []
var max_queue_size: int = 10
var queue_delay: float = .25


func _process(delta) -> void:
	for i in range(queue_timers.size()):
		if i > queue_timers.size()-1:
			break
		queue_timers[i] -= delta
		if queue_timers[i] <= 0:
			queue_timers.remove_at(i)
			queue.remove_at(i)
		
	if queue_timers.size() == 0:
		set_process(false)


func add_to_queue(item) -> void:
	if queue.size() < max_queue_size:
		queue.push_back(item)
		queue_timers.push_back(queue_delay)
	else:
		queue.pop_front()
		queue.push_back(item)
		queue_timers.pop_front()
		queue_timers.push_back(queue_delay)
	
	set_process(true)
#	await get_tree().create_timer(queue_delay).timeout
#	queue.pop_front()

func get_next():
	queue_timers.pop_back()
	if queue_timers.size() > 0:
		set_process(true)
	else: set_process(false)
	return queue.pop_back()
	

func get_size() -> int:
	return queue.size()
