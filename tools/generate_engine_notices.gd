extends SceneTree
## Developer-only: generate matching notices from the selected Godot export engine.
const NOTICES: Script = preload("res://scripts/engine_notices.gd")
const OUTPUT_PATH: String = "res://licenses/GODOT_BINARY_DEPENDENCIES.txt"
func _initialize() -> void:
    var text_value: String = NOTICES.render()
    if text_value.length() < 800 or not text_value.contains("GODOT CORE MIT LICENCE") or not text_value.contains("ENGINE-REPORTED THIRD-PARTY"):
        push_error("ENGINE COPYRIGHT SNAPSHOT FAILED: insufficient data from binary")
        quit(1)
        return
    var out: FileAccess = FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
    if out == null:
        push_error("ENGINE COPYRIGHT SNAPSHOT FAILED: cannot write legal file")
        quit(1)
        return
    out.store_string(text_value)
    out.flush()
    out.close()
    print("ENGINE COPYRIGHT SNAPSHOT PASS: ", text_value.length(), " characters from ", Engine.get_version_info().get("string", "unknown"))
    quit(0)
