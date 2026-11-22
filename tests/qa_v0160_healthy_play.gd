extends SceneTree
## Native-only functional QA. Must be run by actual Godot 4 after import.
func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String, errors: Array[String]) -> void:
    if not ok:
        errors.append(detail)

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("QA 0160 FAIL: scene did not load")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    var errors: Array[String] = []
    var guide: Control = shop.get("healthy_play") as Control
    _check(guide != null, "healthy play controller missing", errors)
    if guide != null:
        _check(guide.get("break_minutes") in [0,15,25,40], "invalid break options", errors)
        _check(guide.get("daily_minutes") in [0,60,90,120], "invalid family time options", errors)
        _check(guide.get("panel") != null and guide.get("toast") != null, "accessible panel and static toast absent", errors)
        guide.set("stored_day", Time.get_date_string_from_system())
        guide.set("today_seconds", 0.0)
        guide.set("session_seconds", 0.0)
        guide.set("break_minutes", 15)
        guide.set("daily_minutes", 60)
        guide.set("next_break_seconds", 900.0)
        guide.set("daily_notice_seen", false)
        guide.call("_record_active_time", 899.0)
        _check(not (guide.get("toast") as Panel).visible, "break message too early", errors)
        guide.call("_record_active_time", 1.5)
        _check((guide.get("toast") as Panel).visible, "first break message missing", errors)
        _check(str((guide.get("toast_label") as Label).text).contains("WATER"), "reminder missing hydration message", errors)
        _check(float(guide.get("next_break_seconds")) > 900.0, "next break deadline must move forward", errors)
        guide.set("daily_notice_seen", false)
        guide.set("next_break_seconds", INF)
        guide.call("_record_active_time", 2700.0)
        _check(bool(guide.get("daily_notice_seen")), "daily notice not triggered", errors)
        _check(str((guide.get("toast_label") as Label).text).contains("FAMILY"), "family notice missing", errors)
        guide.call("_record_active_time", 1.0)
        _check(bool(guide.get("daily_notice_seen")), "daily notice should stay acknowledged", errors)
        guide.set("stored_day", "2000-01-01")
        guide.call("_check_day_rollover")
        _check(float(guide.get("today_seconds")) == 0.0 and not bool(guide.get("daily_notice_seen")), "new-day reset must clear daily duration and notice", errors)
        shop.call("_show_title")
        guide.call("open_panel")
        _check(guide.call("is_open"), "title screen health menu not accessible", errors)
        _check(not (shop.get("title_ui") as Panel).visible, "title should be hidden behind health panel", errors)
        guide.call("close_panel")
        _check((shop.get("title_ui") as Panel).visible, "return from health menu to title", errors)
        guide.set("break_minutes", 25)
        guide.call("_cycle_break_interval")
        _check(int(guide.get("break_minutes")) == 40, "reminder cycling wrong", errors)
        guide.set("break_minutes", 40)
        guide.call("_cycle_break_interval")
        _check(int(guide.get("break_minutes")) == 0, "must be able to turn reminders off", errors)
    if errors.is_empty():
        print("QA 0160 PASSED: healthy play, rest/hydration timing, daily notice, local day reset, title access, optional settings")
        quit(0)
    else:
        for issue in errors:
            push_error("QA 0160 FAIL: " + issue)
        quit(1)
