extends SceneTree
## Developer-only render capture for W3 visual QA.
## Uses qa_mode so personal saves and preferences are not read or written.
## Not a player feature, store screenshot, or evidence of human playability.

const OUT_DIR: String = "res://documentation/windows_visual_previews"

func _initialize() -> void:
    call_deferred("_run_capture")

func _capture(label: String, expected_size: Vector2i) -> bool:
    # Godot 4.4 recommends capturing after frame_post_draw.
    await RenderingServer.frame_post_draw
    var img: Image = root.get_texture().get_image()
    if img == null or img.is_empty():
        push_error("VISUAL QA FAILED: viewport image is empty: " + label)
        return false
    if img.get_size() != expected_size:
        push_error("VISUAL QA FAILED: wrong dimensions for %s: %s instead of %s" % [label, img.get_size(), expected_size])
        return false
    var out: String = ProjectSettings.globalize_path(OUT_DIR.path_join(label + ".png"))
    var status: Error = img.save_png(out)
    if status != OK:
        push_error("VISUAL QA FAILED: couldn't save " + out + " (code " + str(status) + ")")
        return false
    print("VISUAL QA PNG: " + out + " / " + str(img.get_size()))
    return true

func _run_capture() -> void:
    var out_path: String = ProjectSettings.globalize_path(OUT_DIR)
    var created: Error = DirAccess.make_dir_recursive_absolute(out_path)
    if created != OK:
        push_error("VISUAL QA FAILED: cannot make output folder " + out_path)
        quit(1)
        return
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("VISUAL QA FAILED: main scene cannot be loaded")
        quit(1)
        return

    # Fixed viewport sizes provide comparable 720p and 1080p evidence.
    root.size = Vector2i(1280, 720)
    var shop: Node3D = scene.instantiate() as Node3D
    shop.set("qa_mode", true)
    root.add_child(shop)

    # Let the quiet 1.8-second studio ident finish before taking the menu.
    await create_timer(3.0).timeout
    var menu_ok: bool = await _capture("menu_1280x720", Vector2i(1280, 720))

    # Capture accessibility options before playing, including font/contrast toggles.
    # qa_mode ensures this screenshot test never persists simulated settings.
    shop.call("_open_settings_menu")
    await create_timer(0.4).timeout
    var settings_ok: bool = await _capture("settings_default_1280x720", Vector2i(1280, 720))
    shop.set("large_text", true)
    shop.set("high_contrast", true)
    shop.call("_apply_accessibility")
    shop.call("_refresh_accessibility_buttons")
    await create_timer(0.4).timeout
    var settings_large_ok: bool = await _capture("settings_large_contrast_1280x720", Vector2i(1280, 720))
    shop.call("_close_settings")
    shop.call("_open_help")
    await create_timer(0.4).timeout
    var help_ok: bool = await _capture("help_keyboard_1280x720", Vector2i(1280, 720))
    shop.call("_close_help")
    shop.call("_open_healthy_play")
    await create_timer(0.3).timeout
    var healthy_ok: bool = await _capture("healthy_play_1280x720", Vector2i(1280, 720))
    (shop.get("healthy_play") as Control).call("close_panel")
    shop.call("_open_privacy_safety")
    await create_timer(0.3).timeout
    var privacy_ok: bool = await _capture("privacy_safety_1280x720", Vector2i(1280, 720))
    (shop.get("privacy_safety") as Control).call("close_panel")
    shop.set("large_text", false)
    shop.set("high_contrast", false)
    shop.call("_apply_accessibility")

    # Enter the game through the same method used in native smoke tests.
    shop.call("_new_game")
    await create_timer(2.0).timeout
    var shop_720_ok: bool = await _capture("shop_1280x720", Vector2i(1280, 720))
    root.size = Vector2i(1920, 1080)
    await create_timer(0.75).timeout
    var shop_1080_ok: bool = await _capture("shop_1920x1080", Vector2i(1920, 1080))

    root.remove_child(shop)
    shop.free()
    shop = null
    scene = null
    # Let deferred resource releases settle before the GLES3 renderer shuts down.
    await process_frame
    await process_frame
    if menu_ok and settings_ok and settings_large_ok and help_ok and healthy_ok and privacy_ok and shop_720_ok and shop_1080_ok:
        print("VISUAL QA CAPTURE PASSED: 8 real rendered PNGs including accessibility and family/privacy menus (visual review still required)")
        quit(0)
    else:
        push_error("VISUAL QA FAILED: one or more captured frames unavailable")
        quit(1)
