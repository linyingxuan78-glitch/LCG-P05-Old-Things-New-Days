extends SceneTree

# Read-only check of the actual Godot 4.4.1 export config parser.
func _initialize() -> void:
    var path := "res://export_presets.cfg"
    var file := ConfigFile.new()
    var result := file.load(path)
    print("EXPORT_PRESET_DIAG: load_code=", result)
    print("EXPORT_PRESET_DIAG: exists=", FileAccess.file_exists(path))
    if result == OK:
        print("EXPORT_PRESET_DIAG: sections=", file.get_sections())
        if file.has_section("preset.0"):
            print("EXPORT_PRESET_DIAG: name=", file.get_value("preset.0", "name", "UNDEFINED"))
            print("EXPORT_PRESET_DIAG: platform=", file.get_value("preset.0", "platform", "UNDEFINED"))
            print("EXPORT_PRESET_DIAG: resource_count=", file.get_section_keys("preset.0").size())
    quit(0 if result == OK and file.get_value("preset.0", "name", "") == "Windows Desktop" else 1)
