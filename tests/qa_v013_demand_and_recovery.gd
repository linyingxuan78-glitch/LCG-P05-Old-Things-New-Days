extends SceneTree
## Run after importing Godot assets:
## godot --headless --path . --script res://tests/qa_v013_demand_and_recovery.gd
## Non-destructive: QA mode prevents gameplay save writes.

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, text: String, issues: Array[String]) -> void:
    if not ok:
        issues.append(text)

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("v0.13: cannot load main scene")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    shop.call("_new_game")
    var issues: Array[String] = []

    # Demand cycle is announced before a player buys stock.
    _check(int(shop.call("_featured_category")) == 0, "Day 1 must feature Vintage Tech", issues)
    _check(bool(shop.call("_is_featured_product", 0)), "Radio must belong to today's category", issues)
    _check(not bool(shop.call("_is_featured_product", 1)), "Books must not be hot on day 1", issues)
    # The on-screen forecast uses NEXT rather than the old TOMORROW label.
    _check(str(shop.call("_demand_message")).contains("NEXT: Home & Books"), "Demand forecast not visible", issues)
    shop.set("day", 2)
    _check(int(shop.call("_featured_category")) == 1, "Day 2 must feature Home & Books", issues)
    shop.set("day", 3)
    _check(int(shop.call("_featured_category")) == 2, "Day 3 must feature Kitchen Finds", issues)
    shop.set("day", 4)
    _check(int(shop.call("_featured_category")) == 3, "Day 4 introduces Clothes & Travel", issues)
    shop.set("day", 5)
    _check(int(shop.call("_featured_category")) == 4, "Day 5 features Toys & Collectibles", issues)
    shop.set("day", 6)
    _check(int(shop.call("_featured_category")) == 5, "Day 6 features Small Furniture", issues)
    shop.set("day", 7)
    _check(int(shop.call("_featured_category")) == 0, "Six-category demand cycle must repeat", issues)

    # A hot-category sale must appear in the daily report/ledger.
    shop.call("_new_game")
    shop.call("_buy_product", 0)
    shop.call("_stock_from_desk", 0)
    shop.set("customer_target", 0)
    shop.set("customer_budget", 100)
    shop.call("_complete_sale")
    _check(int(shop.get("cash")) == 91, "Radio sale accounting changed", issues)
    _check(int(shop.get("day_hot_sales")) == 1, "Hot-category sales counter missing", issues)
    shop.call("_finish_day")
    var history: Array = shop.get("daily_history")
    _check(history.size() == 1, "One completed day should produce one ledger entry", issues)
    if history.size() == 1:
        _check(int((history[0] as Dictionary).get("hot_sales", 0)) == 1, "Featured sales not written to ledger", issues)
        _check(str((history[0] as Dictionary).get("trend", "")) == "Vintage Tech", "Demand label missing in ledger", issues)
    shop.call("_close_report")
    _check(int(shop.get("day")) == 2, "Next day did not start", issues)
    _check(int(shop.get("day_hot_sales")) == 0, "Hot sale counter not cleared", issues)

    # Corrupted save files must never deserialize as valid gameplay data.
    var qa_file: String = "user://lcg_p05_v013_corrupt_test.json"
    var f: FileAccess = FileAccess.open(qa_file, FileAccess.WRITE)
    if f == null:
        issues.append("QA temp file could not be created")
    else:
        f.store_string("{bad json")
        f.close()
        var bad_data: Dictionary = shop.call("_read_save_data", qa_file)
        _check(bad_data.is_empty(), "Malformed JSON was accepted", issues)
        DirAccess.remove_absolute(ProjectSettings.globalize_path(qa_file))

    # The important recovery condition is *one* step forward after the
    # last saved ledger record, not a second close-day event or duplicate reward.
    shop.set("day", 1)
    var advanced: bool = shop.call("_resume_after_saved_day")
    _check(advanced, "Closed day not detected on resume", issues)
    _check(int(shop.get("day")) == 2, "Rollover helper broken", issues)
    _check((shop.get("daily_history") as Array).size() == 1, "Rollover duplicated a day", issues)
    var advanced_again: bool = shop.call("_resume_after_saved_day")
    _check(not advanced_again, "Closed day was advanced twice", issues)
    _check(int(shop.get("day")) == 2, "Second resume changed the day", issues)

    if issues.is_empty():
        print("v0.13 QA PASS: demand cycle, hot sales, cash accounting, ledger and rollover")
        quit(0)
    else:
        for issue in issues:
            push_error("v0.13 QA FAILURE: " + issue)
        quit(1)
