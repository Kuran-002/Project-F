class_name Queue
extends RefCounted
# A class implementing the Queue (FIFO) data structure
# Allows for O(1) enqueueing and dequeueing of data

var _head: QueueNode
var _tail: QueueNode
var _length: int


func _init(max_length: int = INF) -> void:
	_head = null
	_tail = null
	_length = 0


func enqueue(data) -> void:
	var new_node = QueueNode.new(data)
	if _head == null:
		_head = new_node
		_tail = new_node
	else:
		_tail.next = new_node
		_tail = new_node
	_length += 1


func dequeue():
	assert(_length > 0, "Unable to dequeue data - Queue is empty")
	var data = _head.data
	_head = _head.next
	_length -= 1
	if _length == 0:
		_tail = null
	return data


func peek():
	return _head.data


func is_empty() -> bool:
	return _length == 0


class QueueNode:
	var data
	var next

	func _init(new_data) -> void:
		data = new_data
		next = null
