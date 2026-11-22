extends SceneTree
## To run after importing assets:
## godot --headless --path . --script res://tests/qa_customer_flow.gd
## QA mode prevents writes to the player's saved game.

func _initialize() -> void:
    call_deferred("_run")

func _assert_true(condition: bool, reason: String, failures: Array[String]) -> void:
    if not condition:
        failures.append(reason)

func _drain_route(shop: Node, max_steps: int = 900) -> Array[String]:
    var visited_phases: Array[String] = []
    for _i in range(max_steps):
        var phase: String = str(shop.get("customer_phase"))
        if not visited_phases.has(phase):
            visited_phases.append(phase)
        if phase == "idle":
            break
        shop.call("_update_customer", 0.10)
    return visited_phases

func _set_up_visitor(shop: Node, index: int, budget: int) -> void:
    shop.call("_spawn_customer")
    shop.set("customer_target", index)
    shop.set("customer_budget", budget)
    shop.call("_route_customer_to_shelf")

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("QA CUSTOMER FAILED: main scene missing")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    var failures: Array[String] = []

    # Happy path: a sale must happen at checkout rather than on the shelf.
    shop.call("_new_game")
    shop.call("_buy_product", 0)
    shop.call("_stock_from_desk", 0)
    _set_up_visitor(shop, 0, 100)
    var phases: Array[String] = _drain_route(shop)
    _assert_true(phases.has("enter"), "Missing walk-in state", failures)
    _assert_true(phases.has("browse"), "Missing shelf browse state", failures)
    _assert_true(phases.has("checkout"), "Missing travel-to-checkout state", failures)
    _assert_true(phases.has("pay"), "Missing checkout payment state", failures)
    _assert_true(phases.has("exit"), "Missing leave-shop state", failures)
    _assert_true(shop.get("customer_phase") == "idle", "Shopper did not leave", failures)
    _assert_true(int(shop.get("total_sales")) == 1, "Paid sale missing", failures)
    _assert_true(int(shop.get("cash")) == 91, "Expected $80-$7+$18=$91", failures)

    # Missing stock: visitor leaves without a sale or charge.
    shop.call("_new_game")
    _set_up_visitor(shop, 0, 100)
    var rejected: Array[String] = _drain_route(shop)
    _assert_true(not rejected.has("checkout"), "Out-of-stock visitor should not pay", failures)
    _assert_true(int(shop.get("day_no_stock")) == 1, "Missing out-of-stock feedback", failures)
    _assert_true(int(shop.get("cash")) == 80, "Empty shelf incorrectly paid", failures)

    # Too expensive: visitor must not enter checkout.
    shop.call("_new_game")
    shop.call("_buy_product", 0)
    shop.call("_stock_from_desk", 0)
    _set_up_visitor(shop, 0, 1)
    rejected = _drain_route(shop)
    _assert_true(not rejected.has("checkout"), "Over-budget visitor should not pay", failures)
    _assert_true(int(shop.get("day_over_budget")) == 1, "Missing price feedback", failures)
    _assert_true(int(shop.get("cash")) == 73, "Over-budget visitor incorrectly paid", failures)

    # Closing while a visitor is browsing should safely clear their visual and state.
    shop.call("_new_game")
    _set_up_visitor(shop, 0, 100)
    shop.call("_finish_day")
    _assert_true(shop.get("customer_phase") == "idle", "Customer survives closing", failures)
    _assert_true(shop.get("customer") == null, "Stale customer node after closing", failures)
    _assert_true(int(shop.get("day_unserved_at_close")) == 1, "Closing visitor not counted", failures)
    shop.call("_close_report")
    _assert_true(int(shop.get("day_unserved_at_close")) == 0, "Closing stats not reset", failures)

    if failures.size() > 0:
        for failure in failures:
            push_error("QA CUSTOMER FAILED: " + failure)
        quit(1)
    else:
        print("QA CUSTOMER PASSED: aisle route, browsing, register payment, refusals, day closing.")
        quit(0)
