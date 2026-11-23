extends SceneTree
## Godot 4.4 headless QA, not a substitute for visual usability / photosensitivity testing.
## Run after actual Godot import: godot --headless --path . --script res://tests/qa_v0156_events_and_usability.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("QA 0156 FAILED: Could not import the main scene")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true) # Never write a player's save while testing.
    shop.call("_new_game")
    var issues: Array[String] = []
    if str(shop.get("day_event_id")) != "none":
        issues.append("Tutorial day must start without surprise events")
    if (shop.get("pictogram_icons") as Array).size() != 4:
        issues.append("Four picture cues must be present")
    for i in range(4):
        var icon: TextureRect = (shop.get("pictogram_icons") as Array)[i]
        if icon.texture == null:
            issues.append("Picture cue %d has a missing texture" % i)
    var initial_icon_state: bool = bool(shop.get("picture_guides"))
    shop.call("_toggle_accessibility", 3)
    if bool(shop.get("picture_guides")) == initial_icon_state:
        issues.append("Picture cue preference did not toggle")
    shop.call("_toggle_accessibility", 3)
    shop.call("_toggle_accessibility", 4)
    if not bool(shop.get("compact_hud")) or (shop.get("hud_help_panel") as Panel).visible:
        issues.append("Compact HUD did not hide the long help strip")
    shop.call("_toggle_accessibility", 4)
    shop.call("_advance_day")
    if str(shop.get("day_event_id")) != "none":
        issues.append("Second day should not force a surprise event")
    # An opt-in visitor negotiation is only offered once per day.
    shop.set("customer_target", 0)
    shop.set("customer_budget", 10)
    var inventory: Array = shop.get("stock")
    inventory[0] = 1
    shop.set("stock", inventory)
    var prices: Array = shop.get("prices")
    prices[0] = 12
    shop.set("prices", prices)
    if not bool(shop.call("_can_offer_bargain")):
        issues.append("A small price difference should allow one polite offer")
    var old_cash: int = int(shop.get("cash"))
    shop.call("_open_customer_bargain")
    if not (shop.get("customer_bargain_ui") as Panel).visible or str(shop.get("customer_phase")) != "negotiating":
        issues.append("Customer offer did not open and pause the visit")
    shop.call("_accept_customer_bargain")
    if int(shop.get("customer_agreed_price")) != 10:
        issues.append("Accepted price did not match the visitor's offer")
    shop.call("_complete_sale")
    if int(shop.get("cash")) != old_cash + 10 or int(shop.get("day_revenue")) != 10 or int((shop.get("stock") as Array)[0]) != 0:
        issues.append("Discounted sale did not update cash, revenue and stock consistently")
    if int(shop.get("day_bargain_offers")) != 1 or int(shop.get("day_bargain_accepted")) != 1:
        issues.append("Negotiation counters are incorrect")
    if bool(shop.call("_can_offer_bargain")):
        issues.append("A second negotiation should not be allowed on the same day")
    shop.call("_dismiss_customer")
    # Check at least 80 days for event throttling; actual distribution remains random.
    var previous_event_day: int = -100
    var event_count: int = 0
    for i in range(80):
        shop.call("_advance_day")
        var current_event: String = str(shop.get("day_event_id"))
        if current_event != "none":
            event_count += 1
            if int(shop.get("day")) - previous_event_day < 3:
                issues.append("Too-frequent event days")
            previous_event_day = int(shop.get("day"))
            if current_event not in ["rain","delivery_delay","neighbour_tip","donation_day"]:
                issues.append("Unexpected event identifier")
    if event_count > 27:
        issues.append("More events than the hard cooldown allows")
    # Multiple people may share one style, but never consecutive copies by default.
    shop.call("_new_game")
    var prev_appearance: int = -1
    for i in range(14):
        shop.call("_spawn_customer")
        var current_appearance: int = int(shop.get("last_customer_appearance"))
        if current_appearance == prev_appearance:
            issues.append("Identical visitor model spawned back-to-back")
        prev_appearance = current_appearance
        shop.call("_dismiss_customer")
    # New picture-first store decisions share the old economy and safe-save path.
    # A scenario is optional; no forced modal or long story text interrupts day 1.
    shop.call("_new_game")
    var sorter: Control = shop.get("secondhand_events") as Control
    if sorter == null:
        issues.append("Optional sorting and free-rack module missing")
    else:
        var start_state: Dictionary = sorter.call("export_state")
        if str(start_state.get("active_id", "")) != "" or int(start_state.get("boxes", 0)) != 0:
            issues.append("Tutorial must begin without donation events")
        shop.call("_advance_day")  # Day 2: remain calm.
        if str((sorter.call("export_state") as Dictionary).get("active_id", "")) != "":
            issues.append("First two days must not force a sorting event")
        shop.call("_advance_day")  # Day 3: first optional scenario.
        var event_state: Dictionary = sorter.call("export_state")
        if str(event_state.get("active_id", "")) != "textile_surplus" or int(event_state.get("boxes", 0)) != 2:
            issues.append("Day 3 must offer the optional overflow/free-rack problem")
        shop.call("_toggle_desk")
        sorter.call("open")
        if not bool(sorter.call("is_open")):
            issues.append("Picture-first sorting panel cannot open from shop desk")
        else:
            if (sorter.get("item_picture") as TextureRect).texture == null or (sorter.get("action_icon") as TextureRect).texture == null:
                issues.append("Sorting panel lacks recognizable item and action pictures")
            if (sorter.get("first") as Button).icon == null or (sorter.get("second") as Button).icon == null:
                issues.append("Decision buttons need original, action-specific pictograms")
            var speaker: Button = sorter.get("speech_button") as Button
            if speaker == null or speaker.icon == null:
                issues.append("Optional listening icon must be visible for players who prefer voice")
            if speaker != null and speaker.disabled != DisplayServer.tts_get_voices_for_language("en").is_empty():
                issues.append("Optional English system speech must disable when no voice is installed")
            var stat_boxes: Array = sorter.get("stat_labels")
            if stat_boxes.size() != 3:
                issues.append("Money, storage, and goodwill need three separate symbol-aligned counters")
            else:
                for stat_index in range(3):
                    var field: Label = stat_boxes[stat_index] as Label
                    if field == null or field.position.x < 270 or field.position.x > 630:
                        issues.append("Decision counters are not aligned with their distinct pictograms")
                    elif field.size.x > 120:
                        issues.append("A long counter could overlap the next pictogram")
            if root.gui_get_focus_owner() == null:
                issues.append("Sorting panel needs keyboard focus for non-mouse users")
        sorter.call("_choose", 0)
        var after_choice: Dictionary = sorter.call("export_state")
        if not bool(after_choice.get("handled", false)):
            issues.append("Sorting decision should be marked resolved before saving")
        if not (sorter.get("outcome") as Label).visible or not (sorter.get("done_button") as Button).visible:
            issues.append("Sorting consequence must be shown in a persistent, visible result panel")
        var original_boxes: int = int(after_choice.get("boxes", 0))
        var original_goodwill: int = int(after_choice.get("goodwill", 0))
        sorter.call("_choose", 0)
        var twice: Dictionary = sorter.call("export_state")
        if int(twice.get("boxes", 0)) != original_boxes or int(twice.get("goodwill", 0)) != original_goodwill:
            issues.append("One event must not reward the same choice twice")
        sorter.call("import_state", after_choice, int(shop.get("day")), int(shop.get("total_sales")))
        var restored: Dictionary = sorter.call("export_state")
        if restored != after_choice:
            issues.append("Sorting outcome was not restored by save-data import")
        sorter.call("_close")
        if not (shop.get("desk_ui") as Panel).visible:
            issues.append("Closing optional incident should return to the shop desk")
        # Unpriced and keepsake cases should never sell a privately owned or unchecked item.
        for index in range(1, 7):
            shop.call("_advance_day")
        var current_event: Dictionary = sorter.call("export_state")
        if int(current_event.get("goodwill", 0)) < 0 or int(current_event.get("goodwill", 0)) > 12:
            issues.append("Goodwill should be bounded")
        if int(current_event.get("boxes", 0)) < 0 or int(current_event.get("boxes", 0)) > 8:
            issues.append("Backroom must never exceed physical storage limit")
    # Existing 23 native QA suites remain unchanged in number.
    if issues.is_empty():
        print("QA 0156 PASSED: picture HUD preferences, low-frequency events, visitor negotiation and stock accounting, and varied adjacent character appearances")
        quit(0)
    else:
        for issue in issues:
            push_error("QA 0156 FAILED: " + issue)
        quit(1)
