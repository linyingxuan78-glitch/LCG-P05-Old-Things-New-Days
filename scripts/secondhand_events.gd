extends Control
## Low-frequency, picture-first resale incidents. Original scenarios inspired by
## documented second-hand retail processes, NOT verbatim retellings of real people.
## This adds no online features, tracking, advertising or paid dependencies.
##
## Parent shop remains authoritative for cash, stock, day expenses and save data.
## All event decisions persist atomically in the existing crash-safe save payload.

const MAX_BACKROOM: int = 8
const MAX_GOODWILL: int = 12
const CASES: Array[Dictionary] = [
    {"id":"textile_surplus", "title":"EXTRA CLOTHES", "prompt":"The textile recycler cannot collect today.\nA free rack may help, but not everything gets taken.", "sku":25, "picture":"rack",
        "options":[{"name":"FREE RACK", "icon":"rack", "hint":"Let neighbours take clothes for free. It may not clear the whole pile."},
                   {"name":"KEEP BOX", "icon":"box", "hint":"Keep the spare clothes for another day; they take storage room."}]},
    {"id":"appliance_check", "title":"CHECK A USED ITEM", "prompt":"A second-hand appliance needs a proper check.\nDo not put an untested item straight onto the shelf.", "sku":5, "picture":"check",
        "options":[{"name":"CHECK  $2", "icon":"check", "hint":"Pay for an inspection; only a passing item may go on sale."},
                   {"name":"SET ASIDE", "icon":"box", "hint":"Do not sell an untested appliance. Store it separately."}]},
    {"id":"private_keepsake", "title":"PRIVATE KEEPSAKE", "prompt":"A donated box includes a personal keepsake.\nIt is not a normal item for sale.", "sku":1, "picture":"return",
        "options":[{"name":"RETURN", "icon":"return", "hint":"Use the store's return-to-owner procedure without exposing private details."},
                   {"name":"SAFE KEEP", "icon":"box", "hint":"Keep the item secure while checking who it belongs to."}]},
    {"id":"missing_price", "title":"MISSING PRICE", "prompt":"An item has lost its price label.\nCheck the price before selling it.", "sku":24, "picture":"check",
        "options":[{"name":"CHECK TAG", "icon":"check", "hint":"Verify and restore the store's price information."},
                   {"name":"HOLD ITEM", "icon":"box", "hint":"Take the item off sale until the price can be checked."}]},
    {"id":"mixed_donation", "title":"SORT A DONATION", "prompt":"A delivery mixes usable clothing with items\nthat need sorting. There may be one good bundle.", "sku":25, "picture":"sort",
        "options":[{"name":"SORT  $2", "icon":"sort", "hint":"Spend $2 to check and organise; add the usable bundle only if shelf room remains."},
                   {"name":"DECLINE", "icon":"return", "hint":"Politely refuse this unprocessed batch; no surprise fine."}]},
    {"id":"blocked_aisle", "title":"CLEAR THE WALKWAY", "prompt":"Boxes are blocking a display and access path.\nMake room before more shoppers arrive.", "sku":16, "picture":"broom",
        "options":[{"name":"CLEAR  $1", "icon":"broom", "hint":"Pay a small handling cost to clear the walking route."},
                   {"name":"LATER", "icon":"box", "hint":"Leave the display blocked for now; some shoppers may be discouraged."}]},
    {"id":"furniture_repair", "title":"FIX OR REUSE", "prompt":"A used chair needs repair before it can sell.\nA repaired item still needs room on the shelf.", "sku":24, "picture":"repair",
        "options":[{"name":"REPAIR  $4", "icon":"repair", "hint":"Pay for safe repair. Display only if enough shelf space exists."},
                   {"name":"REUSE PARTS", "icon":"sort", "hint":"Put the damaged item aside for reuse; don't falsely label it as repaired."}]}
]
const ICON_PATH: String = "res://assets/ui_story_icons/%s.svg"

