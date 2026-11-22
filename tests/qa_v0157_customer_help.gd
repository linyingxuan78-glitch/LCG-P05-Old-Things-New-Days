extends SceneTree
## Native Godot QA: no forced modal, safe substitute, no phantom sales.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("QA CUSTOMER HELP 0157 FAILED: scene missing")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    shop.call("_new_game")
    var failures: Array[String] = []
    # Real catalog: book set index 1 and table lamp index 2 share category 1.
    var inventory: Array = shop.get("stock")
    inventory[2] = 1
    shop.set("stock", inventory)
    shop.call("_spawn_customer")
    shop.set("customer_target", 1)
    shop.set("customer_budget", 40)
    var customer: Node3D = shop.get("customer")
    var player: CharacterBody3D = shop.get("player")
    customer.global_position = player.global_position
    shop.set("customer_phase", "needs_help")
    if int(shop.call("_find_customer_alternative")) != 2:
        failures.append("Did not find a real in-stock same-category substitute")
    var before_cash: int = int(shop.get("cash"))
    shop.call("_assist_customer")
    if int(shop.get("customer_target")) != 2 or str(shop.get("customer_phase")) != "enter":
        failures.append("Shopper was not routed to the alternative item")
    if int(shop.get("total_assisted_shoppers")) != 1:
        failures.append("Assistance was not recorded once")
    if int(shop.get("cash")) != before_cash:
        failures.append("Assisting a shopper should not charge cash automatically")
    shop.call("_assist_customer")
    if int(shop.get("total_assisted_shoppers")) != 1:
        failures.append("Multiple presses duplicated a help action")
    shop.set("customer_target", 1)
    shop.set("customer_phase", "needs_help")
    inventory = shop.get("stock")
    inventory[2] = 0
    shop.set("stock", inventory)
    shop.call("_assist_customer")
    if int(shop.get("total_assisted_shoppers")) != 1 or int(shop.get("cash")) != before_cash:
        failures.append("An unavailable substitute caused a phantom transaction")
    if failures.is_empty():
        print("QA CUSTOMER HELP 0157 PASSED: in-person optional assistance, in-stock substitutions, no duplicate offers or unwanted charges")
        quit(0)
    else:
        for failure in failures:
            push_error("QA CUSTOMER HELP 0157 FAILED: " + failure)
        quit(1)
