extends SceneTree
## Frame timing of a cloud Windows virtual graphics adapter ONLY.
## No claims about real player hardware, audio or interactive usability.
const OUT_FILE: String = "res://documentation/windows_visual_previews/virtual_resolution_probe.json"
const SIZES = [Vector2i(1024,768), Vector2i(1280,720), Vector2i(1366,768), Vector2i(1920,1080)]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("RELEASE DISPLAY PROBE FAILED: missing main scene")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var shop: Node3D = scene.instantiate() as Node3D
    shop.set("qa_mode",true)
    root.add_child(shop)
    await create_timer(2.0).timeout
    shop.call("_new_game")
    var records: Array[Dictionary] = []
    for size in SIZES:
        root.size = size
        await create_timer(0.35).timeout
        var elapsed_us: Array[int] = []
        var stamp: int = Time.get_ticks_usec()
        for i in range(90):
            await process_frame
            var now: int = Time.get_ticks_usec()
            elapsed_us.append(now - stamp)
            stamp = now
        elapsed_us.sort()
        var sum: int = 0
        for x in elapsed_us:
            sum += x
        var average_ms: float = float(sum) / float(elapsed_us.size()) / 1000.0
        var p95_ms: float = float(elapsed_us[int(floori(float(elapsed_us.size() - 1) * 0.95))]) / 1000.0
        var rec: Dictionary = {"width":size.x,"height":size.y,"frames":elapsed_us.size(),
            "frame_wall_ms_average":snappedf(average_ms,0.01),
            "frame_wall_ms_p95":snappedf(p95_ms,0.01),
            "average_wall_fps_estimate":snappedf(1000.0 / maxf(average_ms,0.1),0.1),
            "ui_stretch_mode":str(ProjectSettings.get_setting("display/window/stretch/mode"))}
        records.append(rec)
        print("RELEASE VIRTUAL RESOLUTION SAMPLE: ",JSON.stringify(rec))
    var data: Dictionary = {"os":OS.get_name(),"cpu":OS.get_processor_name(),
        "renderer":RenderingServer.get_video_adapter_name(),
        "hardware_limit":"Cloud virtual Windows environment; NOT a player GPU benchmark",
        "audio_limit":"Audio was not heard; this test uses a dummy audio driver",
        "input_limit":"No human keyboard/mouse interaction verified",
        "frames":records}
    var out: String = ProjectSettings.globalize_path(OUT_FILE)
    var file: FileAccess = FileAccess.open(out,FileAccess.WRITE)
    if file == null:
        push_error("RELEASE DISPLAY PROBE FAILED: cannot write metric report")
        quit(1)
        return
    file.store_string(JSON.stringify(data,"  "))
    file.close()
    root.remove_child(shop)
    shop.free()
    shop = null
    scene = null
    await process_frame
    await process_frame
    print("RELEASE VIRTUAL DISPLAY PROBE PASSED: four resolutions measured without a player-hardware claim")
    quit(0)
