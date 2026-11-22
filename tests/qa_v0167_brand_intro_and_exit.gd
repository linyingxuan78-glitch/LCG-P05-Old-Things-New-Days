extends SceneTree
## Godot engine QA only. No real user save files are touched.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn")
    if packed == null:
        push_error("QA BRAND 0167 FAILED: missing main scene")
        quit(1)
        return
    var game: Node = packed.instantiate()
    game.set("qa_mode", true)
    root.add_child(game)
    await process_frame
    var splash: Control = game.get("splash_ui") as Control
    var title: Control = game.get("title_ui") as Control
    if splash == null or title == null:
        push_error("QA BRAND 0167 FAILED: splash / title UI missing")
        quit(1)
        return
    game.call("_show_splash")
    game.call("_skip_splash")
    if splash.visible or not title.visible:
        push_error("QA BRAND 0167 FAILED: skipped intro did not open title")
        quit(1)
        return
    game.call("_skip_splash")
    if not title.visible:
        push_error("QA BRAND 0167 FAILED: repeated skip changed state")
        quit(1)
        return
    print("QA BRAND 0167 PASSED: splash available, skip idempotent, title reached")
    quit(0)
