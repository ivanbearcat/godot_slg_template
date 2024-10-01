extends Node

func load_json_file(path: String):
	if FileAccess.file_exists(path):
		var file_data = FileAccess.open(path, FileAccess.READ).get_as_text()
		var dict = JSON.parse_string(file_data)
		if dict is Dictionary:
			return dict
		else:
			print("文件读取错误或文件格式不是json")
	else:
		print(path + "文件不存在")
