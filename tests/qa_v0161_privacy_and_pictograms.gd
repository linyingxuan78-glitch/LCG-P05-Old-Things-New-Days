extends SceneTree
## Real Godot-only acceptance. QA_MODE prevents save deletion.
func _initialize() -> void:
    call_deferred("_run")

func _check(value: bool, label: String, issues: Array[String]) -> void:
    if not value:
        issues.append(label)

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA 0161 FAIL: scene unavailable")
        quit(1)
        return
    var shop: Node3D = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    var errors: Array[String] = []
    var privacy: Control = shop.get("privacy_safety") as Control
    var healthy: Control = shop.get("healthy_play") as Control
    _check(privacy != null, "privacy panel not constructed", errors)
    _check(healthy != null, "health reminders lost", errors)
    var rows: Array = shop.get("desk_rows")
    _check(rows.size() == 9, "nine catalog rows missing", errors)
    for index in range(6):
        _check(ResourceLoader.exists("res://assets/comfort_icons/category_%d.png" % index), "category icon missing %d" % index, errors)
    if rows.size() == 9:
        for row in rows:
            _check(row.has("icon") and (row["icon"] as TextureRect) != null, "catalog pictogram node missing", errors)
    # Visual regression: four captions must stay below their icon row and above event text.
    var picture_labels: Array = shop.get("pictogram_labels")
    var picture_icons: Array = shop.get("pictogram_icons")
    var event_label: Label = shop.get("pictogram_event") as Label
    _check(picture_labels.size() == 4, "expected four status caption labels", errors)
    _check(event_label != null, "pictogram event label missing", errors)
    if picture_labels.size() == 4 and event_label != null:
        for item in picture_labels:
            var caption_label: Label = item as Label
            _check(caption_label != null and caption_label.text.contains("\n"), "status label must be split across two readable lines", errors)
            if caption_label != null:
                _check(caption_label.position.y + caption_label.size.y < event_label.position.y, "status label overlaps event banner", errors)
    _check(picture_icons.size() == 4, "expected four fixed-size guide icons", errors)
    if picture_icons.size() == 4 and picture_labels.size() == 4:
        for icon_index in range(4):
            var badge: TextureRect = picture_icons[icon_index] as TextureRect
            var caption: Label = picture_labels[icon_index] as Label
            if badge != null and caption != null:
                _check(badge.size.x <= 45.0 and badge.size.y <= 45.0, "guide pictogram exceeds 42px drawing slot", errors)
                _check(badge.position.y + badge.size.y < caption.position.y, "pictogram overlaps its status caption", errors)
    var title_panel: Panel = shop.get("title_ui") as Panel
    var exit_button: Button = null
    if title_panel != null:
        for child in title_panel.get_children():
            if child is Button and (child as Button).text == "QUIT GAME":
                exit_button = child as Button
    _check(exit_button != null, "compact title quit button missing", errors)
    if exit_button != null and title_panel != null:
        _check(exit_button.position.x + exit_button.size.x <= title_panel.size.x - 3.0, "title quit button overflows panel", errors)
    shop.call("_show_title")
    if privacy != null:
        shop.call("_open_privacy_safety")
        _check(bool(privacy.call("is_open")), "privacy menu unavailable from title", errors)
        _check(not (shop.get("title_ui") as Panel).visible, "title visible under privacy menu", errors)
        privacy.call("request_erase")
        _check((privacy.get("confirm_panel") as Panel).visible, "delete confirmation absent", errors)
        privacy.call("confirm_erase")
        _check(not (privacy.get("confirm_panel") as Panel).visible, "QA guard must cancel delete", errors)
        privacy.call("close_panel")
        _check((shop.get("title_ui") as Panel).visible, "back from privacy must restore title", errors)
        shop.set("playing", true)
        shop.set("paused", true)
        (shop.get("pause_ui") as Panel).visible = true
        shop.call("_open_privacy_safety")
        _check(bool((privacy.get("delete_button") as Button).disabled), "delete must not be available while shop open", errors)
        privacy.call("close_panel")
        _check((shop.get("pause_ui") as Panel).visible, "back from privacy must restore pause", errors)
        shop.call("_show_title")
    if healthy != null:
        healthy.set("session_seconds", 300.0)
        healthy.set("today_seconds", 400.0)
        healthy.set("previous_session_seconds", 100.0)
        healthy.call("clear_local_activity_history")
        _check(float(healthy.get("today_seconds")) == 0.0, "local play-time history not reset", errors)
    if errors.is_empty():
        print("QA 0161 PASSED: title/pause safety, delete confirmation, QA erase guard, 6 picture categories, healthy history reset")
        quit(0)
    else:
        for problem in errors:
            push_error("QA 0161 FAIL: " + problem)
        quit(1)
