extends Area2D

const AMMO_AMOUNT = 1	# Shells given per box

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		area.gun.add_reserve_ammo(AMMO_AMOUNT)
		area.play_ammo_pickup_sound()
		queue_free()
