extends SceneTree
## Requires a real Godot 4.4 editor import, then headless execution.
## Does not claim visual accessibility or photosensitivity certification.

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String, problems: Array[String]) -> void:
    if not ok:
        problems.append(reason)

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("Main scene not available")
        quit(1)
        return
    var shop: Node = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    var problems: Array[String] = []
    var controls: Array = shop.get("accessibility_buttons")
    _check(controls.size() == 7, "Seven independently selectable accessibility controls required", problems)
    shop.set("gentle_camera", true)
    shop.set("soft_lighting", true)
    shop.set("reduced_motion", true)
    shop.set("picture_guides", true)
    shop.call("_apply_accessibility")
    var camera: Camera3D = shop.get("camera") as Camera3D
    var sun: DirectionalLight3D = shop.get("sunlight_light") as DirectionalLight3D
    var environment: Environment = shop.get("shop_environment") as Environment
    _check(camera != null and is_equal_approx(camera.fov, 70.0), "Gentle camera should have 70 FOV", problems)
    _check(sun != null and is_equal_approx(sun.light_energy, 0.72), "Soft sunlight setting missing", problems)
    _check(environment != null and is_equal_approx(environment.ambient_light_energy, 0.74), "Soft ambient setting missing", problems)
    shop.call("_toggle_accessibility", 5)
    _check(not bool(shop.get("gentle_camera")) and is_equal_approx(camera.fov, 74.0), "Camera toggle ineffective", problems)
    shop.call("_toggle_accessibility", 6)
    _check(not bool(shop.get("soft_lighting")) and is_equal_approx(sun.light_energy, 0.95), "Lighting toggle ineffective", problems)
    shop.call("_new_game")
    var tutorial: Panel = shop.get("tutorial_panel") as Panel
    var picture: Panel = shop.get("pictogram_panel") as Panel
    var illustration: TextureRect = shop.get("tutorial_icon") as TextureRect
    var keycap: Label = shop.get("tutorial_keycap") as Label
    _check(tutorial != null and picture != null and tutorial.offset_top >= picture.offset_bottom, "Tutorial overlaps upper-right pictograms", problems)
    _check(tutorial.visible, "New game must offer the optional first-session tutorial", problems)
    _check(illustration != null and illustration.texture != null, "Tutorial missing its pictogram", problems)
    _check(keycap != null and keycap.text.find("TAB") >= 0, "First tutorial stage should show a keyboard action", problems)
    var status_labels: Array = shop.get("pictogram_labels")
    _check(status_labels.size() == 4, "Four status pictograms must be present", problems)
    _check((status_labels[0] as Label).text.find("OK") >= 0, "Pictograms must have status text, not color alone", problems)
    var help: Control = shop.get("help_ui") as Control
    var has_scroll: bool = false
    for child in help.get_children():
        if child is ScrollContainer:
            has_scroll = true
    _check(has_scroll, "Long help should be scrollable", problems)
    _check(int(shop.get("cash")) == 80, "Accessibility controls must not affect starting cash", problems)
    if problems.is_empty():
        print("QA 0158 PASSED: tutorial icons, no-overlap, scrollable help, comfort controls and no economy change")
        quit(0)
    else:
        for issue in problems:
            push_error("QA 0158 FAIL: " + issue)
        quit(1)
