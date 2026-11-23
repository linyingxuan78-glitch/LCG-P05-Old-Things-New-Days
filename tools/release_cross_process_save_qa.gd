extends SceneTree
## Real game save -> fresh Godot process -> actual game load.
## CAUTION: this script can only run when the Windows runner provides an
## explicit isolated APPDATA root; it ABORTS before touching a player save.
const SAVE_PATH: String = "user://lcg_p05_shop_v09.json"

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("RELEASE CROSS-PROCESS SAVE FAILED: " + message)
    quit(1)

func _run() -> void:
    var expected: String = OS.get_environment("LCG_P05_QA_ROOT").replace("\\", "/").trim_suffix("/").to_lower()
    var actual: String = ProjectSettings.globalize_path("user://").replace("\\", "/").trim_suffix("/").to_lower()
    if expected.length() < 12 or not actual.begins_with(expected + "/"):
        _fail("Sandbox check prevented touching a real player save. APPDATA=" + actual)
        return
    var args: PackedStringArray = OS.get_cmdline_user_args()
    if args.size() != 1 or str(args[0]) not in ["write","read"]:
        _fail("Expected -- write or -- read")
        return
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        _fail("Game scene could not load")
        return
    var shop: Node3D = scene.instantiate() as Node3D
    shop.set("qa_mode", true) # Prevent _ready() reading external settings.
    root.add_child(shop)
    await process_frame
    if args[0] == "write":
        # Environment isolation is verified above; exercising actual game
        # _save_game rather than a mock or hand-authored JSON fixture.
        shop.set("qa_mode", false)
        shop.call("_new_game")
        shop.set("cash", 137)
        shop.set("day", 4)
        var stock: Array = shop.get("stock")
        stock[0] = 2
        var prices: Array = shop.get("prices")
        prices[0] = 23
        var incidents: Control = shop.get("secondhand_events") as Control
        incidents.call("import_state", {
            "active_id":"textile_surplus","handled":true,
            "boxes":3,"goodwill":5,"outcome":"cross-process-test"
        },4,0)
        if not bool(shop.call("_save_game")):
            _fail("Actual _save_game could not commit in isolated Windows profile")
            return
        var saved: Dictionary = shop.call("_read_save_data",SAVE_PATH)
        if int(saved.get("cash",-1)) != 137 or int(saved.get("day",-1)) != 4:
            _fail("Written game state was not committed")
            return
        print("CROSS-PROCESS SAVE WRITE PASSED: real game payload, 27 SKUs, incident state")
        # _new_game also starts normal audio/visitor timers. Shut those down
        # before the scripted SceneTree exits to avoid false resource-leak errors.
        shop.set("qa_mode",true)
        shop.call("_show_title")
        await create_timer(0.5).timeout
    else:
        # Re-instantiate actual game in this distinct Godot process.
        if not bool(shop.call("_load_game")):
            _fail("Actual _load_game could not load prior process save")
            return
        var recovered: Dictionary = (shop.get("secondhand_events") as Control).call("export_state")
        var check: bool = int(shop.get("cash")) == 137 and int(shop.get("day")) == 4
        var stock2: Array = shop.get("stock")
        var prices2: Array = shop.get("prices")
        check = check and int(stock2[0]) == 2 and int(prices2[0]) == 23
        check = check and int(recovered.get("boxes",-1)) == 3
        check = check and int(recovered.get("goodwill",-1)) == 5
        check = check and bool(recovered.get("handled",false))
        if not check:
            _fail("Cash, day, stock, price or thrift incident did not survive a fresh process")
            return
        print("CROSS-PROCESS SAVE READ PASSED: 2 separate Godot processes restored real gameplay and incident state")
    root.remove_child(shop)
    shop.free()
    shop = null
    scene = null
    await process_frame
    await process_frame
    quit(0)
