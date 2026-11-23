extends Control
## Optional, privacy-preserving healthy-play guidance. No account, age or identity data.
## Uses local device time for same-device daily totals. This is not enforceable parental control.
const PREFERENCES_PATH: String = "user://lcg_p05_healthy_play.json"
const BREAK_OPTIONS: Array[int] = [15, 25, 40, 0] # Minutes; 0 = off.
const DAILY_OPTIONS: Array[int] = [60, 90, 120, 0] # Minutes; 0 = off.
const SAVE_EVERY_SECONDS: float = 30.0
const RECENT_RESTART_SECONDS: int = 600

var shop: Node3D
var break_minutes: int = 25
var daily_minutes: int = 90
var session_seconds: float = 0.0
var today_seconds: float = 0.0
var stored_day: String = ""
var next_break_seconds: float = 1500.0
var daily_notice_seen: bool = false
var last_exit_unix: int = 0
var previous_session_seconds: float = 0.0
var pending_return_notice: bool = false
var active_session: bool = false
var save_elapsed: float = 0.0
var toast_seconds: float = 0.0
var panel: Panel
var toast: Panel
var toast_label: Label
var time_label: Label
var break_button: Button
var daily_button: Button
var source_menu: String = "title"

func configure(owner_shop: Node3D) -> void:
    shop = owner_shop

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _load_local_preferences()
    _build_ui()

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_CLOSE_REQUEST:
        _save_local_preferences()

func _exit_tree() -> void:
    if active_session:
        finish_session()
    else:
        _save_local_preferences()

func _make_panel(at: Vector2, dimensions: Vector2) -> Panel:
    var result := Panel.new()
    result.position = at
    result.size = dimensions
    result.custom_minimum_size = dimensions
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.055, 0.12, 0.11, 0.99)
    style.border_color = Color("a9beaa")
    style.set_border_width_all(2)
    style.set_corner_radius_all(11)
    result.add_theme_stylebox_override("panel", style)
    add_child(result)
    return result

func _label(parent: Node, text_value: String, at: Vector2, dimensions: Vector2, font_size: int) -> Label:
    var result := Label.new()
    result.text = text_value
    result.position = at
    result.size = dimensions
    result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    result.add_theme_font_size_override("font_size", font_size)
    result.add_theme_color_override("font_color", Color("fff6e6"))
    result.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(result)
    return result

func _make_button(parent: Node, title_text: String, at: Vector2, dimensions: Vector2, callback: Callable) -> Button:
    var b := Button.new()
    b.text = title_text
    b.position = at
    b.size = dimensions
    b.custom_minimum_size = dimensions
    b.add_theme_font_size_override("font_size", 19)
    b.add_theme_color_override("font_color", Color.WHITE)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("376655")
    style.border_color = Color("a6bcaa")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    b.add_theme_stylebox_override("normal", style)
    var hover: StyleBoxFlat = style.duplicate() as StyleBoxFlat
    hover.bg_color = Color("507e68")
    b.add_theme_stylebox_override("hover", hover)
    var focus: StyleBoxFlat = style.duplicate() as StyleBoxFlat
    focus.set_border_width_all(4)
    focus.border_color = Color("f4d186")
    b.add_theme_stylebox_override("focus", focus)
    b.focus_mode = Control.FOCUS_ALL
    parent.add_child(b)
    b.pressed.connect(callback)
    return b

