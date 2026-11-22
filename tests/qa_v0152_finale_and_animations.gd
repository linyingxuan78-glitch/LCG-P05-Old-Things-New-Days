extends SceneTree
## Run after Godot has imported the .glb assets. This is an engine test, not a mock pass.
## godot --headless --path . --script res://tests/qa_v0152_finale_and_animations.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA 0152 FAILED: main scene unavailable")
        quit(1)
        return
    var shop: Node = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    shop.call("_new_game")
    var problems: Array[String] = []
    if bool(shop.call("_community_finale_unlocked")):
        problems.append("Finale must be locked on Day 1")
    var cash_before: int = int(shop.get("cash"))
    shop.set("day", 4)
    shop.set("total_sales", 8)
    shop.set("display_level", 1)
    if not bool(shop.call("_community_finale_unlocked")):
        problems.append("Finale should unlock with Day 4 + 8 sales + LV1")
    shop.call("_open_community_finale")
    var panel: Panel = shop.get("community_finale_ui") as Panel
    if not panel.visible:
        problems.append("Finale dialog must open on demand")
    var temporary_stage: Node3D = shop.get("community_finale_stage") as Node3D
    if temporary_stage == null or temporary_stage.get_child_count() < 5:
        problems.append("Temporary 3D community decorations were not created")
    var heading: Label = shop.get("community_finale_heading") as Label
    if heading.text != "A DAY FOR OLD THINGS":
        problems.append("Wrong first finale scene")
    shop.call("_advance_community_finale")
    shop.call("_advance_community_finale")
    if int(shop.get("community_finale_page")) != 2:
        problems.append("Finale must have three scenes")
    if heading.text != "THE DOOR STAYS OPEN":
        problems.append("Wrong last finale scene")
    shop.call("_advance_community_finale")
    if not bool(shop.get("community_finale_seen")):
        problems.append("Completion flag missing")
    if panel.visible or not (shop.get("desk_ui") as Panel).visible:
        problems.append("Finale should return player to shop desk")
    if shop.get("community_finale_stage") != null:
        problems.append("Finale must remove temporary 3D props when closed")
    if not bool(shop.get("playing")) or int(shop.get("cash")) != cash_before:
        problems.append("Optional finale must not end game or change cash")
    if int(shop.get("total_sales")) != 8:
        problems.append("Finale must not create an artificial sale")
    # Import-level animation verification on actual GLB character scenes.
    for path in [
        "res://assets/models/character-female-a.glb",
        "res://assets/models/character-male-a.glb",
        "res://assets/selected_v015/characters/character-female-b.glb"
    ]:
        var pack: PackedScene = load(path) as PackedScene
        if pack == null:
            problems.append("Character import failed: " + path)
            continue
        var actor: Node = pack.instantiate()
        shop.add_child(actor)
        var animation_player: AnimationPlayer = shop.call("_find_customer_animation_player", actor) as AnimationPlayer
        if animation_player == null:
            problems.append("Missing imported AnimationPlayer: " + path)
        else:
            var names: PackedStringArray = animation_player.get_animation_list()
            var has_walk: bool = false
            var has_idle: bool = false
            for name in names:
                has_walk = has_walk or (str(name) == "walk" or str(name).ends_with("/walk"))
                has_idle = has_idle or (str(name) == "idle" or str(name).ends_with("/idle"))
            if not has_walk or not has_idle:
                problems.append("Character missing walk/idle clips: " + path)
        actor.queue_free()
    if problems.is_empty():
        print("QA 0152 PASSED: optional 3-scene finale, no accounting side effects, character animation imports")
        quit(0)
    else:
        for item in problems:
            push_error("QA 0152 FAILED: " + item)
        quit(1)
