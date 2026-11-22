extends SceneTree
## Requires Godot 4.x with editor imports complete.
## godot --headless --path . --script res://tests/qa_v014_onboarding_and_accessibility.gd
## Test mode: no gameplay / audio-preference saves written to user's files.

func _initialize() -> void:
    call_deferred("_run")

func _check(value: bool, description: String, errors: Array[String]) -> void:
    if not value:
        errors.append(description)

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("Cannot open main scene")
        quit(1)
        return
    var shop: Node = scene.instantiate()
    shop.set("qa_mode", true) # Protect local player settings and saves before _ready().
    root.add_child(shop)
    await process_frame
    shop.set("qa_mode", true)
    shop.call("_new_game")
    var problems: Array[String] = []
    _check(bool(shop.get("tutorial_active")), "New Game should start the tutorial", problems)
    _check(int(shop.get("tutorial_step")) == 0, "Step 0 should teach the desk", problems)
    shop.call("_toggle_desk")
    _check(int(shop.get("tutorial_step")) == 1, "Opening desk must complete step 0", problems)
    shop.call("_buy_product", 0)
    _check(int(shop.get("tutorial_step")) == 2, "Buying should complete step 1", problems)
    _check(int(shop.get("cash")) == 73, "Cash mismatch after buying radio", problems)
    shop.call("_stock_from_desk", 0)
    _check(int(shop.get("tutorial_step")) == 3, "Stocking should complete step 2", problems)
    shop.call("_change_price", 0, 1)
    _check(int(shop.get("tutorial_step")) == 4, "Price change should complete step 3", problems)
    shop.set("customer_target", 0)
    shop.set("customer_budget", 99)
    shop.call("_complete_sale")
    _check(not bool(shop.get("tutorial_active")), "Tutorial must complete on real sale", problems)
    _check(int(shop.get("tutorial_step")) == 5, "All five steps must complete", problems)
    _check(int(shop.get("cash")) == 92, "A completed tutorial sale should maintain economy", problems)
    shop.call("_start_tutorial")
    _check(int(shop.get("tutorial_step")) == 0, "Tutorial replay should return to first step", problems)
    shop.call("_skip_tutorial")
    _check(not bool(shop.get("tutorial_active")), "Skip must end tutorial", problems)
    _check(int(shop.get("tutorial_step")) == 5, "Skipped tutorial should remain complete", problems)
    # Help must not force a restart or overwrite the shop economy.
    shop.call("_open_help")
    var help: Control = shop.get("help_ui")
    _check(help.visible, "Help page didn't open", problems)
    shop.call("_close_help")
    _check(not help.visible, "Help page didn't close", problems)
    _check(int(shop.get("cash")) == 92, "Help changed player cash", problems)
    # General usability controls are independent of gameplay progress.
    var title: Label = shop.get("tutorial_heading") as Label
    var font_before: int = title.get_theme_font_size("font_size")
    shop.set("large_text", false)
    shop.call("_apply_accessibility")
    font_before = title.get_theme_font_size("font_size")
    shop.call("_toggle_accessibility", 0)
    _check(int(title.get_theme_font_size("font_size")) > font_before, "Larger UI text toggle ineffective", problems)
    var contrast_before: bool = bool(shop.get("high_contrast"))
    shop.call("_toggle_accessibility", 1)
    _check(bool(shop.get("high_contrast")) != contrast_before, "Contrast preference toggle ineffective", problems)
    var motion_before: bool = bool(shop.get("reduced_motion"))
    shop.call("_toggle_accessibility", 2)
    _check(bool(shop.get("reduced_motion")) != motion_before, "Reduce-motion preference toggle ineffective", problems)
    _check(int(shop.get("cash")) == 92, "Accessibility changes touched game state", problems)
    # Legacy save payloads may lack the new tutorial keys; older saves are not forced to restart onboarding.
    if problems.is_empty():
        print("v0.14 QA PASS: tutorial events, skip/replay, help and accessibility controls")
        quit(0)
    else:
        for problem in problems:
            push_error("v0.14 QA FAIL: " + problem)
        quit(1)
