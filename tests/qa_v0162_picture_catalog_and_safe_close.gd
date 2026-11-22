extends SceneTree
## This test must run under an actual Godot 4 editor; Python static checks are not a substitute.
func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, description: String, problems: Array[String]) -> void:
    if not condition:
        problems.append(description)

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA 0162 FAIL: main scene cannot import")
        quit(1)
        return
    var shop: Node3D = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true) # Absolutely no writes/deletes of user save data.
    var failures: Array[String] = []
    _check(ResourceLoader.exists("res://assets/ui_symbols_v0162/buy.png"), "BUY icon absent", failures)
    _check(ResourceLoader.exists("res://assets/ui_symbols_v0162/shelf.png"), "STOCK icon absent", failures)
    _check(ResourceLoader.exists("res://assets/ui_symbols_v0162/bundle.png"), "BULK icon absent", failures)
    for i in range(27):
        _check(ResourceLoader.exists("res://assets/product_previews_v0162/product_%02d.png" % i), "SKU picture missing %d" % i, failures)
    var rows: Array = shop.get("desk_rows")
    _check(rows.size() == 9, "nine 3-page catalog rows missing", failures)
    for row in rows:
        _check(row.has("picture") and row["picture"] is TextureRect, "product picture control absent", failures)
        _check(row.has("icon") and row["icon"] is TextureRect, "category icon lost", failures)
    shop.call("_new_game")
    _check(bool(shop.get("playing")), "new game not active", failures)
    shop.call("_toggle_desk")
    _check((shop.get("desk_ui") as Panel).visible, "store desk did not open", failures)
    var day_before: int = int(shop.get("day"))
    shop.call("_request_finish_day")
    _check((shop.get("close_day_confirm_ui") as Panel).visible, "close-day confirmation missing", failures)
    _check(not (shop.get("desk_ui") as Panel).visible, "desk should hide under confirmation", failures)
    _check(int(shop.get("day")) == day_before, "day changed before confirmation", failures)
    shop.call("_cancel_finish_day")
    _check(not (shop.get("close_day_confirm_ui") as Panel).visible, "cancel did not close confirmation", failures)
    _check((shop.get("desk_ui") as Panel).visible, "cancel did not restore desk", failures)
    _check((shop.get("daily_history") as Array).is_empty(), "cancel recorded a business day", failures)
    shop.call("_request_finish_day")
    shop.call("_confirm_finish_day")
    _check((shop.get("report_ui") as Panel).visible, "confirmed close did not display summary", failures)
    _check((shop.get("daily_history") as Array).size() == 1, "closing did not record exactly one day", failures)
    shop.call("_close_report")
    _check(int(shop.get("day")) == day_before + 1, "day did not advance once", failures)
    var speed_before: int = int(shop.get("mouse_speed_mode"))
    shop.call("_cycle_mouse_speed")
    _check(int(shop.get("mouse_speed_mode")) == (speed_before + 1) % 3, "mouse look speed did not cycle", failures)
    shop.call("_cycle_mouse_speed")
    shop.call("_cycle_mouse_speed")
    _check(int(shop.get("mouse_speed_mode")) == speed_before, "mouse look speed cycle failed to wrap", failures)
    if failures.is_empty():
        print("QA 0162 PASSED: 27 product pictures, action symbols, guarded day close/cancel, mouse-speed settings")
        quit(0)
    else:
        for issue in failures:
            push_error("QA 0162 FAIL: " + issue)
        quit(1)
