extends Node3D

## Gets the elements in a string format
func get_elements_string(ability: AbilityResource) -> String:
	var elements: Array[String] = []
	for key in ability.elements.type.keys():
		if ability.elements.type[key] == true:
			elements.append(key)
	var elements_string: String = "".join(elements)
	if "Fire" in elements_string and "Frost" in elements_string:
		elements_string = "Frostfire"
	return elements_string


func get_elements_buff(buff: BuffResource) -> String:
	var elements: Array[String] = []
	for key in buff.elements.type.keys():
		if buff.elements.type[key] == true:
			elements.append(key)
	var elements_string: String = "".join(elements)
	if "Fire" in elements_string and "Frost" in elements_string:
		elements_string = "Frostfire"
	return elements_string


func get_mouse_world_coords() -> Vector3:
	var view = get_viewport()
	var camera = view.get_camera_3d()
	var mouse_pos = view.get_mouse_position()
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.collision_mask = pow(2, 1-1)
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	var coords
	if not result.is_empty():
		coords = result.position
	else:
		coords = Vector3.ZERO
	return coords
