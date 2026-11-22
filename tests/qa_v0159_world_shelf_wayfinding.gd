extends SceneTree
## Native Godot 4 QA, not executed until a compatible engine is available.
## Tests that in-world target signs make shelving less text-dependent.

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, label: String, issues: Array[String]) -> void:
    if not condition:
        issues.append(label)

func _run() -> void:
    var packed: PackedScene = load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("QA 0159 FAIL: main.tscn could not be loaded")
        quit(1)
        return
    var shop: Node = packed.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    shop.call("_new_game")
    var issues: Array[String] = []
    var guide: Label3D = shop.get("stock_wayfinder") as Label3D
    var card: Panel = shop.get("context_action_panel") as Panel
    var card_image: TextureRect = shop.get("context_action_icon") as TextureRect
    var card_key: Label = shop.get("context_action_key") as Label
    var shelved: Array = shop.get("shelves")
    var gamer: CharacterBody3D = shop.get("player") as CharacterBody3D
    _check(guide != null, "3D nonflashing target sign must exist", issues)
    _check(card != null and card_image != null and card_key != null, "Picture and single-key prompt must exist", issues)
    _check(shelved.size() == 9, "Existing nine physical shelves must remain", issues)
    _check(gamer != null, "Player body missing", issues)
    if guide != null and card != null and shelved.size() == 9 and gamer != null:
        shop.set("carrying", 0)
        gamer.position = Vector3(0, 0.12, 4.8)
        gamer.rotation.y = PI
        shop.call("_refresh_ui")
        _check(not shop.call("_near_matching_shelf"), "Cannot stock from across the shop", issues)
        var remote_qty: int = int((shop.get("stock") as Array)[0])
        shop.call("_interact_shelf")
        _check(int(shop.get("carrying")) == 0 and int((shop.get("stock") as Array)[0]) == remote_qty, "Remote E cannot place goods", issues)
        _check(guide.visible and guide.text.contains("▼"), "Sign must show pictorial down arrow", issues)
        _check(card.visible and card_image.texture != null, "Carrying should show a picture context prompt", issues)
        var shelf0: StaticBody3D = shelved[0] as StaticBody3D
        gamer.global_position = shelf0.global_position + Vector3(0.0, -0.83, 1.60)
        gamer.rotation.y = PI # Face AWAY to test forgiving interaction without ray precision.
        shop.call("_refresh_ui")
        _check(shop.call("_near_matching_shelf"), "Near shelf should count even without direct gaze", issues)
        _check(card_key.text.contains("E"), "Nearby icon should state the one-key action", issues)
        var before: int = (shop.get("stock") as Array)[0]
        shop.call("_interact_shelf")
        _check(int(shop.get("carrying")) == -1, "E should put down carried goods by matching shelf", issues)
        _check(int((shop.get("stock") as Array)[0]) == before + 1, "E must increase inventory exactly once", issues)
        shop.call("_refresh_ui")
        _check(not guide.visible, "Guide should disappear when hands are empty", issues)
        shop.set("carrying", 1)
        shop.set("picture_guides", false)
        shop.call("_refresh_ui")
        _check(not guide.visible and not card.visible, "Optional picture guides OFF must hide both overlays", issues)
    if issues.is_empty():
        print("QA 0159 PASSED: 3D location sign, no remote stock, forgiving E placement, visual cues, opt-out")
        quit(0)
    else:
        for issue in issues:
            push_error("QA 0159 FAIL: " + issue)
        quit(1)
