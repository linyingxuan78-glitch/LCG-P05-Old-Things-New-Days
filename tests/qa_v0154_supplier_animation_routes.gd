extends SceneTree
## Run with official Godot 4.4 after importing GLB assets:
## godot --headless --path . --script res://tests/qa_v0154_supplier_animation_routes.gd
## Tests engine behavior; QA mode prevents overwriting real player saves.

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("QA 0154 FAILED: main scene unavailable")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    shop.call("_new_game")
    var issues: Array[String] = []
    var supplier: Array = shop.get("supplier_remaining")
    if supplier.size() != 27 or int(supplier[0]) != 8:
        issues.append("Day 1 supplier quota must initialize for all 27 products")
    shop.set("cash", 999)
    for i in range(8):
        shop.call("_buy_product", 0)
        if int(shop.get("carrying")) != 0:
            issues.append("Base product purchase %d failed unexpectedly" % i)
            break
        shop.call("_stock_from_desk", 0)
        # Free display capacity for this deterministic supplier-quantity test.
        var inv: Array = shop.get("stock")
        inv[0] = 0
        shop.set("stock", inv)
    supplier = shop.get("supplier_remaining")
    if int(supplier[0]) != 0:
        issues.append("After eight purchases today's offer must be empty")
    var cash_before: int = int(shop.get("cash"))
    shop.call("_buy_product", 0)
    if int(shop.get("cash")) != cash_before or int(shop.get("carrying")) != -1:
        issues.append("Ninth same-day purchase must be rejected without charging")
    shop.call("_advance_day")
    supplier = shop.get("supplier_remaining")
    if int(supplier[0]) != 8:
        issues.append("Offers should replenish on the NEXT day only")
    for i in range(9, 27):
        if int(supplier[i]) > 2 or int(supplier[i]) < 1:
            issues.append("Curated used item has an implausible daily supplier quantity")
            break
    # Verify the fixed special route avoids the front-left coffee table.
    shop.set("customer_target", 5)
    shop.call("_spawn_customer")
    shop.set("customer_target", 5)
    shop.call("_route_customer_to_shelf")
    var route: Array = shop.get("customer_route")
    if route.size() != 4 or (route[2] as Vector3).distance_to(Vector3(-4.9,0,2.0)) > 0.05:
        issues.append("Front-left customer aisle route is missing a table detour")
    shop.call("_dismiss_customer")
    # Every bundled character should have the animation clips we request.
    for path in [
        "res://assets/models/character-male-a.glb",
        "res://assets/models/character-female-a.glb",
        "res://assets/models/character-female-c.glb",
        "res://assets/selected_v015/characters/character-male-b.glb",
        "res://assets/selected_v015/characters/character-female-b.glb",
        "res://assets/selected_v015/characters/character-female-d.glb"
    ]:
        var resource: PackedScene = load(path) as PackedScene
        if resource == null:
            issues.append("Character could not import: " + path)
            continue
        var actor: Node = resource.instantiate()
        shop.add_child(actor)
        var player: AnimationPlayer = shop.call("_find_customer_animation_player", actor) as AnimationPlayer
        if player == null:
            issues.append("Missing AnimationPlayer: " + path)
        else:
            shop.set("customer_animation_player", player)
            shop.set("customer_animation_state", "")
            for clip_name in ["walk","idle","interact-right","interact-left","pick-up","emote-no"]:
                var matched: String = str(shop.call("_customer_animation_name",clip_name))
                if matched.is_empty():
                    issues.append("Missing " + clip_name + " in " + path)
            shop.call("_play_customer_animation", "walk")
            var walk: String = str(shop.call("_customer_animation_name", "walk"))
            if walk != "" and player.get_animation(walk).loop_mode != Animation.LOOP_LINEAR:
                issues.append("Walk clip must loop without frame resets: " + path)
            shop.call("_play_customer_animation", "interact-right")
            if str(shop.get("customer_animation_state")) != "interact-right":
                issues.append("Gesture should replace walk without repeated restarting: " + path)
        actor.queue_free()
    shop.set("customer_animation_player", null)
    if issues.is_empty():
        print("QA 0154 PASSED: bounded daily offers, next-day reset, aisle detour, six imported animated shoppers")
        quit(0)
    else:
        for issue in issues:
            push_error("QA 0154 FAILED: " + issue)
        quit(1)