func _build_ui() -> void:
    # Single static, non-pulsing toast, below main HUD and outside the tutorial panel.
    toast = _make_panel(Vector2(20, 221), Vector2(445, 89))
    toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
    toast_label = _label(toast, "", Vector2(16, 9), Vector2(415, 73), 18)
    toast.visible = false
    panel = _make_panel(Vector2.ZERO, Vector2(680, 570))
    panel.anchor_left = 0.5
    panel.anchor_right = 0.5
    panel.anchor_top = 0.5
    panel.anchor_bottom = 0.5
    panel.offset_left = -340.0
    panel.offset_right = 340.0
    panel.offset_top = -285.0
    panel.offset_bottom = 285.0
    _label(panel, "HEALTHY PLAY  /  FAMILY GUIDE", Vector2(28, 20), Vector2(630, 47), 28)
    time_label = _label(panel, "", Vector2(30, 76), Vector2(626, 60), 20)
    _label(panel, "Gentle reminders for everyone, not a timer challenge.", Vector2(30, 145), Vector2(625, 36), 18)
    break_button = _make_button(panel, "", Vector2(30, 193), Vector2(621, 49), _cycle_break_interval)
    daily_button = _make_button(panel, "", Vector2(30, 252), Vector2(621, 49), _cycle_daily_interval)
    _label(panel, "FAMILY PLAY PLAN", Vector2(30, 319), Vector2(621, 36), 23)
    _label(panel,
        "Children and caregivers can agree on a daily play plan, with time for sleep, meals, homework and offline activities.\n\nThese settings offer reminders only; they are not a password-protected lock. For enforceable limits, use device or platform parental controls.\n\nEverything is saved on this device only. No birth date, identity, account or play history is uploaded.",
        Vector2(30, 360), Vector2(620, 141), 16)
    _make_button(panel, "BACK  /  CONTINUE", Vector2(197, 515), Vector2(290, 42), close_panel)
    panel.visible = false
    _refresh_panel()

func _refresh_panel() -> void:
    if panel == null:
        return
    time_label.text = "This session: %d min  |  Today on this device: %d min" % [int(session_seconds / 60.0), int(today_seconds / 60.0)]
    break_button.text = "BREAK / WATER REMINDER: %s" % ("OFF" if break_minutes == 0 else ("EVERY %d MIN" % break_minutes))
    daily_button.text = "DAILY FAMILY REMINDER: %s" % ("OFF" if daily_minutes == 0 else ("AFTER %d MIN" % daily_minutes))

func _cycle_break_interval() -> void:
    var index: int = BREAK_OPTIONS.find(break_minutes)
    break_minutes = BREAK_OPTIONS[(index + 1) % BREAK_OPTIONS.size()]
    next_break_seconds = session_seconds + float(break_minutes * 60) if break_minutes > 0 else INF
    _refresh_panel()
    _save_local_preferences()

func _cycle_daily_interval() -> void:
    var index: int = DAILY_OPTIONS.find(daily_minutes)
    daily_minutes = DAILY_OPTIONS[(index + 1) % DAILY_OPTIONS.size()]
    _refresh_panel()
    _save_local_preferences()

func open_panel() -> void:
    if shop == null:
        return
    source_menu = "pause" if bool(shop.get("playing")) else "title"
    if source_menu == "pause":
        shop.set("paused", true)
        (shop.get("pause_ui") as Panel).visible = false
    else:
        (shop.get("title_ui") as Panel).visible = false
    _check_day_rollover()
    _refresh_panel()
    panel.visible = true
    toast.visible = false
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    shop.call("_focus_menu_controls", panel)

func close_panel() -> void:
    panel.visible = false
    if shop == null:
        return
    if source_menu == "pause":
        (shop.get("pause_ui") as Panel).visible = true
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    else:
        shop.call("_show_title")
    _save_local_preferences()
    if source_menu == "pause":
        shop.call("_focus_menu_controls", shop.get("pause_ui"), "HEALTHY PLAY / FAMILY")
    else:
        shop.call("_focus_menu_controls", shop.get("title_ui"), "PLAY TIME")

func is_open() -> bool:
    return panel != null and panel.visible

func begin_session() -> void:
    _check_day_rollover()
    if not active_session:
        active_session = true
        session_seconds = 0.0
        next_break_seconds = float(break_minutes * 60) if break_minutes > 0 else INF
        if pending_return_notice:
            _show_message("WELCOME BACK  /  REST\nIf you have just been playing, consider taking a break.")
            pending_return_notice = false

func finish_session() -> void:
    if not active_session:
        return
    active_session = false
    previous_session_seconds = session_seconds
    last_exit_unix = int(Time.get_unix_time_from_system())
    _save_local_preferences()
    toast.visible = false

func _check_day_rollover() -> void:
    var local_day: String = Time.get_date_string_from_system()
    if stored_day != local_day:
        stored_day = local_day
        today_seconds = 0.0
        daily_notice_seen = false

