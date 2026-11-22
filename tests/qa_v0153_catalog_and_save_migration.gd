extends SceneTree
## Godot 4 engine test: 27 kinds on 9 display areas, paging, rotating offers and old saves.
## Usage: godot --headless --path . --script res://tests/qa_v0153_catalog_and_save_migration.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("QA 0153 FAILED: no scene")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    shop.call("_new_game")
    var issues: Array[String] = []
    var items: Array = shop.get("stock")
    var shelves: Array = shop.get("shelves")
    var rows: Array = shop.get("desk_rows")
    if items.size() != 27 or shelves.size() != 9 or rows.size() != 9:
        issues.append("27 products must use nine physical shelves and nine visible desk rows")
    shop.call("_change_catalog_page", 1)
    if int(shop.get("desk_page")) != 1 or int(shop.call("_catalog_index",0)) != 9:
        issues.append("Desk second page must show product index 9")
    shop.call("_change_catalog_page", 1)
    if int(shop.get("desk_page")) != 2 or int(shop.call("_catalog_index",0)) != 18:
        issues.append("Desk third page must start at SKU18")
    shop.call("_change_catalog_page", -5)
    if int(shop.get("desk_page")) != 0:
        issues.append("Desk pages must clamp to first page")
    shop.set("total_sales", 15)
    shop.set("cash", 400)
    var offering_day: int = 1
    for trial_day in range(1, 8):
        shop.set("day", trial_day)
        if bool(shop.call("_supplier_available",9)):
            offering_day = trial_day
            break
    shop.set("day", offering_day)
    var starting_cash: int = int(shop.get("cash"))
    shop.call("_buy_product", 9)
    if int(shop.get("carrying")) != 9 or int(shop.get("cash")) >= starting_cash:
        issues.append("New SKU should be purchasable only when supplier offers it")
    shop.call("_stock_from_desk", 9)
    if int((shop.get("stock") as Array)[9]) != 1 or int(shop.call("_shelf_inventory_count",0)) != 1:
        issues.append("New SKU must occupy a real shared display slot")
    shop.set("customer_target",9)
    shop.set("customer_budget",999)
    shop.call("_complete_sale")
    if int((shop.get("stock") as Array)[9]) != 0:
        issues.append("Visitor sale must decrease new SKU inventory")
    # Standalone old v0.15/9-SKU save can be parsed without modifying the player's actual save.
    var legacy: Dictionary = {"cash":80,"stock":[1,0,0,0,0,0,0,0,0],"prices":[18,14,23,56,25,30,46,34,40]}
    var path: String = "user://lcg_p05_v0153_legacy_fixture.json"
    var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
    if file == null:
        issues.append("Could not make legacy fixture")
    else:
        file.store_string(JSON.stringify(legacy))
        file.close()
        var recovered: Dictionary = shop.call("_read_save_data", path)
        if recovered.is_empty():
            issues.append("Legacy nine-product save must remain loadable")
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    if issues.is_empty():
        print("QA 0153 PASSED: 27 products, 9 shelves, 3 catalogue pages, seller offer, sale, 9-slot save")
        quit(0)
    else:
        for issue in issues:
            push_error("QA 0153 FAILED: " + issue)
        quit(1)
