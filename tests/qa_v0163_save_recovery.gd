extends SceneTree
## Godot 4 native-only isolated save test. NEVER reads/writes the real game save.
const TEMP_PATH: String = "user://lcg_p05_qa_v0163_isolated_save.json"

func _initialize() -> void:
    call_deferred("_run")

func _clean() -> void:
    for path in [TEMP_PATH, TEMP_PATH + ".bak", TEMP_PATH + ".pending"]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _expect(condition: bool, label: String, failures: Array[String]) -> void:
    if not condition:
        failures.append(label)

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA 0163 FAILED: main scene unavailable")
        quit(1)
        return
    var shop: Node3D = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    var problems: Array[String] = []
    _clean()
    var first: Dictionary = {"stock": [], "prices": [], "cash": 80, "day": 1}
    for i in range(27):
        first["stock"].append(0)
        first["prices"].append(10)
    _expect(bool(shop.call("_write_save_safely", TEMP_PATH, first)), "first write failed", problems)
    _expect(int((shop.call("_read_save_data", TEMP_PATH) as Dictionary).get("cash", -1)) == 80, "first file unreadable", problems)
    var second: Dictionary = first.duplicate(true)
    second["cash"] = 125
    _expect(bool(shop.call("_write_save_safely", TEMP_PATH, second)), "second write failed", problems)
    _expect(int((shop.call("_read_save_data", TEMP_PATH) as Dictionary).get("cash", -1)) == 125, "new save value missing", problems)
    _expect(int((shop.call("_read_save_data", TEMP_PATH + ".bak") as Dictionary).get("cash", -1)) == 80, "previous valid version not backed up", problems)
    # Simulate a partial primary file while the older good backup survives.
    var broken: FileAccess = FileAccess.open(TEMP_PATH, FileAccess.WRITE)
    if broken != null:
        broken.store_string("{ not-json")
        broken.close()
    _expect(int((shop.call("_select_valid_save_data", TEMP_PATH) as Dictionary).get("cash", -1)) == 80, "corrupt primary did not fall back to backup", problems)
    # Simulate a completed staged write at the moment the app loses power.
    var staged: FileAccess = FileAccess.open(TEMP_PATH + ".pending", FileAccess.WRITE)
    if staged != null:
        var newest: Dictionary = first.duplicate(true)
        newest["cash"] = 210
        staged.store_string(JSON.stringify(newest))
        staged.close()
    _expect(int((shop.call("_select_valid_save_data", TEMP_PATH) as Dictionary).get("cash", -1)) == 210, "validated pending state not recovered", problems)
    # Do not touch the real player save, and reject QA writes to that path.
    _expect(not bool(shop.call("_write_save_safely", "user://lcg_p05_shop_v09.json", first)), "QA guard did not block main save path", problems)
    _clean()
    _expect(not FileAccess.file_exists(TEMP_PATH) and not FileAccess.file_exists(TEMP_PATH + ".bak") and not FileAccess.file_exists(TEMP_PATH + ".pending"), "test files left behind", problems)
    if problems.is_empty():
        print("QA 0163 PASSED: staged writes, backup recovery, pending recovery, isolated test cleanup")
        quit(0)
    else:
        for issue in problems:
            push_error("QA 0163 FAILED: " + issue)
        quit(1)
