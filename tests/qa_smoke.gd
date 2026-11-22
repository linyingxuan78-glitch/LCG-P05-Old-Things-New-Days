extends SceneTree
## Run after import: godot --headless --path . --script res://tests/qa_smoke.gd
## Non-destructive: verifies scene initialization and shipped resources only.

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA FAILED: Could not load main.tscn")
        quit(1)
        return
    var shop: Node = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    var errors: Array[String] = []
    var shelves: Array = shop.get("shelves")
    var stocks: Array = shop.get("stock")
    var product_visuals: Array = shop.get("product_visuals")
    if shelves.size() != 9:
        errors.append("Expected 9 physical shelves")
    if stocks.size() != 27:
        errors.append("Expected 27 sellable SKU inventory entries")
    var price_tags: Array = shop.get("price_tags")
    if price_tags.size() != 9:
        errors.append("Expected 9 visible price labels")
    if product_visuals.size() != 9:
        errors.append("Expected 9 model display holders")
    if not ResourceLoader.exists("res://assets/branding/lcg_logo.png"):
        errors.append("Studio logo missing")
    if not ResourceLoader.exists("res://assets/audio/Swinging Sweet.ogg"):
        errors.append("CC0 BGM missing")
    if errors.size() > 0:
        for problem in errors:
            push_error("QA FAILED: " + problem)
        quit(1)
    else:
        print("QA SMOKE PASSED: Godot scene initialized; nine shelves, price signs and required assets found.")
        quit(0)
