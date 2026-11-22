extends SceneTree
## Engine-native test: not a replacement for Windows visual inspection.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene := load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("QA 0147 FAILED: Main scene unavailable")
        quit(1)
        return
    var shop := scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    var problems: Array[String] = []
    for scene_path in [
        "res://assets/curated_v0147/mini_shop/clothing-rack.glb",
        "res://assets/curated_v0147/mini_shop/mannequin.glb",
        "res://assets/curated_v0147/mini_shop/shopping-basket.glb",
        "res://assets/curated_v0147/mini_shop/shelf-bags.glb",
        "res://assets/curated_v0147/mini_shop/hand-truck.glb",
        "res://assets/curated_v0147/furniture/coatRackStanding.glb"
    ]:
        var model := load(scene_path) as PackedScene
        if model == null:
            problems.append("Model import failed: " + scene_path)
    for sound_path in [
        "res://assets/curated_v0147/audio/footstep_wood_000.ogg",
        "res://assets/curated_v0147/audio/footstep_wood_001.ogg",
        "res://assets/curated_v0147/audio/impactBell_heavy_000.ogg",
        "res://assets/curated_v0147/audio/impactGeneric_light_000.ogg"
    ]:
        if not (load(sound_path) is AudioStream):
            problems.append("Audio import failed: " + sound_path)
    if (shop.get("footstep_streams") as Array).size() != 2:
        problems.append("Two alternating footstep streams expected")
    if not (shop.get("audio_entry_bell") is AudioStreamPlayer):
        problems.append("Entry bell player missing")
    if not (shop.get("audio_stock") is AudioStreamPlayer):
        problems.append("Stocking sound player missing")
    if problems.is_empty():
        print("QA ASSETS 0147 PASSED: six GLB props and four audio streams loaded; audio players initialized")
        quit(0)
    else:
        for item in problems:
            push_error("QA 0147 FAILED: " + item)
        quit(1)
