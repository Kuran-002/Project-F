extends Node

@export var r:RhythmNotifier 

var action_queue:Queue 
var timing_queue:Queue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_queue = Queue.new() 
	timing_queue = Queue.new() 

# Export all of the actions as an array 
func export_actions() -> void: 
	print("\nActions\n")
	while(!action_queue.is_empty()): 
		print("%.2f," % action_queue.dequeue())

# Export all of the timings as an array 
func export_timings() -> void: 
	print("\nTimings\n")
	while(!timing_queue.is_empty()): 
		print("%.2f," % timing_queue.dequeue())

var last_position:float = 0.0
var is_recording:bool = false 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# start music 
	if (Input.is_action_just_pressed("start_record")): 
		if (!is_recording): 
			is_recording = true 
			r.audio_stream_player.seek(last_position)
			r.audio_stream_player.play()
		else: 
			is_recording = false 
			last_position = r.current_position
			r.audio_stream_player.stop() 

	# on keypress, record action and timing 
	if (Input.is_action_just_pressed("attack1")): 
		action_queue.enqueue(1)
		timing_queue.enqueue(r.current_position)
	if (Input.is_action_just_pressed("attack2")): 
		action_queue.enqueue(2)
		timing_queue.enqueue(r.current_position)
	if (Input.is_action_just_pressed("attack3")): 
		action_queue.enqueue(3)
		timing_queue.enqueue(r.current_position)

	# export all 
	if (Input.is_action_just_pressed("export")): 
		export_actions()
		export_timings()

	
