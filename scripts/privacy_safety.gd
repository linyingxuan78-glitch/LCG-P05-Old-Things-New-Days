extends Control
## LCG-P05 privacy and safety information. No login, tracking, identity checks,
## web calls, ad SDKs, user-generated content or chat are used by this module.
## Displayed only on demand from the title or pause menu; not an age gate.
const SHOP_SAVE_PATH: String = "user://lcg_p05_shop_v09.json"

var shop: Node3D
var panel: Panel
var confirm_panel: Panel
var status_label: Label
var delete_button: Button
var source_menu: String = "title"

func configure(owner_shop: Node3D) -> void:
    shop = owner_shop

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_ui()

func _make_panel(dimensions: Vector2) -> Panel:
    var p := Panel.new()
    p.size = dimensions
    p.custom_minimum_size = dimensions
    p.anchor_left = 0.5
    p.anchor_right = 0.5
    p.anchor_top = 0.5
    p.anchor_bottom = 0.5
    p.offset_left = -dimensions.x / 2.0
    p.offset_right = dimensions.x / 2.0
    p.offset_top = -dimensions.y / 2.0
    p.offset_bottom = dimensions.y / 2.0
    var style := StyleBoxFlat.new()
    style.bg_color = Color("18332d")
    style.border_color = Color("c9baa1")
    style.set_border_width_all(2)
    style.set_corner_radius_all(12)
    p.add_theme_stylebox_override("panel", style)
    add_child(p)
    return p

func _make_label(parent: Node, text_value: String, at: Vector2, dimensions: Vector2, size: int) -> Label:
    var lab := Label.new()
    lab.position = at
    lab.size = dimensions
    lab.text = text_value
    lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    lab.add_theme_font_size_override("font_size", size)
    lab.add_theme_color_override("font_color", Color("f6f0e2"))
    parent.add_child(lab)
    return lab

