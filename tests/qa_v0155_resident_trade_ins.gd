extends SceneTree
## Godot 4.4 headless logic QA; does NOT overwrite the player's real save.
## Run after asset import with: godot --headless --path . --script res://tests/qa_v0155_resident_trade_ins.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("QA 0155 FAILED: main scene could not load")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    shop.call("_new_game")
    var issues: Array[String] = []
    if int(shop.get("resident_offer_index")) != -1:
        issues.append("Day 1 must be an introduction day without a local offer")
    shop.call("_advance_day")
    var index: int = int(shop.get("resident_offer_index"))
    var cost: int = int(shop.get("resident_offer_cost"))
    if index < 0 or index >= 27:
        issues.append("Day 2 offer SKU is invalid")
    if cost < 1:
        issues.append("Resident trade-in price must be positive")
    if not bool(shop.call("_resident_offer_available")):
        issues.append("Day 2 should have one available local offer")
    if not issues.is_empty():
        for issue in issues:
            push_error("QA 0155 FAILED: " + issue)
        quit(1)
        return
    if cost > int(shop.call("_supplier_cost", index)):
        issues.append("Resident asking price exceeds local supplier cost")
    var before_quota: Array = (shop.get("supplier_remaining") as Array).duplicate()
    shop.set("cash", 0)
    shop.call("_accept_resident_offer")
    if int(shop.get("carrying")) != -1 or int(shop.get("cash")) != 0:
        issues.append("Insufficient funds must not acquire goods or debit cash")
    shop.set("cash", 200)
    shop.set("carrying", 0)
    shop.call("_accept_resident_offer")
    if int(shop.get("carrying")) != 0 or int(shop.get("cash")) != 200:
        issues.append("Already carrying a purchase should reject a second purchase")
    shop.set("carrying", -1)
    var slot: int = int(shop.call("_product_shelf", index))
    var inventory: Array = shop.get("stock")
    inventory[slot] = 6
    shop.set("stock", inventory)
    shop.call("_accept_resident_offer")
    if int(shop.get("carrying")) != -1 or int(shop.get("cash")) != 200:
        issues.append("Full shared display must reject the purchase")
    inventory[slot] = 0
    shop.set("stock", inventory)
    shop.call("_open_resident_offer")
    if not (shop.get("resident_offer_ui") as Panel).visible:
        issues.append("Local offer modal must open from the store desk")
    var old_cost: int = int(shop.get("day_cost"))
    shop.call("_accept_resident_offer")
    if int(shop.get("carrying")) != index or int(shop.get("cash")) != 200 - cost:
        issues.append("Accepted trade-in did not charge and give the right carried item")
    if int(shop.get("day_cost")) != old_cost + cost:
        issues.append("Trade-in spending was not included in the daily cash movement")
    if int(shop.get("resident_purchases_total")) != 1 or int(shop.get("resident_purchase_spending")) != cost:
        issues.append("Resident purchase totals did not update")
    if (shop.get("supplier_remaining") as Array) != before_quota:
        issues.append("Resident trades must not reduce the unrelated supplier quota")
    if bool(shop.call("_resident_offer_available")):
        issues.append("Resident offer remained available after acceptance")
    var settled_cash: int = int(shop.get("cash"))
    shop.call("_accept_resident_offer")
    if int(shop.get("cash")) != settled_cash:
        issues.append("Accepted trade-in can be charged again")
    shop.call("_stock_from_desk", index)
    if int((shop.get("stock") as Array)[index]) != 1 or int(shop.get("carrying")) != -1:
        issues.append("Purchased trade-in cannot use the standard stock-shelf flow")
    shop.call("_advance_day")
    if not bool(shop.call("_resident_offer_available")):
        issues.append("New business day must have a fresh offer")
    var cash_before_decline: int = int(shop.get("cash"))
    shop.call("_decline_resident_offer")
    if bool(shop.call("_resident_offer_available")) or int(shop.get("cash")) != cash_before_decline:
        issues.append("Declining must end the day's offer without any charge")
    if issues.is_empty():
        print("QA 0155 PASSED: resident offers, insufficient cash, carrying, display capacity, single acceptance, daily reset, standard stocking, and decline")
        quit(0)
    else:
        for issue in issues:
            push_error("QA 0155 FAILED: " + issue)
        quit(1)