var shop: Node3D
var active_id: String = ""
var handled: bool = false
var backroom_boxes: int = 0
var goodwill: int = 0
var outcome_summary: String = ""
var panel_choice_consumed: bool = false
var panel: Panel
var item_picture: TextureRect
var action_icon: TextureRect
var heading: Label
var explanation: Label
var outcome: Label
var outcome_picture: TextureRect
var outcome_number: Label
var stat_labels: Array[Label] = []
var first: Button
var second: Button
var done_button: Button
var speech_button: Button
var speech_used: bool = false
var entry_button: Button

func configure(owner: Node3D) -> void:
    shop = owner
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_ui()

func _icon(name: String) -> Texture2D:
    return load(ICON_PATH % name) as Texture2D

func _build_ui() -> void:
    panel = shop.call("_panel", self, Vector2.ZERO, Vector2(750, 526), Color(0.055, 0.125, 0.115, 0.99)) as Panel
    shop.call("_center_panel", panel)
    heading = shop.call("_text", panel, Vector2(25, 20), Vector2(608, 48), 30, Color("f7ebcf")) as Label
    speech_button = shop.call("_button", panel, "", Vector2(656, 20), Vector2(66, 54), Callable(self, "_speak_event")) as Button
    speech_button.icon = _icon("speaker")
    speech_button.add_theme_constant_override("icon_max_width", 47)
    speech_button.tooltip_text = "Listen to this event and both choices (English system voice)"
    item_picture = TextureRect.new()
    item_picture.position = Vector2(44, 86)
    item_picture.size = Vector2(176, 176)
    item_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    item_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    item_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(item_picture)
    action_icon = TextureRect.new()
    action_icon.position = Vector2(225, 83)
    action_icon.size = Vector2(67, 67)
    action_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    action_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    action_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(action_icon)
    explanation = shop.call("_text", panel, Vector2(296, 92), Vector2(417, 107), 19, Color("f5f3df")) as Label
    explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    # Visible quantities and three distinct pictograms reduce reliance on prose.
    for i in range(3):
        var icon_node := TextureRect.new()
        icon_node.position = Vector2(242 + i * 157, 213)
        icon_node.size = Vector2(35, 35)
        icon_node.texture = _icon(["cash","box","care"][i])
        icon_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
        panel.add_child(icon_node)
    # Three numeric boxes are anchored to their own pictograms.
    for i in range(3):
        var number_label: Label = shop.call("_text", panel, Vector2(281 + i * 157, 212), Vector2(108, 46), 23, Color("f3e8c5")) as Label
        number_label.autowrap_mode = TextServer.AUTOWRAP_OFF
        stat_labels.append(number_label)
    first = shop.call("_button", panel, "OPTION 1", Vector2(34, 294), Vector2(327, 111), Callable(self, "_choose").bind(0)) as Button
    second = shop.call("_button", panel, "OPTION 2", Vector2(388, 294), Vector2(327, 111), Callable(self, "_choose").bind(1)) as Button
    for control in [first, second]:
        control.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
        control.add_theme_constant_override("icon_max_width", 78)
        control.add_theme_constant_override("h_separation", 12)
        control.add_theme_font_size_override("font_size", 22)
        control.set_meta("ui_original_font_size", 22)
    # Consequences are shown as a LARGE ACTION PICTURE + LARGE NUMBER first.
    # Explanatory text is optional supporting context for readers.
    outcome_picture = TextureRect.new()
    outcome_picture.position = Vector2(293, 287)
    outcome_picture.size = Vector2(60, 60)
    outcome_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    outcome_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    outcome_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(outcome_picture)
    outcome_picture.visible = false
    outcome_number = shop.call("_text", panel, Vector2(365, 290), Vector2(130, 60), 39, Color("f5e0ac")) as Label
    outcome_number.autowrap_mode = TextServer.AUTOWRAP_OFF
    outcome_number.visible = false
    outcome = shop.call("_text", panel, Vector2(50, 358), Vector2(655, 78), 19, Color("f5e0ac")) as Label
    outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    outcome.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    outcome.visible = false
    done_button = shop.call("_button", panel, "BACK", Vector2(286, 448), Vector2(178, 52), Callable(self, "_close")) as Button
    done_button.icon = _icon("return")
    done_button.add_theme_constant_override("icon_max_width", 38)
    panel.visible = false

func reset_state() -> void:
    active_id = ""
    handled = false
    backroom_boxes = 0
    goodwill = 0
    outcome_summary = ""
    panel_choice_consumed = false
    speech_used = false
    if panel != null:
        panel.visible = false
    refresh_entry()