func _show_message(message: String) -> void:
    if toast_label == null:
        return
    toast_label.text = message
    toast_seconds = 9.0
    toast.visible = true

func _record_active_time(seconds: float) -> void:
    # Unit-testable business logic. Never coerce players to continue or punish rest.
    if seconds <= 0.0:
        return
    _check_day_rollover()
    session_seconds += seconds
    today_seconds += seconds
    save_elapsed += seconds
    if break_minutes > 0 and session_seconds >= next_break_seconds:
        next_break_seconds = session_seconds + float(break_minutes * 60)
        _show_message("REST / WATER BREAK\nConsider standing, resting your eyes and drinking water.")
    if daily_minutes > 0 and not daily_notice_seen and today_seconds >= float(daily_minutes * 60):
        daily_notice_seen = true
        _show_message("FAMILY PLAY PLAN\nToday's planned time is reached. Consider stopping.")
    if save_elapsed >= SAVE_EVERY_SECONDS:
        save_elapsed = 0.0
        _save_local_preferences()

func _process(delta: float) -> void:
    if toast != null and toast.visible:
        toast_seconds -= delta
        if toast_seconds <= 0.0:
            toast.visible = false
    if not active_session or shop == null or bool(shop.get("qa_mode")):
        return
    if not bool(shop.get("playing")) or bool(shop.get("paused")) or is_open():
        return
    if not DisplayServer.window_is_focused():
        return
    # Delta is capped so returning from suspension does not count hours as play.
    _record_active_time(clampf(delta, 0.0, 0.25))

func clear_local_activity_history() -> void:
    # Local choice: clear play-time history only. Keep user-chosen reminder settings.
    # This is not tamper-resistant parental control or a cloud deletion request.
    session_seconds = 0.0
    today_seconds = 0.0
    previous_session_seconds = 0.0
    last_exit_unix = 0
    pending_return_notice = false
    daily_notice_seen = false
    save_elapsed = 0.0
    stored_day = Time.get_date_string_from_system()
    next_break_seconds = float(break_minutes * 60) if break_minutes > 0 else INF
    if toast != null:
        toast.visible = false
    _refresh_panel()
    _save_local_preferences()

func _load_local_preferences() -> void:
    stored_day = Time.get_date_string_from_system()
    if not FileAccess.file_exists(PREFERENCES_PATH):
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PREFERENCES_PATH))
    if not (data is Dictionary):
        return
    var prefs: Dictionary = data
    var saved_break: int = int(prefs.get("break_minutes", 25))
    var saved_daily: int = int(prefs.get("daily_minutes", 90))
    break_minutes = saved_break if BREAK_OPTIONS.has(saved_break) else 25
    daily_minutes = saved_daily if DAILY_OPTIONS.has(saved_daily) else 90
    if str(prefs.get("date", "")) == stored_day:
        today_seconds = clampf(float(prefs.get("today_seconds", 0.0)), 0.0, 86400.0)
        daily_notice_seen = bool(prefs.get("daily_notice_seen", false))
    last_exit_unix = int(prefs.get("last_exit_unix", 0))
    previous_session_seconds = clampf(float(prefs.get("previous_session_seconds", 0.0)), 0.0, 86400.0)
    var now: int = int(Time.get_unix_time_from_system())
    pending_return_notice = last_exit_unix > 0 and now >= last_exit_unix and now - last_exit_unix < RECENT_RESTART_SECONDS and previous_session_seconds >= 300.0

func _save_local_preferences() -> void:
    if shop != null and bool(shop.get("qa_mode")):
        return
    var prefs: Dictionary = {"version":1, "date":stored_day,
        "break_minutes":break_minutes, "daily_minutes":daily_minutes,
        "today_seconds":today_seconds, "daily_notice_seen":daily_notice_seen,
        "last_exit_unix":last_exit_unix, "previous_session_seconds":previous_session_seconds}
    var handle: FileAccess = FileAccess.open(PREFERENCES_PATH, FileAccess.WRITE)
    if handle != null:
        handle.store_string(JSON.stringify(prefs))
        handle.close()
