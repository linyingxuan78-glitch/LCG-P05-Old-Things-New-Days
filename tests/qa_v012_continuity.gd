extends SceneTree
## Godot 4.4+: import assets first, then:
## godot --headless --path . --script res://tests/qa_v012_continuity.gd
## WARNING: QA mode suppresses game-save writes; no real player progress is overwritten.

func _initialize() -> void:
    call_deferred("_run")

func _expect(actual: Variant, expected: Variant, context: String, problems: Array[String]) -> void:
    if actual != expected:
        problems.append("%s: expected=%s, actual=%s" % [context, str(expected), str(actual)])

func _run() -> void:
    var main: PackedScene = load("res://main.tscn") as PackedScene
    if main == null:
        push_error("v0.12 test: main scene not loaded")
        quit(1)
        return
    var shop: Node = main.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    var problems: Array[String] = []

    # Old saves have no consignment_stock or history. New-game defaults must be intact.
    shop.call("_new_game")
    var initial_liabilities: Array = shop.get("consignment_stock")
    _expect(initial_liabilities.size(), 9, "consignment array size", problems)
    _expect((shop.get("daily_history") as Array).size(), 0, "clean ledger", problems)

    # At zero cash and no inventory the player must not be trapped permanently.
    shop.set("cash", 0)
    shop.call("_request_consignment")
    _expect(shop.get("cash"), 0, "consignment no upfront charge", problems)
    _expect((shop.get("stock") as Array)[1], 1, "consignment stock booked", problems)
    _expect((shop.get("consignment_stock") as Array)[1], 1, "supplier ownership tracked", problems)
    shop.call("_request_consignment")
    _expect((shop.get("stock") as Array)[1], 1, "no second consignment while stock remains", problems)

    # Supplier-funded stock cannot be repriced below wholesale settlement.
    for _step in range(8):
        shop.call("_change_price", 1, -1)
    shop.call("_change_price", 1, -1)
    _expect((shop.get("prices") as Array)[1], 6, "minimum payable price", problems)
    shop.set("customer_target", 1)
    shop.set("customer_budget", 100)
    shop.call("_complete_sale")
    _expect(shop.get("cash"), 1, "cash after $6 sale and $5 settlement", problems)
    _expect(shop.get("day_revenue"), 6, "full sale revenue", problems)
    _expect(shop.get("day_cost"), 5, "supplier fee recorded on sale", problems)
    _expect((shop.get("consignment_stock") as Array)[1], 0, "supplier unit cleared", problems)
    _expect(shop.get("total_consignment_paid"), 5, "lifetime supplier settlement", problems)

    # Daily ledger is recorded once and retained after the next day begins.
    shop.call("_finish_day")
    _expect((shop.get("daily_history") as Array).size(), 1, "one closed-day record", problems)
    var record: Dictionary = (shop.get("daily_history") as Array)[0]
    _expect(int(record.get("cash_change", 0)), 1, "day's net cash movement", problems)
    shop.call("_finish_day")
    _expect((shop.get("daily_history") as Array).size(), 1, "no duplicated daily record", problems)
    shop.call("_close_report")
    _expect(shop.get("day"), 2, "business day increases", problems)
    _expect((shop.get("daily_history") as Array).size(), 1, "ledger persists across days", problems)

    # Pressing pause must freeze gameplay and permit audio settings to return correctly.
    shop.call("_open_pause")
    _expect(shop.get("paused"), true, "pause enabled", problems)
    shop.call("_open_settings_menu")
    _expect(shop.get("settings_source"), "pause", "settings remembers pause origin", problems)
    shop.call("_close_settings")
    var pause_panel: Panel = shop.get("pause_ui")
    _expect(pause_panel.visible, true, "return to pause panel", problems)
    shop.call("_resume_pause")
    _expect(shop.get("paused"), false, "pause released", problems)

    if problems.is_empty():
        print("v0.12 CONTINUITY PASS: cash rescue, supplier settlement, ledger and pause routing")
        quit(0)
    else:
        for problem in problems:
            push_error("v0.12 CONTINUITY FAILURE: " + problem)
        quit(1)