func new_day(day_number: int, sales: int) -> void:
    # Events are optional, at most one every third business day, never on day 1/2.
    active_id = ""
    handled = false
    outcome_summary = ""
    if day_number >= 3 and day_number % 3 == 0:
        var sequence_index: int = (int(day_number / 3) - 1) % CASES.size()
        active_id = str(CASES[sequence_index]["id"])
        if active_id == "textile_surplus":
            backroom_boxes = mini(MAX_BACKROOM, backroom_boxes + 2)
    refresh_entry()

func export_state() -> Dictionary:
    return {"active_id":active_id,"handled":handled,"boxes":backroom_boxes,
        "goodwill":goodwill,"outcome":outcome_summary}

func import_state(data: Variant, day_number: int, sales: int) -> void:
    if not (data is Dictionary) or (data as Dictionary).is_empty():
        # Backwards-compatible: older saves have no incident state.
        new_day(day_number, sales)
        return
    var state: Dictionary = data as Dictionary
    var candidate: String = str(state.get("active_id", ""))
    active_id = candidate if _find_case(candidate) >= 0 else ""
    handled = bool(state.get("handled", false))
    backroom_boxes = clampi(int(state.get("boxes", 0)), 0, MAX_BACKROOM)
    goodwill = clampi(int(state.get("goodwill", 0)), 0, MAX_GOODWILL)
    outcome_summary = str(state.get("outcome", "")).substr(0, 180)
    refresh_entry()

func _find_case(id: String) -> int:
    for i in range(CASES.size()):
        if str(CASES[i]["id"]) == id:
            return i
    return -1

func _current_case() -> Dictionary:
    var index: int = _find_case(active_id)
    if index >= 0 and not handled:
        return CASES[index]
    if backroom_boxes > 0:
        return {"id":"backroom_cleanup", "title":"CLEAR STORED BOXES", "sku":25,
            "picture":"box", "prompt":"Old boxes need space.\nYou can try a free rack or arrange reuse.",
            "options":[{"name":"FREE RACK", "icon":"rack", "hint":"Some clothes may be taken; no guaranteed result."},
                       {"name":"REUSE  $1", "icon":"sort", "hint":"Pay $1 to clear one old box through local reuse."}]}
    return {}

func refresh_entry() -> void:
    if entry_button == null:
        return
    var available: bool = not _current_case().is_empty()
    entry_button.disabled = not available
    entry_button.text = "SORT" if available else "SORT -"
    entry_button.tooltip_text = "Picture-first optional second-hand decision" if available else "No boxes or decisions waiting today"

func is_open() -> bool:
    return panel != null and panel.visible

func open() -> void:
    if shop == null or not bool(shop.get("playing")) or bool(shop.get("paused")) or _current_case().is_empty():
        return
    var desk: Panel = shop.get("desk_ui") as Panel
    if desk == null or not desk.visible:
        return
    desk.visible = false
    panel.visible = true
    panel_choice_consumed = false
    speech_used = false
    shop.call("_refresh_tutorial_ui")
    _refresh_panel()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    shop.call("_focus_menu_controls", panel)

func _refresh_panel() -> void:
    var entry: Dictionary = _current_case()
    if entry.is_empty():
        _close()
        return
    heading.text = str(entry["title"])
    explanation.text = str(entry["prompt"])
    # No subscription or online API. If an English OS voice is absent, icon
    # controls still work and the speaker is visibly unavailable.
    speech_button.disabled = DisplayServer.tts_get_voices_for_language("en").is_empty()
    item_picture.texture = load("res://assets/product_previews_v0162/product_%02d.png" % int(entry["sku"])) as Texture2D
    action_icon.texture = _icon(str(entry["picture"]))
    _refresh_stats()
    first.visible = true
    second.visible = true
    outcome.visible = false
    outcome_picture.visible = false
    outcome_number.visible = false
    var buttons: Array[Button] = [first, second]
    for i in range(2):
        var data: Dictionary = (entry["options"] as Array)[i]
        buttons[i].text = str(data["name"])
        buttons[i].icon = _icon(str(data["icon"]))
        buttons[i].tooltip_text = str(data["hint"])
        buttons[i].disabled = not _can_choose(str(entry["id"]), i)
    done_button.text = "BACK"

