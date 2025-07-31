extends HSlider


func _ready() -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	var current_value: float = AudioServer.get_bus_volume_db(bus_index)
	value = db_to_linear(current_value) * max_value
	var on_slider_changed: Callable = func(value: float):
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / max_value))
	value_changed.connect(on_slider_changed)
