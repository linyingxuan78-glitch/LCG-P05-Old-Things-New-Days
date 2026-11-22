extends SceneTree
## Native HUD input regression. Run with Godot 4 after import.
## Must report failure rather than printing PASS on an invalid scene.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA UI INPUT FAILED: main.tscn not loadable")
        quit(1)
        return
    var shop: Node = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    var problems: Array[String] = []
    var layer: CanvasLayer = shop.get("ui_layer") as CanvasLayer
    var hud: Control = shop.get("hud_ui") as Control
    if layer == null or layer.get_child_count() == 0:
        problems.append("UI canvas missing")
    else:
        var ui_root: Control = layer.get_child(0) as Control
        if ui_root == null or ui_root.mouse_filter != Control.MOUSE_FILTER_IGNORE:
            problems.append("Fullscreen UI root captures mouse input")
    if hud == null or hud.mouse_filter != Control.MOUSE_FILTER_IGNORE:
        problems.append("Fullscreen HUD captures mouse input")
    elif hud.get_child_count() < 3:
        problems.append("HUD panels missing")
    else:
        for child in hud.get_children():
            if child is Panel and (child as Panel).mouse_filter != Control.MOUSE_FILTER_IGNORE:
                problems.append("Noninteractive HUD Panel captures mouse input")
    var title: Panel = shop.get("title_ui") as Panel
    if title == null:
        problems.append("Title menu missing")
    else:
        var found_button: bool = false
        for child in title.get_children():
            if child is Button and (child as Button).mouse_filter != Control.MOUSE_FILTER_IGNORE:
                found_button = true
        if not found_button:
            problems.append("Title menu lacks mouse-enabled buttons")
    if not problems.is_empty():
        for problem in problems:
            push_error("QA UI INPUT FAILED: " + problem)
        quit(1)
    else:
        print("QA UI INPUT PASSED: HUD is click-through; menu buttons remain interactive")
        quit(0)