func _refresh_stats() -> void:
    if stat_labels.size() != 3:
        return
    stat_labels[0].text = "$%d" % int(shop.get("cash"))
    stat_labels[1].text = "%d/%d" % [backroom_boxes, MAX_BACKROOM]
    stat_labels[2].text = "%d/%d" % [goodwill, MAX_GOODWILL]

func _has_shelf_space(index: int) -> bool:
    return int(shop.call("_shelf_inventory_count", int(shop.call("_product_shelf", index)))) < 6

func _can_choose(case_id: String, option: int) -> bool:
    if option == 1 and case_id == "backroom_cleanup":
        return int(shop.get("cash")) >= 1
    if option != 0:
        return true
    if case_id == "appliance_check":
        return int(shop.get("cash")) >= 2 and _has_shelf_space(5)
    if case_id == "mixed_donation":
        return int(shop.get("cash")) >= 2 and _has_shelf_space(25)
    if case_id == "blocked_aisle":
        return int(shop.get("cash")) >= 1
    if case_id == "furniture_repair":
        return int(shop.get("cash")) >= 4 and _has_shelf_space(24)
    return true

func _charge(amount: int) -> void:
    shop.set("cash", int(shop.get("cash")) - amount)
    shop.set("day_cost", int(shop.get("day_cost")) + amount)

func _display_one(index: int) -> void:
    var inventory: Array = shop.get("stock")
    inventory[index] = int(inventory[index]) + 1
    shop.call("_refresh_shelf", int(shop.call("_product_shelf", index)))

func _try_free_rack() -> int:
    # Not a guaranteed outcome: some clothes may remain despite free pricing.
    var count: int = mini(backroom_boxes, posmod(int(shop.get("day")) + int(shop.get("total_sales")), 3))
    backroom_boxes -= count
    if count > 0:
        goodwill = mini(MAX_GOODWILL, goodwill + 1)
    return count

