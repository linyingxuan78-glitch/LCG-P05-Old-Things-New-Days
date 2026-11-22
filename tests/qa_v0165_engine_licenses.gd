extends SceneTree
## Native-only licensing API test. Uses zero private data and no real save files.
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var copyright_info: Array[Dictionary] = Engine.get_copyright_info()
    var licenses: Dictionary = Engine.get_license_info()
    var core_text: String = Engine.get_license_text()
    var notices: Script = load("res://scripts/engine_notices.gd")
    var combined: String = notices.render()
    if copyright_info.is_empty() or licenses.is_empty() or core_text.is_empty() or not combined.contains("GODOT CORE MIT LICENCE"):
        push_error("QA ENGINE RIGHTS 0165 FAILED: missing Godot runtime notices")
        quit(1)
        return
    print("QA ENGINE RIGHTS 0165 PASSED: source-runtime licence data present")
    quit(0)