func _make_button(parent: Node, text_value: String, at: Vector2, dimensions: Vector2, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text_value
    button.position = at
    button.size = dimensions
    button.custom_minimum_size = dimensions
    button.add_theme_font_size_override("font_size", 17)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("376655")
    style.border_color = Color("a9beaa")
    style.set_border_width_all(2)
    style.set_corner_radius_all(8)
    button.add_theme_stylebox_override("normal", style)
    var focus: StyleBoxFlat = style.duplicate() as StyleBoxFlat
    focus.border_color = Color("f4d186")
    focus.set_border_width_all(4)
    button.add_theme_stylebox_override("focus", focus)
    button.focus_mode = Control.FOCUS_ALL
    parent.add_child(button)
    button.pressed.connect(callback)
    return button

func _build_ui() -> void:
    panel = _make_panel(Vector2(802, 574))
    _make_label(panel, "PRIVACY  /  FAMILY SAFETY", Vector2(30, 20), Vector2(744, 45), 30)
    # This screen is optional. No account/age/IP/user input is requested.
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(29, 75)
    scroll.size = Vector2(745, 337)
    panel.add_child(scroll)
    var body := _make_label(scroll,
        "NO LOGIN     NO ONLINE CHAT     NO AD TRACKING\n\n" +
        "PLAY OFFLINE\nThere is no second game account, real-name verification, webcam, location request or online chat in this build.\n\n" +
        "SAVES ON THIS DEVICE\nShop progress, sound/accessibility preferences and optional play-time reminders use local game files. Files are not encrypted; others who can access this device may be able to read them.\n\n" +
        "FAMILY / GUARDIAN\nAgree on screen time together. Use your device or storefront's parental controls for limits and purchases. The in-game reminders are suggestions, not a password lock.\n\n" +
        "THIRD PARTIES\nCurrent gameplay code does not include ad, analytics, login, chat or social SDKs. If these are added before release, the privacy notice and platform disclosures must be reviewed again.\n\n" +
        "YOUR CHOICES\nClear only local play-time history, or delete your shop progress and its built-in backup from this device. External copies or platform backups are outside the game's control.\n\n" +
        "This is a plain-language overview, not a legal certification. The complete third-party asset credits are in the separate Credits menu.",
        Vector2.ZERO, Vector2(703, 830), 19)
    body.custom_minimum_size = Vector2(703, 830)
    status_label = _make_label(panel, "No personal information is requested by this game.", Vector2(30, 420), Vector2(740, 57), 16)
    _make_button(panel, "CLEAR PLAY-TIME HISTORY", Vector2(29, 484), Vector2(240, 47), _clear_history)
    delete_button = _make_button(panel, "DELETE LOCAL SHOP SAVE", Vector2(277, 484), Vector2(240, 47), request_erase)
    _make_button(panel, "BACK", Vector2(532, 484), Vector2(240, 47), close_panel)
    panel.visible = false
    confirm_panel = _make_panel(Vector2(650, 320))
    _make_label(confirm_panel, "DELETE LOCAL SHOP PROGRESS?", Vector2(28, 22), Vector2(600, 50), 26)
    _make_label(confirm_panel,
        "This removes the current shop save, its recovery copy AND any pending save from this device.\n\nIt cannot be undone in the game. Play-time reminder settings are separate. This does not remove external backups.",
        Vector2(32, 89), Vector2(580, 134), 20)
    _make_button(confirm_panel, "KEEP MY SAVE", Vector2(35, 245), Vector2(268, 50), cancel_erase)
    _make_button(confirm_panel, "YES, DELETE SAVE", Vector2(324, 245), Vector2(289, 50), confirm_erase)
    confirm_panel.visible = false

func open_panel() -> void:
    if shop == null:
        return
    source_menu = "pause" if bool(shop.get("playing")) else "title"
    if source_menu == "pause":
        shop.set("paused", true)
        (shop.get("pause_ui") as Panel).visible = false
    else:
        (shop.get("title_ui") as Panel).visible = false
    status_label.text = "No personal information is requested by this game."
    delete_button.disabled = source_menu != "title"
    delete_button.tooltip_text = "Available from the main menu only" if source_menu != "title" else "Requires a second confirmation"
    panel.visible = true
    confirm_panel.visible = false
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    shop.call("_focus_menu_controls", panel)

func is_open() -> bool:
    return (panel != null and panel.visible) or (confirm_panel != null and confirm_panel.visible)

func hide_panel() -> void:
    if panel != null:
        panel.visible = false
    if confirm_panel != null:
        confirm_panel.visible = false

func close_or_cancel() -> void:
    if confirm_panel != null and confirm_panel.visible:
        cancel_erase()
    else:
        close_panel()

func close_panel() -> void:
    hide_panel()
    if shop == null:
        return
    if source_menu == "pause":
        (shop.get("pause_ui") as Panel).visible = true
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    else:
        shop.call("_show_title")
    if source_menu == "pause":
        shop.call("_focus_menu_controls", shop.get("pause_ui"), "PRIVACY / SAFETY")
    else:
        shop.call("_focus_menu_controls", shop.get("title_ui"), "SAFETY")

func _clear_history() -> void:
    if shop == null:
        return
    var healthy: Control = shop.get("healthy_play") as Control
    if healthy == null:
        status_label.text = "Play-time history not available."
        return
    healthy.call("clear_local_activity_history")
    status_label.text = "Local play-time history reset. Your shop save is unchanged."

func request_erase() -> void:
    if shop == null or source_menu != "title":
        return
    panel.visible = false
    confirm_panel.visible = true
    shop.call("_focus_menu_controls", confirm_panel)

func cancel_erase() -> void:
    confirm_panel.visible = false
    panel.visible = true
    if shop != null:
        shop.call("_focus_menu_controls", panel)

func confirm_erase() -> void:
    # No destructive tests may ever remove real player data.
    if shop == null or source_menu != "title" or bool(shop.get("qa_mode")):
        cancel_erase()
        return
    var failed: bool = false
    for path in [SHOP_SAVE_PATH, SHOP_SAVE_PATH + ".bak", SHOP_SAVE_PATH + ".pending"]:
        if FileAccess.file_exists(path):
            if DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) != OK:
                failed = true
    confirm_panel.visible = false
    panel.visible = true
    if failed:
        status_label.text = "Some local save data could not be removed. Check device permissions."
    else:
        (shop.get("title_continue") as Button).disabled = true
        status_label.text = "Local save, backup and pending recovery removed. Reminder settings remain."