func _choose(option: int) -> void:
    # The result screen is a hard one-shot guard, even if backroom cleanup
    # becomes available immediately after resolving today\u0027s main incident.
    if panel_choice_consumed or not is_open():
        return
    var entry: Dictionary = _current_case()
    if entry.is_empty() or not _can_choose(str(entry["id"]), option):
        return
    var kind: String = str(entry["id"])
    var result: String = ""
    var old_cash: int = int(shop.get("cash"))
    var old_boxes: int = backroom_boxes
    var old_goodwill: int = goodwill
    match kind:
        "textile_surplus","backroom_cleanup":
            if option == 0:
                var taken: int = _try_free_rack()
                result = "%d box(es) taken. %d remain.\nFree does not always mean collected." % [taken, backroom_boxes]
            elif kind == "backroom_cleanup":
                _charge(1)
                backroom_boxes = maxi(0, backroom_boxes - 1)
                result = "1 box sent to reuse.\nCosts $1, no automatic sale."
            else:
                result = "Boxes kept safely.\nThey still occupy backroom space."
        "appliance_check":
            if option == 0:
                _charge(2)
                if int(shop.get("day")) % 2 == 0:
                    _display_one(5)
                    goodwill = mini(MAX_GOODWILL, goodwill + 1)
                    result = "Check passed. 1 tested appliance displayed."
                else:
                    backroom_boxes = mini(MAX_BACKROOM, backroom_boxes + 1)
                    result = "Check found a fault. Not for sale."
            else:
                backroom_boxes = mini(MAX_BACKROOM, backroom_boxes + 1)
                result = "Untested item stored. Nothing unsafe sold."
        "private_keepsake":
            if option == 0:
                goodwill = mini(MAX_GOODWILL, goodwill + 2)
                result = "Keepsake returned through a private process."
            else:
                backroom_boxes = mini(MAX_BACKROOM, backroom_boxes + 1)
                result = "Private item safely stored, not for sale."
        "missing_price":
            if option == 0:
                goodwill = mini(MAX_GOODWILL, goodwill + 1)
                result = "Price label checked before sale."
            else:
                backroom_boxes = mini(MAX_BACKROOM, backroom_boxes + 1)
                result = "Unpriced item moved off the shop floor."
        "mixed_donation":
            if option == 0:
                _charge(2)
                _display_one(25)
                goodwill = mini(MAX_GOODWILL, goodwill + 1)
                result = "1 usable clothes bundle sorted and displayed."
            else:
                result = "Unsorted batch politely declined."
        "blocked_aisle":
            if option == 0:
                _charge(1)
                goodwill = mini(MAX_GOODWILL, goodwill + 1)
                result = "Walkway cleared for everyone."
            else:
                goodwill = maxi(0, goodwill - 1)
                result = "Display remains awkward to reach."
        "furniture_repair":
            if option == 0:
                _charge(4)
                _display_one(24)
                goodwill = mini(MAX_GOODWILL, goodwill + 1)
                result = "1 repaired chair is ready for sale."
            else:
                backroom_boxes = maxi(0, backroom_boxes - 1)
                result = "Damaged item set aside for parts; not sold."
        _:
            return
    if kind != "backroom_cleanup":
        handled = true
    outcome_summary = result
    panel_choice_consumed = true
    _refresh_stats()
    first.visible = false
    second.visible = false
    explanation.text = "STORE RESULT"
    action_icon.texture = _icon("care" if goodwill > 0 else "check")
    outcome.text = result
    outcome.visible = true
    var change: int = 0
    var result_icon: String = str((entry["options"] as Array)[option]["icon"])
    if kind == "textile_surplus" or kind == "backroom_cleanup":
        change = abs(backroom_boxes - old_boxes)
        result_icon = "box"
    elif kind == "appliance_check" or kind == "mixed_donation" or kind == "furniture_repair":
        change = abs(int(shop.get("cash")) - old_cash)
        result_icon = "cash" if change > 0 else result_icon
    elif kind == "private_keepsake" or kind == "missing_price" or kind == "blocked_aisle":
        change = abs(goodwill - old_goodwill)
        result_icon = "care" if change > 0 else result_icon
    outcome_picture.texture = _icon(result_icon)
    outcome_number.text = str(change)
    outcome_number.tooltip_text = "This is the change in stored boxes, coins spent, or neighbour goodwill shown by the picture"
    outcome_picture.visible = true
    outcome_number.visible = true
    done_button.text = "CONTINUE"
    speech_button.tooltip_text = "Listen to the decision result"
    # Prevent repeat rewards across reloads; the existing safe-save path is used.
    shop.call("_save_game")
    shop.call("_refresh_ui")
    shop.call("_focus_menu_controls", panel, "CONTINUE")

func _close() -> void:
    if panel == null:
        return
    panel.visible = false
    panel_choice_consumed = false
    if speech_used and not bool(shop.get("qa_mode")):
        DisplayServer.tts_stop()
    speech_used = false
    if shop != null and bool(shop.get("playing")) and not bool(shop.get("paused")):
        (shop.get("desk_ui") as Panel).visible = true
        shop.call("_refresh_ui")
        shop.call("_refresh_tutorial_ui")
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        shop.call("_focus_menu_controls", shop.get("desk_ui"), "SORT")

func _speak_event() -> void:
    # Device-native speech helps players with limited reading. Do not claim
    # all languages or all devices have voices; the button disables if absent.
    if not is_open() or bool(shop.get("qa_mode")):
        return
    var voices: PackedStringArray = DisplayServer.tts_get_voices_for_language("en")
    if voices.is_empty():
        return
    var spoken: String = outcome_summary if panel_choice_consumed else (
        heading.text + ". " + explanation.text.replace("\n", " ") + ". " +
        "First choice: " + first.text + ". " + first.tooltip_text + ". " +
        "Second choice: " + second.text + ". " + second.tooltip_text
    )
    var volume: int = clampi(roundi(float(shop.get("master_volume")) * 75.0), 0, 100)
    DisplayServer.tts_speak(spoken, voices[0], volume, 1.0, 0.85, 0, true)
    speech_used = true

func visitor_interval_factor() -> float:
    # A small, capped positive effect—not a magical guaranteed sale.
    return 0.95 if goodwill >= 4 else 1.0
