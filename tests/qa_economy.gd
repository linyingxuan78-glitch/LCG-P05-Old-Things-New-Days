extends SceneTree
## Run: godot --headless --path . --script res://tests/qa_economy.gd
## All save operations are disabled via qa_mode. Never touches user save files.

func _initialize() -> void:
    call_deferred("_run")

func _expect(actual: Variant, expected: Variant, title: String, failures: Array[String]) -> void:
    if actual != expected:
        failures.append("%s: expected %s got %s" % [title, str(expected), str(actual)])

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA: cannot load main.tscn")
        quit(1)
        return
    var shop: Node = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    var failures: Array[String] = []

    # Single unit order -> carry -> shelf, with correct accounting.
    shop.call("_new_game")
    _expect(shop.get("cash"), 80, "initial cash", failures)
    shop.call("_buy_product", 0)
    _expect(shop.get("cash"), 73, "single purchase", failures)
    _expect(shop.get("carrying"), 0, "hand holds radio", failures)
    shop.call("_stock_from_desk", 0)
    _expect((shop.get("stock") as Array)[0], 1, "shelf stocked", failures)
    _expect(shop.get("carrying"), -1, "hand clear after stocking", failures)

    # Repricing must update real in-world price label; deterministic sale.
    shop.call("_change_price", 0, 2)
    _expect((shop.get("prices") as Array)[0], 20, "repricing", failures)
    var tags: Array = shop.get("price_tags")
    if tags.size() == 9:
        _expect((tags[0] as Label3D).text, "$20   |   1/6", "3D price sign", failures)
    else:
        failures.append("Expected nine 3D price signs")
    shop.set("customer_target", 0)
    shop.set("customer_budget", 50)
    shop.call("_complete_sale")
    _expect(shop.get("cash"), 93, "sale payout", failures)
    _expect((shop.get("stock") as Array)[0], 0, "sale decreases stock", failures)
    _expect(shop.get("total_sales"), 1, "sale counter", failures)

    # Customers above price budget leave without charge.
    shop.call("_buy_product", 0)
    shop.call("_stock_from_desk", 0)
    shop.set("customer_target", 0)
    shop.set("customer_budget", 5)
    var cash_before: int = shop.get("cash")
    shop.call("_complete_sale")
    _expect(shop.get("cash"), cash_before, "budget refusal no payout", failures)
    _expect(shop.get("day_over_budget"), 1, "budget refusal report", failures)

    # Bulk orders are gated and discounted, with a capacity ceiling.
    shop.set("total_sales", 3)
    shop.set("carrying", -1)
    var stock_data: Array = shop.get("stock")
    stock_data[0] = 0
    shop.set("stock", stock_data)
    shop.set("cash", 100)
    shop.call("_buy_bulk", 0)
    _expect(shop.get("cash"), 81, "discounted 3 pack ($19)", failures)
    _expect((shop.get("stock") as Array)[0], 3, "3 pack shelf inventory", failures)
    shop.call("_buy_bulk", 0)
    _expect((shop.get("stock") as Array)[0], 6, "shelf capacity", failures)
    var cap_cash: int = shop.get("cash")
    shop.call("_buy_bulk", 0)
    _expect(shop.get("cash"), cap_cash, "overcapacity order rejected", failures)

    # One-time daily target payout even if the report function is called twice.
    shop.set("day_sales", 2)
    shop.set("day_visitors", 3)
    shop.call("_finish_day")
    var after_goal: int = shop.get("cash")
    _expect(shop.get("day_goal_awarded"), true, "goal paid", failures)
    _expect(shop.get("total_goal_rewards"), 10, "day 1 reward ($10)", failures)
    shop.call("_finish_day")
    _expect(shop.get("cash"), after_goal, "reward paid only once", failures)
    shop.call("_close_report")
    _expect(shop.get("day"), 2, "day rolls over", failures)
    _expect(shop.get("day_sales"), 0, "daily sales reset", failures)

    # Do not terminate SceneTree while the test still owns the instantiated shop.
    # Release scene and loaded resources before asking Godot to exit.
    root.remove_child(shop)
    shop.free()
    shop = null
    scene = null
    await process_frame

    if failures.size() > 0:
        for failure in failures:
            push_error("QA FAILED: " + failure)
        quit(1)
    else:
        print("QA ECONOMY PASSED: inventory, prices, sales, refusals, bulk orders, daily reward.")
        quit(0)
