extends Object
class_name MMGenLoader

func load_gen(filename: String) -> MMGenBase:
	var file = File.new()
	if file.open(filename, File.READ) == OK:
		var data = parse_json(file.get_as_text())
		return create_gen(data)
	return null

func create_gen(data) -> MMGenBase:
	var generator = null
	if data.has("connections") and data.has("nodes"):
		generator = MMGenGraph.new()
		for n in data.nodes:
			var g = create_gen(n)
			if g != null:
				generator.add_child(g)
	elif data.has("type"):
		if data.type == "material":
			generator = MMGenMaterial.new()
		else:
			generator = MMGenShader.new()
			var file = File.new()
			if file.open("res://addons/material_maker/nodes/"+data.type+".mmn", File.READ) == OK:
				var config = parse_json(file.get_as_text())
				print("loaded description "+data.type+".mmn")
				generator.configure(config)
			else:
				print("Cannot find description for "+data.type)
	if generator != null and data.has("parameters"):
		generator.initialize(data)
	return generator