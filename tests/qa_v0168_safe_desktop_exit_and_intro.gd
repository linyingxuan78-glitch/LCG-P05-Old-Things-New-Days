extends SceneTree
## Godot 4 native QA only; no player files are opened or modified.
## Tests real scene methods and splash alpha, not actual Windows hardware or display output.
func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String, failures: Array[String]) -> void:
    if not ok:
        failures.append(label)

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA 0168 FAILED: main scene unavailable")
        quit(1)
        return
    var shop: Node3D = scene.instantiate()
    shop.set("qa_mode", true) # Must be set before _ready() on add_child.
    root.add_child(shop)
    await process_frame
    var failures: Array[String] = []
    var splash: Control = shop.get("splash_ui") as Control
    var title: Control = shop.get("title_ui") as Control
    var logo: Control = shop.get("splash_logo") as Control
    _check(splash != null and title != null and logo != null, "missing splash, title or logo", failures)
    if splash != null and title != null and logo != null:
        shop.set("reduced_motion", false)
        shop.call("_show_splash")
        _check(splash.visible and not title.visible, "standard splash not displayed", failures)
        shop.call("_advance_splash", 0.25)
        _check(absf(logo.modulate.a - 0.5) < 0.02, "splash fade-in alpha at 0.25s", failures)
        shop.call("_advance_splash", 0.75)
        _check(absf(logo.modulate.a - 1.0) < 0.02, "splash steady alpha", failures)
        shop.call("_advance_splash", 0.64)
        _check(logo.modulate.a < 0.55 and splash.visible, "splash final fade-out alpha", failures)
        shop.call("_advance_splash", 0.16)
        _check(not splash.visible and title.visible, "splash not closed at 1.8s", failures)
        shop.set("reduced_motion", true)
        shop.call("_show_splash")
        _check(not splash.visible and title.visible, "reduced motion did not bypass ident", failures)
    shop.call("_new_game")
    _check(bool(shop.get("playing")), "new game did not start", failures)
    shop.set("qa_force_save_failure", true)
    shop.call("_back_to_menu")
    _check(bool(shop.get("playing")), "failed save exited to menu", failures)
    _check(not bool(shop.call("_prepare_desktop_exit")), "failed save authorized desktop exit", failures)
    shop.call("_quit_desktop")
    _check(bool(shop.get("playing")), "failed save ended gameplay", failures)
    _check(not bool(shop.get("exit_committed")), "failed save set exit commit flag", failures)
    shop.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
    _check(not bool(shop.get("exit_committed")), "window X / Alt+F4 bypassed failed-save guard", failures)
    shop.set("qa_force_save_failure", false)
    _check(bool(shop.call("_prepare_desktop_exit")), "successful save did not authorize closing", failures)
    if failures.is_empty():
        print("QA 0168 PASSED: fade envelope, skip motion, new game, failed-save guards for menu/X/desktop")
        quit(0)
    else:
        for issue in failures:
            push_error("QA 0168 FAILED: " + issue)
        quit(1)
