extends Node3D
## Little Cozy Games / LCG-P05 — Godot 4 native gameplay v0.16.9 (quiet intro, guarded OS/window close and desktop exit).
## Internal prototype, not a Steam-ready commercial release.
## Third-party models and sound: see licenses/ and documentation/ASSET_INTAKE_v0145.md.

# One brief brand ident at application boot only. No flashing, spinning, zooming or forced credits.
const BRAND_SPLASH_SECONDS: float = 1.8
const BRAND_FADE_IN_SECONDS: float = 0.50
const BRAND_FADE_OUT_SECONDS: float = 0.32
const SAVE_PATH: String = "user://lcg_p05_shop_v09.json" # Retain v0.9 saves.
const SAVE_PENDING_SUFFIX: String = ".pending" # Crash-safe staged write; not an extra player save slot.
const SETTINGS_PATH: String = "user://lcg_p05_audio_settings.json"
const HEALTHY_PLAY_SCRIPT: Script = preload("res://scripts/healthy_play.gd")
const PRIVACY_SAFETY_SCRIPT: Script = preload("res://scripts/privacy_safety.gd")
const SECONDHAND_EVENTS_SCRIPT: Script = preload("res://scripts/secondhand_events.gd")
const ENGINE_NOTICES_SCRIPT: Script = preload("res://scripts/engine_notices.gd")
const SHELF_CAPACITY: int = 6
const CONSIGNMENT_PRODUCT_INDEX: int = 1 # Old Book Set: supplier-funded recovery stock.
const LEDGER_MAX_DAYS: int = 14
const TUTORIAL_ACTIONS = ["open_desk", "buy", "stock", "price", "sale"]
const TUTORIAL_TITLES = ["OPEN STORE DESK", "BUY YOUR FIRST ITEM", "PLACE ITEM ON SHELF", "SET YOUR SELLING PRICE", "COMPLETE ONE SALE"]
# Short prompts plus a matching static picture and keycap. This improves reading
# load but is NOT a full non-reader mode or audio narration system.
const TUTORIAL_INSTRUCTIONS = [
    "Go to the counter and press E, or press TAB to open the desk.",
    "Choose an available item. Press BUY and watch it appear in your hands.",
    "Follow the ▼ sign to the matching shelf. Stand near it and press E, or use STOCK at the desk.",
    "Change the price with the + or - button. You can revise it later.",
    "Close the desk. Let a shopper find the item and pay at checkout."
]
const TUTORIAL_PICTURE_IDS = [0, 0, 1, 2, 2]
const TUTORIAL_KEYCAPS = ["E / TAB", "BUY", "E / STOCK", "+ / -", "WATCH CHECKOUT"]

const BULK_DISCOUNT: float = 0.90
# Daily demand cycles are visible in the shop desk: customers prefer the featured group.
# Existing nine goods retain their original category order; new finds extend the six groups.
const CATEGORY_NAMES = ["Vintage Tech", "Home & Books", "Kitchen Finds", "Clothes & Travel", "Toys & Collectibles", "Small Furniture"]
const PRODUCT_CATEGORIES = [0, 1, 1, 0, 1, 2, 2, 0, 2, 0, 1, 1, 0, 1, 2, 5, 3, 2, 0, 4, 1, 0, 1, 5, 5, 3, 1]
const SHELF_LABELS = ["ELECTRONICS", "BOOKS & TOYS", "LIGHTING", "SCREENS", "HOME DECOR", "KITCHEN", "COFFEE & FURNITURE", "TRAVEL & AUDIO", "KITCHEN & HOME"]
# Fit larger original GLB models to six small shelf slots instead of letting
# furniture or tall props intersect the board above them. Product scale is
# retained for carried items; only in-shelf display changes.
const DISPLAY_FIT_FACTORS = {0:0.78, 2:0.84, 3:0.74, 4:0.87, 5:0.93, 6:0.74, 7:0.87, 8:0.90, 18:0.87, 20:0.87, 21:0.87, 23:0.53, 24:0.93}
const PRODUCT_PICTURE_TEXTURES = [
    preload("res://assets/product_previews_v0162/product_00.png"),
    preload("res://assets/product_previews_v0162/product_01.png"),
    preload("res://assets/product_previews_v0162/product_02.png"),
    preload("res://assets/product_previews_v0162/product_03.png"),
    preload("res://assets/product_previews_v0162/product_04.png"),
    preload("res://assets/product_previews_v0162/product_05.png"),
    preload("res://assets/product_previews_v0162/product_06.png"),
    preload("res://assets/product_previews_v0162/product_07.png"),
    preload("res://assets/product_previews_v0162/product_08.png"),
    preload("res://assets/product_previews_v0162/product_09.png"),
    preload("res://assets/product_previews_v0162/product_10.png"),
    preload("res://assets/product_previews_v0162/product_11.png"),
    preload("res://assets/product_previews_v0162/product_12.png"),
    preload("res://assets/product_previews_v0162/product_13.png"),
    preload("res://assets/product_previews_v0162/product_14.png"),
    preload("res://assets/product_previews_v0162/product_15.png"),
    preload("res://assets/product_previews_v0162/product_16.png"),
    preload("res://assets/product_previews_v0162/product_17.png"),
    preload("res://assets/product_previews_v0162/product_18.png"),
    preload("res://assets/product_previews_v0162/product_19.png"),
    preload("res://assets/product_previews_v0162/product_20.png"),
    preload("res://assets/product_previews_v0162/product_21.png"),
    preload("res://assets/product_previews_v0162/product_22.png"),
    preload("res://assets/product_previews_v0162/product_23.png"),
    preload("res://assets/product_previews_v0162/product_24.png"),
    preload("res://assets/product_previews_v0162/product_25.png"),
    preload("res://assets/product_previews_v0162/product_26.png"),
]
const CATALOG_PAGE_SIZE: int = 9
const SUPPLIER_ROTATION: int = 4
const BASE_SUPPLIER_QUOTA: int = 8 # Common donated goods; allows two 3-packs after two normal orders.
const CUSTOMER_TURN_SPEED: float = 9.0
const CUSTOMER_WALK_SPEED: float = 1.65 # A casual walk, not a sprint across the shop.
# Optional, low-frequency events. Never use flashing lights, jump scares or punish the player without explanation.
const DAY_EVENT_IDS = ["rain", "delivery_delay", "neighbour_tip", "donation_day"]
const DAY_EVENT_TITLES = {
    "none":"A quiet shop day", "rain":"Rainy weather · fewer walk-ins",
    "delivery_delay":"Delayed delivery · fewer uncommon goods",
    "neighbour_tip":"Neighbour referral · a few more visitors",
    "donation_day":"Community clear-out · a few extra donated finds"
}
const DAILY_EVENT_CHANCE: float = 0.30
const EVENT_MIN_GAP_DAYS: int = 3 # Days between non-empty event dates.


const HOT_CATEGORY_INTEREST: float = 0.60
const HOT_CATEGORY_BUDGET_BONUS: float = 1.10
const MOVEMENT_SPEED: float = 4.5
const LOOK_SENSITIVITY: float = 0.0024
const LOOK_SPEED_MULTIPLIERS = [0.65, 1.0, 1.25]
const LOOK_SPEED_LABELS = ["SLOW", "STANDARD", "FAST"]
const DAY_SECONDS: float = 140.0
# A small, optional visual/narrative finale; not a profit rank or a mandatory ending.
const COMMUNITY_FINALE_SCENES = [
    {"title":"A DAY FOR OLD THINGS", "body":"The shop opens for a neighbourhood exchange.\nPeople arrive with lamps, books and small keepsakes. Nothing needs to be new to be loved."},
    {"title":"A SECOND CHAPTER", "body":"A neighbour finds a radio that sounds like her childhood kitchen.\nSomeone picks up a book to read with a friend. Old objects are finding new homes."},
    {"title":"THE DOOR STAYS OPEN", "body":"Before leaving, a guest places a small note by the counter:\n\n'Thank you for giving these things another chance.'\n\nThe community day ends. Your shop's next chapter is yours to choose."},
]
const BG_MUSIC: String = "res://assets/audio/Swinging Sweet.ogg"
const PRODUCTS = [
    {"name":"Retro Radio",      "cost":7,  "base":18, "unlock":0, "model":"radio",                "scale":2.1, "target":17},
    {"name":"Old Book Set",     "cost":5,  "base":14, "unlock":0, "model":"books",                "scale":3.5, "target":13},
    {"name":"Table Lamp",       "cost":9,  "base":23, "unlock":0, "model":"lampRoundTable",       "scale":2.1, "target":23},
    {"name":"Vintage Television","cost":23,"base":56,"unlock":3,"model":"televisionVintage",    "scale":1.7, "target":56},
    {"name":"Ceramic-Style Plant","cost":10,"base":25,"unlock":3,"model":"pottedPlant",      "scale":0.95, "target":24},
    {"name":"Classic Toaster",   "cost":12,"base":30,"unlock":3,"model":"toaster",             "scale":3.0, "target":30},
    {"name":"Coffee Machine",    "cost":19,"base":46,"unlock":8,"model":"kitchenCoffeeMachine","scale":2.7,"target":47},
    {"name":"Small Speaker",     "cost":14,"base":34,"unlock":8,"model":"speakerSmall",        "scale":2.1, "target":34},
    {"name":"Vintage Blender",   "cost":17,"base":40,"unlock":8,"model":"kitchenBlender",      "scale":2.7, "target":39},
    {"name":"Compact Laptop","cost":24,"base":54,"unlock":8,"model":"expanded/laptop","scale":1.80,"target":53,"category":0,"condition":"Good"},
    {"name":"Comic Book Bundle","cost":6,"base":17,"unlock":3,"model":"books","scale":3.20,"target":17,"category":1,"condition":"Well-Loved"},
    {"name":"Square Desk Lamp","cost":12,"base":28,"unlock":3,"model":"expanded/lampSquareTable","scale":1.80,"target":27,"category":1,"condition":"Excellent"},
    {"name":"Modern Television","cost":28,"base":67,"unlock":12,"model":"expanded/televisionModern","scale":0.70,"target":66,"category":0,"condition":"Good"},
    {"name":"Small Indoor Plant","cost":8,"base":21,"unlock":3,"model":"expanded/plantSmall2","scale":2.00,"target":21,"category":1,"condition":"Good"},
    {"name":"Microwave Oven","cost":18,"base":44,"unlock":8,"model":"expanded/kitchenMicrowave","scale":1.70,"target":44,"category":2,"condition":"Good"},
    {"name":"Wooden Side Table","cost":19,"base":43,"unlock":8,"model":"expanded/sideTable","scale":0.88,"target":43,"category":5,"condition":"Well-Loved"},
    {"name":"Travel Suitcase","cost":11,"base":29,"unlock":3,"model":"expanded/item-luggage","scale":1.65,"target":29,"category":3,"condition":"Good"},
    {"name":"Mini Fridge","cost":27,"base":65,"unlock":12,"model":"expanded/kitchenFridgeSmall","scale":0.75,"target":64,"category":2,"condition":"Excellent"},
    {"name":"Computer Keyboard","cost":7,"base":20,"unlock":3,"model":"expanded/computerKeyboard","scale":2.10,"target":20,"category":0,"condition":"Good"},
    {"name":"Teddy Bear","cost":6,"base":18,"unlock":3,"model":"expanded/bear","scale":1.18,"target":18,"category":4,"condition":"Well-Loved"},
    {"name":"Floor Lamp","cost":15,"base":37,"unlock":8,"model":"expanded/lampRoundFloor","scale":0.73,"target":37,"category":1,"condition":"Good"},
    {"name":"Retro Computer Screen","cost":15,"base":36,"unlock":8,"model":"computerScreen","scale":1.50,"target":35,"category":0,"condition":"Good"},
    {"name":"Soft Cushion","cost":4,"base":12,"unlock":0,"model":"expanded/pillow","scale":1.55,"target":12,"category":1,"condition":"Excellent"},
    {"name":"Standing Coat Rack","cost":15,"base":36,"unlock":8,"model":"expanded/coatRackStanding","scale":1.30,"target":35,"category":5,"condition":"Good"},
    {"name":"Rounded Wooden Chair","cost":18,"base":44,"unlock":8,"model":"expanded/chairRounded","scale":1.30,"target":43,"category":5,"condition":"Well-Loved"},
    {"name":"Folded Clothes Bundle","cost":9,"base":24,"unlock":3,"model":"procedural/foldedClothes","scale":1.00,"target":24,"category":3,"condition":"Good"},
    {"name":"Round Rug","cost":13,"base":32,"unlock":8,"model":"expanded/rugRound","scale":0.52,"target":31,"category":1,"condition":"Well-Loved"},
]
const DISPLAY_LEVEL_PRICES = [35, 65, 110]
const SHELF_POINTS = [
    Vector3(-4.5, 0.95, -6.0), Vector3(0, 0.95, -6.0), Vector3(4.5, 0.95, -6.0),
    Vector3(-6.6, 0.95, -3.8), Vector3(-6.6, 0.95, 0), Vector3(-6.6, 0.95, 3.8),
    Vector3(6.6, 0.95, -3.8), Vector3(6.6, 0.95, 0), Vector3(6.6, 0.95, 3.8),
]

var rng := RandomNumberGenerator.new()
var cash: int = 80
var total_sales: int = 0
var total_revenue: int = 0
var total_wholesale: int = 0
var day: int = 1
var day_clock: float = 0.0
var day_revenue: int = 0
var day_cost: int = 0
var day_sales: int = 0
var day_visitors: int = 0
var total_visitors: int = 0
var day_no_stock: int = 0
var day_over_budget: int = 0
var day_unserved_at_close: int = 0
var total_goal_rewards: int = 0
var day_goal_awarded: bool = false
var day_consignment_paid: int = 0
var day_hot_sales: int = 0
var recovered_save: bool = false
var total_consignment_paid: int = 0
var daily_history: Array[Dictionary] = []
var consignment_stock: Array[int] = []
var paused: bool = false
var qa_mode: bool = false # QA scripts must never overwrite a real player save.
var qa_force_save_failure: bool = false # Fault injection for Godot QA only.
var exit_committed: bool = false # Avoid repeat close notifications after a successful quit.
var display_level: int = 0
var carrying: int = -1
var stock: Array[int] = []
var prices: Array[int] = []
var supplier_remaining: Array[int] = [] # Per-SKU daily supplier offers. Persisted in saves.
# One optional neighbourhood resale offer per business day (after opening day).
# This is a distinct, finite opportunity rather than unlimited wholesale stock.
var resident_offer_index: int = -1
var resident_offer_cost: int = 0
var resident_offer_decided: bool = false
var resident_purchases_total: int = 0
var resident_purchase_spending: int = 0
# Each event is decided once at the start of a day and saved. Reloading does not reroll it.
var day_event_id: String = "none"
var last_day_event_id: String = "none"
var last_day_event_day: int = -100
var event_days_total: int = 0
var day_feedback: Dictionary = {"pleased":0, "missing":0, "expensive":0}
var last_customer_appearance: int = -1
var customer_agreed_price: int = -1
var customer_bargain_offer: int = -1
var day_bargain_offers: int = 0
var day_bargain_accepted: int = 0
var day_bargain_rejected: int = 0
var day_assisted_shoppers: int = 0
var total_assisted_shoppers: int = 0
var sold_milestone: bool = false
var music_volume: float = 0.50
var sfx_volume: float = 0.70
var master_volume: float = 0.75
# Optional first-session, event-driven tutorial. Existing v0.9-v0.13 saves default to complete.
var tutorial_active: bool = false
var tutorial_step: int = 0
var large_text: bool = false
var high_contrast: bool = false
# Comfortable defaults: no unnecessary animated intro, slightly gentler look,
# and less intense lighting. Preferences are independent and can be disabled.
var reduced_motion: bool = true
var picture_guides: bool = true
var compact_hud: bool = false
var gentle_camera: bool = true
var soft_lighting: bool = true
var mouse_speed_mode: int = 1  # 0 slow, 1 standard (old saved-game default), 2 fast.
var sunlight_light: DirectionalLight3D
var shop_environment: Environment


var healthy_play: Control
var privacy_safety: Control
var secondhand_events: Control
var story_entry_button: Button
var playing: bool = false
var player: CharacterBody3D
var camera: Camera3D
var head: Node3D
var ray: RayCast3D
var held_item: Node3D
var shelves: Array[StaticBody3D] = []
var product_visuals: Array[Node3D] = []
var price_tags: Array[Label3D] = []
# A single non-flashing, camera-facing sign for the shelf matching the carried item.
var stock_wayfinder: Label3D
var display_elements: Array[Node3D] = []
var customer: Node3D
var customer_target: int = -1
var customer_phase: String = "idle"
var customer_timer: float = 4.0
var customer_wait: float = 0.0
var customer_budget: int = 0
var customer_entry: Vector3 = Vector3(0, 0, 6.7)
var customer_route: Array[Vector3] = []
var customer_waypoint: int = 0
var customer_visual: Node3D
var customer_walk_phase: float = 0.0
var customer_animation_player: AnimationPlayer
var customer_animation_state: String = ""
var shopper_reaction: Label3D
var customer_checkout: Vector3 = Vector3(3.1, 0.0, 4.1)
var world: Node3D
var audio_music: AudioStreamPlayer
var audio_click: AudioStreamPlayer
var audio_sale: AudioStreamPlayer
var audio_footstep: AudioStreamPlayer
var audio_entry_bell: AudioStreamPlayer
var audio_stock: AudioStreamPlayer
var footstep_streams: Array[AudioStream] = []
var footstep_elapsed: float = 0.0
var footstep_index: int = 0

var ui_layer: CanvasLayer
var title_ui: Panel
var hud_ui: Control
var desk_ui: Panel
var report_ui: Panel
var settings_ui: Panel
var mouse_speed_button: Button
var close_day_confirm_ui: Panel
var close_day_return_to_desk: bool = false
var settings_return_to_game: bool = false
var settings_source: String = "title"
var pause_ui: Panel
var ledger_ui: Panel
var ledger_text: Label
var volume_labels: Array[Label] = []
var volume_sliders: Array[HSlider] = []
var credits_ui: Panel
var credits_legal_label: RichTextLabel
var credits_scroll: ScrollContainer
var credits_default_text: String = ""
var pause_status_label: Label
var splash_ui: Panel
var splash_logo: Control
var splash_remaining: float = BRAND_SPLASH_SECONDS
var hud_status: Label
var hud_help_panel: Panel
var hud_bottom_panel: Panel
var pictogram_panel: Panel
var pictogram_icons: Array[TextureRect] = []
var pictogram_labels: Array[Label] = []
var pictogram_event: Label
var context_action_panel: Panel
var context_action_icon: TextureRect
var context_action_key: Label
var context_action_text: Label
var hud_hint: Label
var hud_message: Label
var desk_stats: Label
var desk_rows: Array[Dictionary] = []
var desk_page: int = 0
var desk_page_label: Label
var resident_offer_ui: Panel
var customer_bargain_ui: Panel
var customer_bargain_description: Label
var customer_bargain_accept: Button
var resident_offer_description: Label
var resident_offer_accept_button: Button
var resident_offer_decline_button: Button
var desk_upgrade_button: Button
var report_text: Label
var report_title: Label
var title_continue: Button
var message_time: float = 0.0
var result_is_milestone: bool = false
var tutorial_panel: Panel
var tutorial_heading: Label
var tutorial_body: Label
var tutorial_icon: TextureRect
var tutorial_keycap: Label
var desk_tutorial_label: Label
var help_ui: Panel
var help_source: String = "title"
var accessibility_buttons: Array[Button] = []
var new_game_confirm_ui: Panel
var community_finale_seen: bool = false
var community_finale_page: int = 0
var community_finale_ui: Panel
var community_finale_heading: Label
var community_finale_body: Label
var community_finale_progress: Label
var community_finale_next: Button
var community_finale_access: Button
var community_finale_stage: Node3D


func _ready() -> void:
    # Intercept the window X / Alt+F4, not only the in-game Quit button.
    # Otherwise a closing window can lose progress even when the menu path is safe.
    get_tree().set_auto_accept_quit(false)
    rng.randomize()
    _reset_model()
    _load_audio_settings()
    _create_world()
    _create_player()
    _create_audio()
    _create_ui()
    _apply_accessibility()
    _show_splash()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST and not exit_committed and is_inside_tree():
        _quit_desktop()

func _reset_model() -> void:
    cash = 80
    total_sales = 0
    total_revenue = 0
    total_wholesale = 0
    day = 1
    day_clock = 0.0
    day_revenue = 0
    day_cost = 0
    day_sales = 0
    day_visitors = 0
    total_visitors = 0
    day_no_stock = 0
    day_over_budget = 0
    day_unserved_at_close = 0
    total_goal_rewards = 0
    day_goal_awarded = false
    day_consignment_paid = 0
    day_hot_sales = 0
    recovered_save = false
    total_consignment_paid = 0
    daily_history.clear()
    consignment_stock.clear()
    paused = false
    display_level = 0
    carrying = -1
    sold_milestone = false
    community_finale_seen = false
    community_finale_page = 0
    desk_page = 0
    resident_purchases_total = 0
    resident_purchase_spending = 0
    day_event_id = "none"
    last_day_event_id = "none"
    last_day_event_day = -100
    event_days_total = 0
    day_feedback = {"pleased":0,"missing":0,"expensive":0}
    last_customer_appearance = -1
    customer_agreed_price = -1
    customer_bargain_offer = -1
    day_bargain_offers = 0
    day_bargain_accepted = 0
    day_bargain_rejected = 0
    day_assisted_shoppers = 0
    total_assisted_shoppers = 0
    tutorial_active = false
    tutorial_step = TUTORIAL_ACTIONS.size()
    _dismiss_customer()
    _clear_community_finale_stage()
    customer_timer = 4.0
    stock.clear()
    prices.clear()
    supplier_remaining.clear()
    for i in range(PRODUCTS.size()):
        var product: Dictionary = PRODUCTS[i]
        stock.append(0)
        consignment_stock.append(0)
        prices.append(int(product["base"]))
        supplier_remaining.append(_daily_supplier_quota(i))
    _roll_resident_offer()
    if secondhand_events != null:
        secondhand_events.call("reset_state")

func _box(parent: Node3D, location: Vector3, dimensions: Vector3, color: Color, name_tag: String = "", solid: bool = false, metallic: float = 0.0) -> Node3D:
    var holder: Node3D
    if solid:
        var body := StaticBody3D.new()
        var collider := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = dimensions
        collider.shape = shape
        body.add_child(collider)
        holder = body
    else:
        holder = Node3D.new()
    holder.name = name_tag if name_tag != "" else "Prop"
    holder.position = location
    parent.add_child(holder)
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    visual.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metallic
    mat.roughness = 0.78
    visual.material_override = mat
    holder.add_child(visual)
    return holder

func _sphere(parent: Node3D, location: Vector3, size: float, color: Color) -> void:
    var visual := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = size
    mesh.height = size * 2.0
    visual.mesh = mesh
    visual.position = location
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.98
    visual.material_override = mat
    parent.add_child(visual)

func _model(parent: Node3D, filename: String, location: Vector3, size_factor: float = 1.0) -> Node3D:
    var anchor := Node3D.new()
    anchor.position = location
    parent.add_child(anchor)
    if filename == "procedural/foldedClothes":
        # A humble stack of three folded garments, made from native primitive meshes.
        var colors: Array[Color] = [Color("ba9876"), Color("7f9a86"), Color("c1b0b4")]
        for j in range(3):
            _box(anchor, Vector3(0, 0.08 + float(j) * 0.13, 0), Vector3(0.54, 0.12, 0.40), colors[j], "FoldedGarment")
        return anchor
    var asset_path: String = "res://assets/models/%s.glb" % filename
    if filename.begins_with("expanded/"):
        asset_path = "res://assets/expanded_v0153/%s.glb" % filename.trim_prefix("expanded/")
    var resource: Resource = load(asset_path)
    if resource is PackedScene:
        var instance: Node = (resource as PackedScene).instantiate()
        anchor.add_child(instance)
        if instance is Node3D:
            (instance as Node3D).scale = Vector3.ONE * size_factor
    else:
        # Development fallback is only visible if the source model fails to import.
        _box(anchor, Vector3.ZERO, Vector3(0.42, 0.43, 0.42), Color("c28b68"))
    return anchor

func _third_party_character(parent: Node3D, scene_path: String, size_factor: float) -> Node3D:
    var anchor := Node3D.new()
    parent.add_child(anchor)
    if ResourceLoader.exists(scene_path):
        var resource: Resource = load(scene_path)
        if resource is PackedScene:
            var instance: Node = (resource as PackedScene).instantiate()
            anchor.add_child(instance)
            if instance is Node3D:
                (instance as Node3D).scale = Vector3.ONE * size_factor
            return anchor
    _model(anchor, "character-female-a", Vector3.ZERO, 1.0)
    return anchor

func _find_customer_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found: AnimationPlayer = _find_customer_animation_player(child)
        if found != null:
            return found
    return null

func _customer_animation_name(requested: String) -> String:
    if customer_animation_player == null or not is_instance_valid(customer_animation_player):
        return ""
    # Godot may import glTF animations as 'walk' or 'Library/walk'.
    for candidate_name in customer_animation_player.get_animation_list():
        var candidate: String = str(candidate_name)
        if candidate == requested or candidate.ends_with("/" + requested):
            return candidate
    return ""

func _play_customer_animation(requested: String) -> void:
    if customer_animation_player == null or not is_instance_valid(customer_animation_player):
        return
    var animation_name: String = _customer_animation_name(requested)
    if animation_name.is_empty():
        return
    var playing_clip: Animation = customer_animation_player.get_animation(animation_name)
    if playing_clip != null and requested in ["walk", "idle"]:
        # Imported glTF clips are not guaranteed to be flagged as looping.
        # Make movement seamless instead of restarting on every final frame.
        playing_clip.loop_mode = Animation.LOOP_LINEAR
    if customer_animation_state == requested:
        # Short gestures are one-shot, not replayed each frame after completion.
        if requested not in ["walk", "idle"] or customer_animation_player.is_playing():
            return
    customer_animation_state = requested
    customer_animation_player.play(animation_name, 0.15)

func _third_party_decoration(parent: Node3D, scene_path: String, location: Vector3, size_factor: float = 1.0) -> void:
    # Optional visual dressing. Original commerce logic never depends on these assets.
    # If native FBX import is unavailable, this simply leaves the scene unchanged.
    if not ResourceLoader.exists(scene_path):
        return
    var imported_resource: Resource = load(scene_path)
    if not (imported_resource is PackedScene):
        return
    var instance: Node = (imported_resource as PackedScene).instantiate()
    if not (instance is Node3D):
        instance.queue_free()
        return
    parent.add_child(instance)
    (instance as Node3D).position = location
    (instance as Node3D).scale = Vector3.ONE * size_factor

func _make_light(position_3d: Vector3, energy_value: float, range_value: float) -> void:
    var light := OmniLight3D.new()
    light.position = position_3d
    light.light_color = Color("fff0d8")
    light.light_energy = energy_value
    light.omni_range = range_value
    light.shadow_enabled = false
    world.add_child(light)

func _create_world() -> void:
    world = Node3D.new()
    world.name = "ShopEnvironment"
    add_child(world)
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("b6cfce")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("e6e9e0")
    env.ambient_light_energy = 0.82
    shop_environment = env
    environment.environment = env
    world.add_child(environment)
    var sunlight := DirectionalLight3D.new()
    sunlight.rotation_degrees = Vector3(-55, 18, 0)
    sunlight.light_color = Color("fff3dc")
    sunlight.light_energy = 0.95
    sunlight_light = sunlight
    world.add_child(sunlight)
    # Warm walnut plank floor, ivory wall panels and green display niches.
    _box(world, Vector3(0, -0.17, 0), Vector3(17.6, 0.34, 17.6), Color("a57754"), "Floor", true)
    for n in range(31):
        var z_value := -8.5 + float(n) * 0.55
        var brown := Color("ad805e") if n % 4 != 0 else Color("bd8a63")
        _box(world, Vector3(0, 0.006, z_value), Vector3(17.2, 0.014, 0.53), brown, "FloorPlank")
    _box(world, Vector3(-8.65, 1.65, 0), Vector3(0.24, 3.3, 17.5), Color("efe8dc"), "LeftWall", true)
    _box(world, Vector3(8.65, 1.65, 0), Vector3(0.24, 3.3, 17.5), Color("efe8dc"), "RightWall", true)
    _box(world, Vector3(0, 1.65, -8.65), Vector3(17.5, 3.3, 0.24), Color("efe8dc"), "BackWall", true)
    _box(world, Vector3(0, 3.35, 0), Vector3(17.6, 0.16, 17.6), Color("f7f2e9"), "Ceiling")
    for n in range(3):
        _box(world, Vector3(-7.6, 1.75, -5.8 + float(n) * 5.3), Vector3(0.08, 2.75, 3.6), Color("82917b"), "GreenInset")
    _box(world, Vector3(0, 2.65, -8.45), Vector3(6.5, 0.65, 0.05), Color("25302c"), "BackFeature")
    _box(world, Vector3(-6.7, 1.65, 8.64), Vector3(3.9, 3.3, 0.16), Color("efe8dc"), "FrontWallLeft", true)
    _box(world, Vector3(6.7, 1.65, 8.64), Vector3(3.9, 3.3, 0.16), Color("efe8dc"), "FrontWallRight", true)
    # Transparent panes create a recognizable storefront without real-world brands.
    for x_coord in [-4.4, 4.4]:
        var pane := _box(world, Vector3(x_coord, 1.7, 8.59), Vector3(1.3, 2.9, 0.09), Color("afd5d5"), "Window")
        var mesh: MeshInstance3D = pane.get_child(0) as MeshInstance3D
        var mat := StandardMaterial3D.new()
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mat.albedo_color = Color(0.55, 0.79, 0.79, 0.24)
        mat.roughness = 0.16
        mesh.material_override = mat
    _box(world, Vector3(0, 2.65, 8.62), Vector3(3.2, 0.55, 0.14), Color("25302c"), "ShopSign")
    var store_sign := Label3D.new()
    store_sign.name = "StorefrontName"
    store_sign.text = "LITTLE RESALE SHOP"
    store_sign.position = Vector3(0.0, 2.66, 8.77)
    store_sign.font_size = 42
    store_sign.pixel_size = 0.005
    store_sign.modulate = Color("f7e8c9")
    store_sign.outline_size = 0
    world.add_child(store_sign)
    _box(world, Vector3(0, 0.01, 6.5), Vector3(2.4, 0.05, 1.4), Color("536357"), "EntranceMat")
    _box(world, Vector3(0, 3.0, 8.7), Vector3(0.12, 0.6, 0.28), Color("bea16e"), "SignHighlight")
    _make_light(Vector3(-4.7, 3.02, -3.0), 1.15, 10.4)
    _make_light(Vector3(4.7, 3.02, 1.8), 1.15, 10.4)
    _make_light(Vector3(0, 3.02, 5.0), 0.95, 10.4)
    var checkout_counter: Node3D = _box(world, Vector3(4.0, 0.68, 5.3), Vector3(3.2, 1.3, 1.25), Color("8b634b"), "CashRegisterCounter", true)
    checkout_counter.set_meta("kind", "desk")
    # In-world access to the same management screen; TAB remains an accessibility shortcut.
    var counter_sign := Label3D.new()
    counter_sign.name = "CounterInteractHint"
    counter_sign.text = "[E]  $  SHOP DESK"
    counter_sign.position = Vector3(4.0, 2.08, 5.3)
    counter_sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    counter_sign.font_size = 36
    counter_sign.pixel_size = 0.005
    counter_sign.modulate = Color("f4e5c8")
    world.add_child(counter_sign)
    _box(world, Vector3(4.0, 1.38, 5.3), Vector3(3.33, 0.13, 1.36), Color("f0e5d2"), "CounterTop")
    _model(world, "computerScreen", Vector3(4.2, 1.51, 5.15), 1.5)
    _model(world, "pottedPlant", Vector3(5.1, 0, 3.0), 1.65)
    _model(world, "tableCoffee", Vector3(-2.6, 0, 3.6), 2.8)
    _model(world, "chair", Vector3(-1.7, 0, 3.9), 1.95)
    _model(world, "rugRectangle", Vector3(-2.8, 0.015, 3.6), 1.9)
    # v0.14.4: reuse already bundled Kenney CC0 props for a lived-in resale shop.
    # Visual-only dressings are kept near walls, away from the central customer aisle.
    _model(world, "bookcaseOpen", Vector3(-7.95, 0.0, -8.03), 1.9)
    _model(world, "cardboardBoxClosed", Vector3(7.55, 0.0, -7.85), 3.0)
    _model(world, "desk", Vector3(-7.90, 0.0, 6.05), 1.7)
    _model(world, "plantSmall1", Vector3(7.85, 0.0, 7.10), 4.2)
    # v0.14.5: imported CC0 FBX visual props; non-colliding and guarded against import failure.
    _third_party_decoration(world, "res://assets/third_party/homely_house/bench_A.fbx", Vector3(-5.8, 0.0, 11.3), 1.3) # 商店外长椅
    _third_party_decoration(world, "res://assets/third_party/homely_house/doormat.fbx", Vector3(0.0, 0.05, 9.1), 1.4) # 商店门垫
    _third_party_decoration(world, "res://assets/third_party/homely_house/mailbox.fbx", Vector3(6.8, 0.03, 11.0), 1.3) # 店外邮筒
    _third_party_decoration(world, "res://assets/third_party/homely_house/package.fbx", Vector3(7.5, 0.06, -6.4), 1.4) # 店内货物纸包
    _third_party_decoration(world, "res://assets/third_party/pretty_park/bush.fbx", Vector3(7.5, 0.0, 13.0), 1.6) # 街边绿植
    _third_party_decoration(world, "res://assets/third_party/pretty_park/flower_A.fbx", Vector3(-7.5, 0.0, 12.4), 1.4) # 街边花卉
    _third_party_decoration(world, "res://assets/third_party/restaurant_bits/crate.fbx", Vector3(7.4, 0.02, -5.5), 1.6) # 商店货箱
    # v0.14.6: new CC0 Kenney glTF/GLB visual pass (not sellable items).
    # Every position is provisional until a native engine screenshot and collision pass.
    _third_party_decoration(world, "res://assets/third_party_kenney/mini_arcade/cash-register.glb", Vector3(3.0, 1.50, 5.08), 1.0)
    _third_party_decoration(world, "res://assets/third_party_kenney/city_suburban/planter.glb", Vector3(-4.0, 0.01, 10.75), 1.0)
    _third_party_decoration(world, "res://assets/third_party_kenney/city_suburban/planter.glb", Vector3(4.0, 0.01, 10.75), 1.0)
    _third_party_decoration(world, "res://assets/third_party_kenney/factory/box-small.glb", Vector3(7.25, 0.01, -7.15), 1.0)
    _third_party_decoration(world, "res://assets/third_party_kenney/prototype/crate.glb", Vector3(-6.9, 0.01, -7.2), 0.85)
    _third_party_decoration(world, "res://assets/third_party_kenney/building/column-thin.glb", Vector3(-5.80, 0.03, 8.77), 1.2)
    _third_party_decoration(world, "res://assets/third_party_kenney/building/column-thin.glb", Vector3(5.80, 0.03, 8.77), 1.2)
    # v0.14.7: curated CC0 resale-shop set dressing. Decorative only; no gameplay collisions.
    # Nine display slots persist, with a 27-SKU catalogue added in v0.15.3.
    _third_party_decoration(world, "res://assets/curated_v0147/mini_shop/clothing-rack.glb", Vector3(-7.7, 0.02, 1.90), 2.0)
    _third_party_decoration(world, "res://assets/curated_v0147/mini_shop/mannequin.glb", Vector3(-5.2, 0.02, 5.85), 2.3)
    _third_party_decoration(world, "res://assets/curated_v0147/mini_shop/shopping-basket.glb", Vector3(-4.0, 0.02, 5.5), 0.85)
    _third_party_decoration(world, "res://assets/curated_v0147/mini_shop/shelf-bags.glb", Vector3(7.80, 0.02, -6.6), 2.0)
    _third_party_decoration(world, "res://assets/curated_v0147/mini_shop/hand-truck.glb", Vector3(7.8, 0.02, -5.15), 2.4)
    _third_party_decoration(world, "res://assets/curated_v0147/furniture/coatRackStanding.glb", Vector3(-7.65, 0.02, 2.85), 2.2)
    # v0.15.0: single storefront canopy; no game logic attached to decoration.
    _third_party_decoration(world, "res://assets/selected_v015/urban/detail-awning-wide.glb", Vector3(0.0, 2.93, 8.88), 2.3)
    # Outdoor reference: sidewalk and trees are original primitive geometry.
    _box(world, Vector3(0, -0.25, 12.7), Vector3(19, 0.36, 6.0), Color("c6beb0"), "Sidewalk", true)
    _box(world, Vector3(0, -0.35, 17), Vector3(28, 0.25, 4.7), Color("59605e"), "Road")
    for xpos in [-8.0, 8.0]:
        _box(world, Vector3(xpos, 1.5, 13.8), Vector3(0.23, 3.0, 0.23), Color("7c624b"), "StreetTree")
        for off in [-0.55,0,0.55]:
            _sphere(world, Vector3(xpos+off, 3.2, 13.8), 0.85, Color("86aa71"))
    _create_shelves()
    _update_display_decor()

func _create_shelves() -> void:
    for i in range(SHELF_POINTS.size()):
        var body := StaticBody3D.new()
        body.name = "ProductShelf_%02d" % (i+1)
        body.position = SHELF_POINTS[i]
        if i >= 6:
            body.rotation.y = -PI / 2.0
        elif i >= 3:
            body.rotation.y = PI / 2.0
        body.set_meta("item_index", i)
        body.set_meta("kind", "shelf")
        world.add_child(body)
        var collider := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = Vector3(2.1, 1.9, 0.8)
        collider.shape = shape
        body.add_child(collider)
        _box(body, Vector3.ZERO, Vector3(2.06, 1.86, 0.73), Color("82917b"), "ShelfFrame")
        for h in [-0.69,-0.03,0.63]:
            _box(body, Vector3(0, h, 0.45), Vector3(1.91, 0.09, 1.04), Color("bea16e"), "ShelfBoard")
        _box(body, Vector3(0, 0.95, 0.12), Vector3(2.05, 0.12, 0.75), Color("25302c"), "ShelfTop")
        var tag := Label3D.new()
        tag.name = "ProductSign"
        tag.text = str(SHELF_LABELS[i])
        tag.font_size = 36
        tag.pixel_size = 0.0055
        tag.position = Vector3(0, 1.11, 0.23)
        tag.modulate = Color("f8f2e5")
        body.add_child(tag)
        var visuals := Node3D.new()
        visuals.name = "StockVisuals"
        body.add_child(visuals)
        product_visuals.append(visuals)
        var placard := Label3D.new()
        placard.name = "PriceAndStock"
        placard.position = Vector3(0, 0.03, 0.91)
        placard.font_size = 28
        placard.pixel_size = 0.006
        placard.modulate = Color("f6f0d5")
        body.add_child(placard)
        price_tags.append(placard)
        shelves.append(body)
    for i in range(SHELF_POINTS.size()):
        _refresh_shelf(i)
    stock_wayfinder = Label3D.new()
    stock_wayfinder.name = "CarriedItemTargetSign"
    stock_wayfinder.text = "▼\nE · PLACE"
    stock_wayfinder.font_size = 36
    stock_wayfinder.pixel_size = 0.005
    stock_wayfinder.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    stock_wayfinder.outline_size = 14
    stock_wayfinder.modulate = Color("ffefbd")
    stock_wayfinder.no_depth_test = false
    stock_wayfinder.visible = false
    world.add_child(stock_wayfinder)

func _product_shelf(index: int) -> int:
    return posmod(index, SHELF_POINTS.size())

func _shelf_inventory_count(slot: int) -> int:
    var count: int = 0
    for i in range(PRODUCTS.size()):
        if _product_shelf(i) == slot:
            count += stock[i]
    return count

func _shelf_focus(slot: int) -> int:
    # Prefer something the customer can buy, or the original base item.
    for i in range(PRODUCTS.size()):
        if _product_shelf(i) == slot and stock[i] > 0:
            return i
    return slot

func _refresh_shelf(index: int) -> void:
    var slot: int = _product_shelf(index)
    if slot >= product_visuals.size():
        return
    var holder: Node3D = product_visuals[slot]
    for item in holder.get_children():
        item.queue_free()
    var total: int = _shelf_inventory_count(slot)
    var focus: int = _shelf_focus(slot)
    if slot < price_tags.size():
        if total == 0:
            price_tags[slot].text = "0/%d  ·  EMPTY" % SHELF_CAPACITY
        elif total == stock[focus]:
            # Preserve the familiar single-SKU price tag for old save files.
            price_tags[slot].text = "$%d   |   %d/%d" % [prices[focus], total, SHELF_CAPACITY]
        else:
            price_tags[slot].text = "%d/%d  ·  FROM $%d" % [total, SHELF_CAPACITY, min_price_at_shelf(slot)]
    var offset: int = 0
    for sku in range(PRODUCTS.size()):
        if _product_shelf(sku) != slot:
            continue
        for unit in range(stock[sku]):
            if offset >= SHELF_CAPACITY:
                break
            var x: float = -0.57 + float(offset % 3) * 0.57
            var y: float = (-0.62 if offset >= 3 else 0.04)
            var fitted_scale: float = float(PRODUCTS[sku]["scale"]) * float(DISPLAY_FIT_FACTORS.get(sku, 1.0))
            _model(holder, str(PRODUCTS[sku]["model"]), Vector3(x, y, 0.71), fitted_scale)
            offset += 1

func min_price_at_shelf(slot: int) -> int:
    var lowest: int = 999
    for i in range(PRODUCTS.size()):
        if _product_shelf(i) == slot and stock[i] > 0:
            lowest = mini(lowest, prices[i])
    return lowest

func _roll_day_event() -> void:
    # First two days are guaranteed calm for new players. Only one event can
    # occur per day; a minimum gap stops surprise-event fatigue.
    day_event_id = "none"
    if day < 3 or day - last_day_event_day < EVENT_MIN_GAP_DAYS:
        return
    if rng.randf() >= DAILY_EVENT_CHANCE:
        return
    var possibilities: Array[String] = []
    for candidate in DAY_EVENT_IDS:
        if candidate != last_day_event_id:
            possibilities.append(candidate)
    if possibilities.is_empty():
        return
    day_event_id = possibilities[rng.randi_range(0, possibilities.size() - 1)]
    last_day_event_id = day_event_id
    last_day_event_day = day
    event_days_total += 1

func _day_event_description() -> String:
    return str(DAY_EVENT_TITLES.get(day_event_id, DAY_EVENT_TITLES["none"]))

func _customer_arrival_time() -> float:
    var interval: float = rng.randf_range(6.5, 11.0)
    if secondhand_events != null:
        interval *= float(secondhand_events.call("visitor_interval_factor"))
    if day_event_id == "rain":
        return interval * 1.45
    if day_event_id == "neighbour_tip":
        return interval * 0.75
    return interval

func _daily_supplier_quota(index: int) -> int:
    # Small second-hand delivery batches; no endlessly replenished unique vintage pieces.
    # Legacy catalogue keeps a larger quota so the early-game economy still works.
    if index < SHELF_POINTS.size():
        return BASE_SUPPLIER_QUOTA
    var quota: int = 1 + posmod(index * 7 + day, 2)
    if day_event_id == "delivery_delay":
        return maxi(0, quota - 1)
    if day_event_id == "donation_day":
        return quota + 1
    return quota

func _supplier_available(index: int) -> bool:
    if index < 0 or index >= PRODUCTS.size() or supplier_remaining.size() != PRODUCTS.size():
        return false
    if supplier_remaining[index] <= 0:
        return false
    # Uncommon second-hand finds are not available from every supplier every day.
    return index < SHELF_POINTS.size() or posmod(index + day, SUPPLIER_ROTATION) != 0

func _supplier_cost(index: int) -> int:
    var original: int = int(PRODUCTS[index]["cost"])
    if index < SHELF_POINTS.size():
        return original
    var condition: String = str(PRODUCTS[index].get("condition", "Good"))
    var multiplier: float = 0.84 if condition == "Well-Loved" else (1.22 if condition == "Excellent" else 1.0)
    return maxi(1, roundi(float(original) * multiplier))

func _roll_resident_offer() -> void:
    # The first day focuses on learning the shop; one local seller may visit
    # from day two onward. The offer is deterministic for a given day/progress
    # and the exact offer is persisted, so reloads cannot reroll for profit.
    resident_offer_index = -1
    resident_offer_cost = 0
    resident_offer_decided = false
    if day < 2:
        return
    var candidates: Array[int] = []
    for i in range(PRODUCTS.size()):
        if total_sales >= int(PRODUCTS[i]["unlock"]):
            candidates.append(i)
    if candidates.is_empty():
        return
    resident_offer_index = candidates[posmod(day * 7 + total_sales * 3, candidates.size())]
    var regular_cost: int = _supplier_cost(resident_offer_index)
    var discount: float = 0.63 + float(posmod(day + resident_offer_index * 3, 4)) * 0.06
    resident_offer_cost = clampi(roundi(float(regular_cost) * discount), 1, regular_cost)

func _resident_offer_available() -> bool:
    return day >= 2 and resident_offer_index >= 0 and resident_offer_index < PRODUCTS.size() and not resident_offer_decided

func _catalog_index(row: int) -> int:
    return desk_page * CATALOG_PAGE_SIZE + row

func _change_catalog_page(direction: int) -> void:
    desk_page = clampi(desk_page + direction, 0, ceili(float(PRODUCTS.size()) / float(CATALOG_PAGE_SIZE)) - 1)
    _play_click()
    _refresh_ui()

func _update_display_decor() -> void:
    for node in display_elements:
        node.queue_free()
    display_elements.clear()
    for lvl in range(display_level):
        var position_3d := Vector3(-4.5 + float(lvl) * 4.5, 2.8, -7.7)
        var node := _box(world, position_3d, Vector3(2.1, 0.11, 0.25), Color("bea16e"), "UpgradeLamp")
        display_elements.append(node)

func _create_player() -> void:
    player = CharacterBody3D.new()
    player.name = "ShopOwner"
    player.position = Vector3(0, 0.10, 5.2)
    add_child(player)
    var collider := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.30
    shape.height = 1.70
    collider.shape = shape
    collider.position.y = 0.86
    player.add_child(collider)
    head = Node3D.new()
    head.position.y = 1.55
    player.add_child(head)
    camera = Camera3D.new()
    camera.current = true
    camera.fov = 74.0
    head.add_child(camera)
    ray = RayCast3D.new()
    ray.target_position = Vector3(0, 0, -4.6)
    camera.add_child(ray)
    held_item = Node3D.new()
    held_item.position = Vector3(0.58, -0.45, -0.88)
    held_item.visible = false
    camera.add_child(held_item)

func _create_audio() -> void:
    audio_music = AudioStreamPlayer.new()
    audio_music.stream = load(BG_MUSIC)
    if audio_music.stream is AudioStreamOggVorbis:
        (audio_music.stream as AudioStreamOggVorbis).loop = true
    audio_music.bus = "Master"
    add_child(audio_music)
    audio_click = AudioStreamPlayer.new()
    audio_click.stream = load("res://assets/selected_v015/audio/click_001.ogg")
    add_child(audio_click)
    audio_sale = AudioStreamPlayer.new()
    audio_sale.stream = load("res://assets/audio/ui_3.ogg")
    add_child(audio_sale)
    # Four new short, CC0 environmental effects. Loaded only into the same Godot runtime.
    for footstep_path in ["res://assets/curated_v0147/audio/footstep_wood_000.ogg", "res://assets/curated_v0147/audio/footstep_wood_001.ogg"]:
        var footstep_resource: Resource = load(footstep_path)
        if footstep_resource is AudioStream:
            footstep_streams.append(footstep_resource as AudioStream)
    audio_footstep = AudioStreamPlayer.new()
    if not footstep_streams.is_empty():
        audio_footstep.stream = footstep_streams[0]
    add_child(audio_footstep)
    audio_entry_bell = AudioStreamPlayer.new()
    audio_entry_bell.stream = load("res://assets/curated_v0147/audio/impactBell_heavy_000.ogg")
    add_child(audio_entry_bell)
    audio_stock = AudioStreamPlayer.new()
    audio_stock.stream = load("res://assets/curated_v0147/audio/impactGeneric_light_000.ogg")
    add_child(audio_stock)
    _apply_audio()

func _apply_audio() -> void:
    if audio_music != null:
        audio_music.volume_db = linear_to_db(maxf(0.001, music_volume * master_volume * 0.28))
    if audio_click != null:
        audio_click.volume_db = linear_to_db(maxf(0.001, sfx_volume * master_volume * 0.42))
    if audio_sale != null:
        audio_sale.volume_db = linear_to_db(maxf(0.001, sfx_volume * master_volume * 0.46))
    if audio_footstep != null:
        audio_footstep.volume_db = linear_to_db(maxf(0.001, sfx_volume * master_volume * 0.16))
    if audio_entry_bell != null:
        audio_entry_bell.volume_db = linear_to_db(maxf(0.001, sfx_volume * master_volume * 0.28))
    if audio_stock != null:
        audio_stock.volume_db = linear_to_db(maxf(0.001, sfx_volume * master_volume * 0.26))

func _play_click() -> void:
    # Native headless QA validates stream availability but cannot verify audible playback.
    # Do not leave live OGG playback objects behind when the test SceneTree exits.
    if audio_click != null and not qa_mode:
        audio_click.play()

func _play_sale() -> void:
    if audio_sale != null and not qa_mode:
        audio_sale.play()

func _play_stock_sound() -> void:
    if audio_stock != null and audio_stock.stream != null and not qa_mode:
        audio_stock.play()

func _play_entry_bell() -> void:
    if audio_entry_bell != null and audio_entry_bell.stream != null and not qa_mode:
        audio_entry_bell.play()

func _update_footsteps(delta: float, is_moving: bool) -> void:
    # Audio is driven by actual floor movement and respects the existing SFX slider.
    # Headless QA has no real playback hardware; streams are still loaded and validated.
    if qa_mode:
        footstep_elapsed = 0.0
        return
    if not is_moving or footstep_streams.is_empty():
        footstep_elapsed = 0.0
        return
    footstep_elapsed -= delta
    if footstep_elapsed <= 0.0 and audio_footstep != null:
        audio_footstep.stream = footstep_streams[footstep_index % footstep_streams.size()]
        audio_footstep.play()
        footstep_index += 1
        footstep_elapsed = 0.48

func _create_ui() -> void:
    # Menu cursor only; Godot automatically hides it while mouse is captured in-game.
    # No third-party typography or external service dependency is added.
    var cursor_resource: Resource = load("res://assets/third_party_kenney/ui/cursor_toon.png")
    if cursor_resource is Texture2D:
        Input.set_custom_mouse_cursor(cursor_resource as Texture2D, Input.CURSOR_ARROW, Vector2(4, 3))
    ui_layer = CanvasLayer.new()
    add_child(ui_layer)
    var ui_root := Control.new()
    ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui_layer.add_child(ui_root)
    # The fullscreen UI canvas must not consume look/click events intended for
    # first-person gameplay. Interactive child buttons remain clickable.
    ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud_ui = Control.new()
    hud_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui_root.add_child(hud_ui)
    hud_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var top := _panel(hud_ui, Vector2(16, 16), Vector2(766, 105), Color(0.08,0.16,0.14,0.90))
    top.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud_status = _text(top, Vector2(14, 12), Vector2(735, 85), 22, Color("f9f5e9"))
    var help := _panel(hud_ui, Vector2(16, 131), Vector2(850, 78), Color(0.07,0.16,0.15,0.82))
    hud_help_panel = help
    help.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud_hint = _text(help, Vector2(13, 12), Vector2(818, 60), 18, Color("f5edda"))
    var bottom := _panel(hud_ui, Vector2(16, 631), Vector2(1248, 74), Color(0.08,0.15,0.14,0.91))
    hud_bottom_panel = bottom
    bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud_message = _text(bottom, Vector2(13, 10), Vector2(1220, 58), 19, Color("e6d3a0"))
    var cross := _text(hud_ui, Vector2(625, 345), Vector2(28, 28), 28, Color("fcfaf6"))
    cross.text = "+"
    _create_context_action_hint(hud_ui)
    _create_picture_guides(hud_ui)
    _create_title_ui(ui_root)
    _create_desk_ui(ui_root)
    _create_resident_offer_ui(ui_root)
    _create_customer_bargain_ui(ui_root)
    _create_report_ui(ui_root)
    _create_day_end_confirm_ui(ui_root)
    _create_community_finale_ui(ui_root)
    _create_ledger_ui(ui_root)
    _create_pause_ui(ui_root)
    _create_credits_ui(ui_root)
    _create_settings_ui(ui_root)
    _create_help_ui(ui_root)
    _create_tutorial_ui(ui_root)
    _create_new_game_confirm_ui(ui_root)
    _create_splash_ui(ui_root)
    healthy_play = HEALTHY_PLAY_SCRIPT.new() as Control
    healthy_play.call("configure", self)
    ui_root.add_child(healthy_play)
    privacy_safety = PRIVACY_SAFETY_SCRIPT.new() as Control
    privacy_safety.call("configure", self)
    ui_root.add_child(privacy_safety)
    secondhand_events = SECONDHAND_EVENTS_SCRIPT.new() as Control
    secondhand_events.call("configure", self)
    ui_root.add_child(secondhand_events)
    secondhand_events.set("entry_button", story_entry_button)
    secondhand_events.call("refresh_entry")
    hud_ui.visible = false

func _create_context_action_hint(parent: Node) -> void:
    # Picture + one key + short caption. Anchored above the existing message bar.
    # Static colors: no pulses, timed flashes or screen-covering overlays.
    context_action_panel = _panel(parent, Vector2(440, 526), Vector2(400, 82), Color(0.065, 0.13, 0.11, 0.92))
    context_action_panel.anchor_left = 0.5
    context_action_panel.anchor_right = 0.5
    context_action_panel.offset_left = -200.0
    context_action_panel.offset_right = 200.0
    context_action_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    context_action_icon = TextureRect.new()
    context_action_icon.position = Vector2(12, 11)
    context_action_icon.size = Vector2(60, 60)
    context_action_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    context_action_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    context_action_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    context_action_panel.add_child(context_action_icon)
    context_action_key = _text(context_action_panel, Vector2(87, 7), Vector2(305, 32), 23, Color("fff2cd"))
    context_action_text = _text(context_action_panel, Vector2(87, 42), Vector2(300, 34), 16, Color("f1f0dd"))
    context_action_panel.visible = false

func _near_matching_shelf() -> bool:
    # Do not require pixel-perfect first-person aiming: approaching the right
    # shelf is enough, but never auto-stock from the counter or across the shop.
    if carrying < 0 or carrying >= PRODUCTS.size() or player == null:
        return false
    var slot: int = _product_shelf(carrying)
    if slot < 0 or slot >= shelves.size():
        return false
    var origin: Vector3 = player.global_position
    var target: Vector3 = shelves[slot].global_position
    return Vector2(origin.x, origin.z).distance_to(Vector2(target.x, target.z)) <= 2.25

func _refresh_context_action_hint() -> void:
    if context_action_panel == null:
        return
    if stock_wayfinder != null:
        var show_target: bool = playing and picture_guides and carrying >= 0 and not desk_ui.visible and not pause_ui.visible and not report_ui.visible and not help_ui.visible and not settings_ui.visible and not community_finale_ui.visible and not resident_offer_ui.visible and not customer_bargain_ui.visible and not ledger_ui.visible
        stock_wayfinder.visible = show_target
        if show_target:
            stock_wayfinder.position = SHELF_POINTS[_product_shelf(carrying)] + Vector3(0.0, 1.85, 0.0)
            stock_wayfinder.modulate = Color.WHITE if high_contrast else Color("ffefbd")
    context_action_panel.visible = false
    if not playing or not picture_guides or desk_ui.visible or paused or report_ui.visible or help_ui.visible or settings_ui.visible or ledger_ui.visible or community_finale_ui.visible or resident_offer_ui.visible or customer_bargain_ui.visible:
        return
    var icon_number: int = -1
    var key_line: String = ""
    var detail: String = ""
    if customer_phase == "needs_help" and _player_can_assist_customer():
        icon_number = 2
        key_line = "E   HELP"
        detail = "Offer a stocked alternative"
    elif _looking_at_counter():
        icon_number = 0
        key_line = "E   SHOP DESK"
        detail = "Buy · price · manage goods"
    elif carrying >= 0:
        icon_number = 1
        if _near_matching_shelf():
            key_line = "E   PLACE HERE"
            detail = "Put the item on this shelf"
        else:
            key_line = "▼   FIND SHELF"
            detail = "Follow the sign to place your item"
    elif _looked_shelf() >= 0:
        icon_number = 1
        key_line = "+ / −   PRICE"
        detail = "Change this shelf item's price"
    if icon_number < 0:
        return
    context_action_icon.texture = load("res://assets/ui_guides/guide_%d.png" % icon_number)
    context_action_key.text = key_line
    context_action_text.text = detail
    context_action_panel.visible = true

func _create_picture_guides(parent: Node) -> void:
    # Four static pictograms, not flashing prompts. Text is supplementary.
    pictogram_panel = _panel(parent, Vector2(0, 14), Vector2(350, 142), Color(0.055,0.14,0.12,0.92))
    pictogram_panel.anchor_left = 1.0
    pictogram_panel.anchor_right = 1.0
    pictogram_panel.offset_left = -366
    pictogram_panel.offset_right = -16
    pictogram_panel.offset_top = 14
    pictogram_panel.offset_bottom = 156
    pictogram_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    for icon_id in range(4):
        var image := TextureRect.new()
        image.texture = load("res://assets/ui_guides/guide_%d.png" % icon_id)
        image.position = Vector2(20 + icon_id * 83, 8)
        image.size = Vector2(42, 42)
        image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        # The source pictograms are 96x96. Scale explicitly into the 42px slot;
        # keep-aspect rendering left their native size over the status captions.
        image.stretch_mode = TextureRect.STRETCH_SCALE
        image.mouse_filter = Control.MOUSE_FILTER_IGNORE
        pictogram_panel.add_child(image)
        image.size = Vector2(42, 42)
        pictogram_icons.append(image)
        var caption := _text(pictogram_panel, Vector2(8 + icon_id * 83, 54), Vector2(75, 32), 11, Color("f5ecde"))
        caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        caption.autowrap_mode = TextServer.AUTOWRAP_OFF
        # Two-line captions stay within each 83px cell at both 720p and 1080p.
        caption.text = ["BUY\nOK", "PLACE\nWAIT", "SELL\nWAIT", "DAY\nOK"][icon_id]
        pictogram_labels.append(caption)
    pictogram_event = _text(pictogram_panel, Vector2(11, 115), Vector2(328, 22), 12, Color("f6e3ba"))
    pictogram_event.text = "QUIET SHOP DAY"

func _refresh_picture_guides() -> void:
    if pictogram_panel == null:
        return
    pictogram_panel.visible = picture_guides
    if not picture_guides:
        return
    var enabled: Array[bool] = [carrying < 0, carrying >= 0, customer_phase != "idle", true]
    for index in range(pictogram_icons.size()):
        pictogram_icons[index].modulate = Color.WHITE if enabled[index] else Color(0.60,0.65,0.61,0.65)
        # Ready/WAIT words accompany icon opacity; no gameplay cue relies on
        # green-versus-red or a color-only change.
        var action: String = ["BUY", "PLACE", "SELL", "DAY"][index]
        pictogram_labels[index].text = action + ("\nOK" if enabled[index] else "\nWAIT")
    var small_labels: Dictionary = {"none":"CALM DAY", "rain":"RAIN · SLOWER VISITS", "delivery_delay":"DELIVERY LATE", "neighbour_tip":"LOCAL RECOMMENDATION", "donation_day":"DONATIONS TODAY"}
    pictogram_event.text = str(small_labels.get(day_event_id, "CALM DAY"))

func _panel(parent: Node, at: Vector2, size_2d: Vector2, color: Color) -> Panel:
    var panel := Panel.new()
    panel.position = at
    panel.custom_minimum_size = size_2d
    panel.size = size_2d
    var box := StyleBoxFlat.new()
    box.bg_color = color
    box.corner_radius_top_left = 10
    box.corner_radius_top_right = 10
    box.corner_radius_bottom_left = 10
    box.corner_radius_bottom_right = 10
    box.content_margin_left = 0
    box.content_margin_right = 0
    box.content_margin_top = 0
    box.content_margin_bottom = 0
    panel.add_theme_stylebox_override("panel", box)
    panel.set_meta("ui_original_background", color)
    parent.add_child(panel)
    return panel

func _text(parent: Node, at: Vector2, size_2d: Vector2, font_size: int, tint: Color) -> Label:
    var lab := Label.new()
    lab.position = at
    lab.size = size_2d
    lab.add_theme_color_override("font_color", tint)
    lab.add_theme_font_size_override("font_size", font_size)
    lab.set_meta("ui_original_font_size", font_size)
    lab.set_meta("ui_original_color", tint)
    lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(lab)
    return lab

func _button(parent: Node, label_text: String, at: Vector2, size_2d: Vector2, on_press: Callable) -> Button:
    var b := Button.new()
    b.text = label_text
    b.position = at
    b.custom_minimum_size = size_2d
    b.size = size_2d
    b.add_theme_font_size_override("font_size", 18)
    b.add_theme_color_override("font_color", Color("ffffff"))
    b.add_theme_color_override("font_hover_color", Color("ffffff"))
    b.add_theme_color_override("font_pressed_color", Color("ffffff"))
    b.tooltip_text = label_text
    b.set_meta("ui_original_font_size", 18)
    var normal_style := StyleBoxFlat.new()
    normal_style.bg_color = Color("376655")
    normal_style.set_corner_radius_all(8)
    normal_style.set_border_width_all(1)
    normal_style.border_color = Color("819b7b")
    b.add_theme_stylebox_override("normal", normal_style)
    var hover_style := normal_style.duplicate() as StyleBoxFlat
    hover_style.bg_color = Color("508a70")
    b.add_theme_stylebox_override("hover", hover_style)
    var pressed_style := normal_style.duplicate() as StyleBoxFlat
    pressed_style.bg_color = Color("27473e")
    b.add_theme_stylebox_override("pressed", pressed_style)
    # Disabled and keyboard-focused controls must be visually distinct,
    # especially for first-time and older players.
    var disabled_style := normal_style.duplicate() as StyleBoxFlat
    disabled_style.bg_color = Color("39473e")
    disabled_style.border_color = Color("69736a")
    b.add_theme_stylebox_override("disabled", disabled_style)
    b.add_theme_color_override("font_disabled_color", Color("b3b7ae"))
    var focus_style := StyleBoxFlat.new()
    focus_style.bg_color = Color(0, 0, 0, 0)
    focus_style.set_border_width_all(3)
    focus_style.border_color = Color("f4d186")
    focus_style.set_corner_radius_all(10)
    b.add_theme_stylebox_override("focus", focus_style)
    # Preserve original soft green styles so the high-contrast toggle is reversible.
    b.set_meta("ui_original_button_styles", {
        "normal": normal_style.duplicate(),
        "hover": hover_style.duplicate(),
        "pressed": pressed_style.duplicate(),
        "disabled": disabled_style.duplicate()
    })
    b.focus_mode = Control.FOCUS_ALL
    parent.add_child(b)
    b.pressed.connect(on_press)
    return b

func _focus_menu_controls(menu: Control, preferred_text: String = "") -> void:
    # Explicit Godot keyboard focus avoids relying on unstable automatic guessing.
    # The visible panel owns Tab / Shift+Tab; this never remaps gameplay keys.
    if menu == null or not menu.visible or not menu.is_inside_tree():
        return
    var focusables: Array[Control] = []
    for item in menu.get_children():
        if item is Control:
            var control: Control = item as Control
            if not control.visible or control.focus_mode == Control.FOCUS_NONE:
                continue
            if control is BaseButton and (control as BaseButton).disabled:
                continue
            focusables.append(control)
    if focusables.is_empty():
        return
    focusables.sort_custom(func(a: Control, b: Control) -> bool:
        if absf(a.position.y - b.position.y) <= 8.0:
            return a.position.x < b.position.x
        return a.position.y < b.position.y
    )
    for index in range(focusables.size()):
        var control: Control = focusables[index]
        control.focus_next = control.get_path_to(focusables[(index + 1) % focusables.size()])
        control.focus_previous = control.get_path_to(focusables[(index - 1 + focusables.size()) % focusables.size()])
    var target: Control = focusables[0]
    if not preferred_text.is_empty():
        for candidate in focusables:
            if candidate is Button and (candidate as Button).text == preferred_text:
                target = candidate
                break
    target.grab_focus()

func _center_panel(panel: Panel) -> void:
    # Center modal menus independently from screen resolution or aspect ratio.
    # Child buttons retain their coordinates relative to the centered panel.
    var width: float = panel.size.x
    var height: float = panel.size.y
    panel.anchor_left = 0.5
    panel.anchor_right = 0.5
    panel.anchor_top = 0.5
    panel.anchor_bottom = 0.5
    panel.offset_left = -width * 0.5
    panel.offset_right = width * 0.5
    panel.offset_top = -height * 0.5
    panel.offset_bottom = height * 0.5

func _create_title_ui(parent: Node) -> void:
    title_ui = _panel(parent, Vector2(355, 65), Vector2(570, 590), Color(0.055,0.12,0.11,0.97))
    _center_panel(title_ui)
    # Working name only: creator-selected candidate, NOT a registered or legally cleared mark.
    var internal_mark := _text(title_ui, Vector2(96, 27), Vector2(378, 150), 33, Color("e7c993"))
    internal_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    internal_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    internal_mark.text = "OLD THINGS,\nNEW DAYS"
    var headline := _text(title_ui, Vector2(56, 204), Vector2(468, 70), 27, Color("f4eee1"))
    headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    headline.text = "A COZY SECONDHAND SHOP"
    var subtitle := _text(title_ui, Vector2(80, 268), Vector2(420, 32), 16, Color("d1be8e"))
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.text = "Little Cozy Games · development preview"
    var start_icon := TextureRect.new()
    start_icon.texture = load("res://assets/selected_v015/ui/icon_checkmark.png")
    start_icon.position = Vector2(105, 331)
    start_icon.size = Vector2(34, 34)
    start_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    start_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    title_ui.add_child(start_icon)
    _button(title_ui, "NEW GAME", Vector2(144, 325), Vector2(283, 46), _request_new_game)
    var continue_icon := TextureRect.new()
    continue_icon.texture = load("res://assets/selected_v015/ui/icon_circle.png")
    continue_icon.position = Vector2(107, 391)
    continue_icon.size = Vector2(30, 30)
    continue_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    title_ui.add_child(continue_icon)
    title_continue = _button(title_ui, "CONTINUE", Vector2(144, 381), Vector2(283, 46), _continue_game)
    _button(title_ui, "CREDITS / LICENCES", Vector2(144, 437), Vector2(283, 46), _show_credits)
    _button(title_ui, "AUDIO + ACCESSIBILITY", Vector2(144, 490), Vector2(283, 40), _open_settings_menu)
    _button(title_ui, "CONTROLS / HOW TO PLAY", Vector2(144, 535), Vector2(283, 38), _open_help)
    _button(title_ui, "PLAY TIME", Vector2(20, 537), Vector2(120, 35), _open_healthy_play)
    var safety_entry: Button = _button(title_ui, "SAFETY", Vector2(20, 490), Vector2(120, 37), _open_privacy_safety)
    safety_entry.tooltip_text = "Privacy, family safety and local save controls"
    var exit_button: Button = _button(title_ui, "QUIT GAME", Vector2(431, 538), Vector2(130, 33), _quit_desktop)
    exit_button.tooltip_text = "Save and quit to desktop"

func _create_desk_ui(parent: Node) -> void:
    desk_ui = _panel(parent, Vector2(168, 28), Vector2(942, 662), Color(0.06,0.125,0.115,0.98))
    _center_panel(desk_ui)
    var title := _text(desk_ui, Vector2(24, 16), Vector2(730, 38), 29, Color("f6ede0"))
    title.text = "STORE DESK"
    title.size.x = 188.0
    story_entry_button = _button(desk_ui, "SORT -", Vector2(218, 17), Vector2(116, 39), func(): secondhand_events.call("open"))
    story_entry_button.icon = preload("res://assets/ui_story_icons/sort.svg")
    story_entry_button.add_theme_constant_override("icon_max_width", 31)
    story_entry_button.add_theme_constant_override("h_separation", 3)
    story_entry_button.add_theme_font_size_override("font_size", 15)
    story_entry_button.set_meta("ui_original_font_size", 15)
    story_entry_button.tooltip_text = "Picture-first, optional shop sorting activity"
    var resident_button := _button(desk_ui, "LOCAL OFFER", Vector2(341, 17), Vector2(105, 39), _open_resident_offer)
    resident_button.add_theme_font_size_override("font_size", 15)
    resident_button.set_meta("ui_original_font_size", 15)
    _button(desk_ui, "HELP", Vector2(451, 17), Vector2(87, 39), _open_help)
    _button(desk_ui, "LEDGER", Vector2(544, 17), Vector2(97, 39), _open_ledger)
    community_finale_access = _button(desk_ui, "COMMUNITY DAY", Vector2(647, 17), Vector2(150, 39), _open_community_finale)
    _button(desk_ui, "CLOSE / TAB", Vector2(804, 17), Vector2(116, 39), _toggle_desk)
    desk_stats = _text(desk_ui, Vector2(24, 63), Vector2(880, 56), 17, Color("e8d4a4"))
    desk_tutorial_label = _text(desk_ui, Vector2(24, 117), Vector2(565, 25), 15, Color("f4e7b5"))
    desk_page_label = _text(desk_ui, Vector2(605, 114), Vector2(113, 25), 16, Color("eedab5"))
    _button(desk_ui, "PREV", Vector2(715, 110), Vector2(100, 30), func(): _change_catalog_page(-1))
    _button(desk_ui, "NEXT", Vector2(818, 110), Vector2(100, 30), func(): _change_catalog_page(1))
    for i in range(CATALOG_PAGE_SIZE):
        var n: int = i
        var y: float = 146.0 + float(i) * 48.0
        # Two cues for non-readers: the actual item's silhouette and a small
        # category glyph. Numbered item cards help when shapes look similar.
        var product_picture := TextureRect.new()
        product_picture.position = Vector2(24, y)
        product_picture.size = Vector2(48, 45)
        product_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        product_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        product_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
        desk_ui.add_child(product_picture)
        var category_icon := TextureRect.new()
        category_icon.position = Vector2(72, y + 12.0)
        category_icon.size = Vector2(22, 22)
        category_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        category_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        category_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
        desk_ui.add_child(category_icon)
        var information := _text(desk_ui, Vector2(101, y), Vector2(353, 46), 16, Color("f1e9db"))
        var buy := _button(desk_ui, "BUY", Vector2(468, y), Vector2(95, 36), func(): _buy_product(_catalog_index(n)))
        var stock_btn := _button(desk_ui, "STOCK", Vector2(568, y), Vector2(107, 36), func(): _stock_from_desk(_catalog_index(n)))
        var minus_btn := _button(desk_ui, "−", Vector2(683, y), Vector2(42, 36), func(): _change_price(_catalog_index(n),-1))
        var plus_btn := _button(desk_ui, "+", Vector2(731, y), Vector2(42, 36), func(): _change_price(_catalog_index(n),1))
        var bulk_btn := _button(desk_ui, "3-PACK", Vector2(785, y), Vector2(126, 36), func(): _buy_bulk(_catalog_index(n)))
        buy.icon = preload("res://assets/ui_symbols_v0162/buy.png")
        stock_btn.icon = preload("res://assets/ui_symbols_v0162/shelf.png")
        bulk_btn.icon = preload("res://assets/ui_symbols_v0162/bundle.png")
        for icon_button in [buy, stock_btn, bulk_btn]:
            icon_button.add_theme_constant_override("icon_max_width", 21)
            icon_button.add_theme_constant_override("h_separation", 3)
        buy.tooltip_text = "Buy the pictured item from today's local suppliers"
        stock_btn.tooltip_text = "Place the carried item on the matching shelf"
        bulk_btn.tooltip_text = "Buy three items (when available)"
        desk_rows.append({"label":information,"picture":product_picture,"icon":category_icon,"buy":buy,"stock":stock_btn,"minus":minus_btn,"plus":plus_btn,"bulk":bulk_btn})
    desk_upgrade_button = _button(desk_ui, "UPGRADE DISPLAY", Vector2(23, 585), Vector2(315, 48), _buy_display_upgrade)
    _button(desk_ui, "CONSIGNMENT", Vector2(355, 585), Vector2(175, 48), _request_consignment)
    _button(desk_ui, "CLOSE DAY", Vector2(547, 585), Vector2(174, 48), _request_finish_day)
    _button(desk_ui, "MAIN MENU", Vector2(736, 585), Vector2(174, 48), _back_to_menu)
    desk_ui.visible = false

func _create_resident_offer_ui(parent: Node) -> void:
    resident_offer_ui = _panel(parent, Vector2(294, 163), Vector2(692, 394), Color(0.055, 0.125, 0.105, 0.99))
    _center_panel(resident_offer_ui)
    var heading := _text(resident_offer_ui, Vector2(30, 22), Vector2(630, 52), 29, Color("f4e8d3"))
    heading.text = "LOCAL SECOND-HAND OFFER"
    resident_offer_description = _text(resident_offer_ui, Vector2(35, 91), Vector2(620, 186), 20, Color("eadfcd"))
    resident_offer_accept_button = _button(resident_offer_ui, "BUY FROM RESIDENT", Vector2(34, 288), Vector2(296, 55), _accept_resident_offer)
    resident_offer_decline_button = _button(resident_offer_ui, "DECLINE TODAY", Vector2(346, 288), Vector2(155, 55), _decline_resident_offer)
    _button(resident_offer_ui, "BACK", Vector2(516, 288), Vector2(139, 55), _close_resident_offer)
    resident_offer_ui.visible = false

func _create_customer_bargain_ui(parent: Node) -> void:
    customer_bargain_ui = _panel(parent, Vector2(295, 188), Vector2(690, 345), Color(0.055,0.13,0.12,0.99))
    _center_panel(customer_bargain_ui)
    var heading: Label = _text(customer_bargain_ui, Vector2(28, 26), Vector2(628, 56), 29, Color("f3e2c1"))
    heading.text = "A CUSTOMER MAKES AN OFFER"
    customer_bargain_description = _text(customer_bargain_ui, Vector2(33, 95), Vector2(624, 133), 22, Color("f6efe3"))
    customer_bargain_accept = _button(customer_bargain_ui, "ACCEPT OFFER", Vector2(39, 252), Vector2(294, 53), _accept_customer_bargain)
    _button(customer_bargain_ui, "KEEP ORIGINAL PRICE", Vector2(353, 252), Vector2(294, 53), _decline_customer_bargain)
    customer_bargain_ui.visible = false

func _can_offer_bargain() -> bool:
    # Player is offered one optional price discussion at most per day. It is
    # only offered when the buyer is slightly below the shelf price, not broke.
    if day < 2 or day_bargain_offers >= 1 or customer_target < 0:
        return false
    var asking: int = prices[customer_target]
    var supplier_due: int = int(PRODUCTS[customer_target]["cost"]) if consignment_stock[customer_target] > 0 else 0
    return stock[customer_target] > 0 and asking > customer_budget and customer_budget > supplier_due and customer_budget >= maxi(1, roundi(float(asking) * 0.80))

func _open_customer_bargain() -> void:
    if not _can_offer_bargain() or customer_bargain_ui == null:
        return
    customer_bargain_offer = customer_budget
    customer_agreed_price = -1
    day_bargain_offers += 1
    customer_phase = "negotiating"
    customer_bargain_description.text = "%s\nShelf price: $%d   |   Visitor offers: $%d\n\nYou may accept or politely keep your original price." % [str(PRODUCTS[customer_target]["name"]),prices[customer_target],customer_bargain_offer]
    customer_bargain_accept.text = "ACCEPT $%d" % customer_bargain_offer
    customer_bargain_ui.visible = true
    _play_customer_animation("idle")
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _accept_customer_bargain() -> void:
    if customer_bargain_ui == null or not customer_bargain_ui.visible or customer_phase != "negotiating":
        return
    if stock[customer_target] <= 0 or customer_bargain_offer <= 0:
        _decline_customer_bargain()
        return
    if consignment_stock[customer_target] > 0 and customer_bargain_offer <= int(PRODUCTS[customer_target]["cost"]):
        _decline_customer_bargain()
        return
    customer_agreed_price = mini(prices[customer_target], customer_bargain_offer)
    day_bargain_accepted += 1
    customer_bargain_ui.visible = false
    customer_phase = "pickup"
    customer_wait = 0.60
    _play_customer_animation("pick-up")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _message("Offer accepted. Visitor will pay $%d at the checkout." % customer_agreed_price)
    _save_game()

func _decline_customer_bargain() -> void:
    if customer_bargain_ui == null or not customer_bargain_ui.visible:
        return
    customer_bargain_ui.visible = false
    day_bargain_rejected += 1
    customer_agreed_price = -1
    customer_bargain_offer = -1
    customer_phase = "decline"
    customer_wait = 0.5
    _play_customer_animation("emote-no")
    # This uses the ordinary no-sale accounting, with no deductions or fines.
    _complete_sale()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _save_game()

func _refresh_resident_offer_ui() -> void:
    if resident_offer_description == null:
        return
    if day < 2:
        resident_offer_description.text = "Local residents begin bringing items from DAY 2.\n\nRun your store normally and return tomorrow."
    elif resident_offer_decided:
        resident_offer_description.text = "Today's resident offer has already been handled.\n\nA new neighbour may bring another item tomorrow."
    elif not _resident_offer_available():
        resident_offer_description.text = "No local item is available today.\n\nTry the usual supplier catalogue."
    else:
        var product: Dictionary = PRODUCTS[resident_offer_index]
        var condition: String = str(product.get("condition", "Good"))
        resident_offer_description.text = "A neighbour offers one pre-owned item:\n\n%s  ·  %s condition\nAsking $%d  (normal supply $%d)\n\nBuy once, then place it on the shared display." % [str(product["name"]), condition, resident_offer_cost, _supplier_cost(resident_offer_index)]
    var enough_space: bool = _resident_offer_available() and _shelf_inventory_count(_product_shelf(resident_offer_index)) < SHELF_CAPACITY
    resident_offer_accept_button.disabled = not enough_space or carrying != -1 or cash < resident_offer_cost
    resident_offer_decline_button.disabled = not _resident_offer_available()
    if _resident_offer_available() and cash < resident_offer_cost:
        resident_offer_accept_button.tooltip_text = "Not enough cash for the resident's asking price"
    elif _resident_offer_available() and carrying != -1:
        resident_offer_accept_button.tooltip_text = "First place the item you are carrying"
    elif _resident_offer_available() and not enough_space:
        resident_offer_accept_button.tooltip_text = "Shared display is full"
    else:
        resident_offer_accept_button.tooltip_text = "Buy this one local second-hand find"

func _open_resident_offer() -> void:
    if not playing or paused or report_ui.visible or settings_ui.visible or community_finale_ui.visible:
        return
    desk_ui.visible = false
    resident_offer_ui.visible = true
    _refresh_resident_offer_ui()
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_resident_offer() -> void:
    resident_offer_ui.visible = false
    if playing and not paused:
        desk_ui.visible = true
    _refresh_ui()
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _accept_resident_offer() -> void:
    if not _resident_offer_available() or carrying != -1:
        _refresh_resident_offer_ui()
        return
    var index: int = resident_offer_index
    if _shelf_inventory_count(_product_shelf(index)) >= SHELF_CAPACITY:
        _message("The shared display is full. Sell goods before accepting an offer.")
        _refresh_resident_offer_ui()
        return
    if cash < resident_offer_cost:
        _message("Not enough cash for this neighbour's asking price.")
        _refresh_resident_offer_ui()
        return
    var paid: int = resident_offer_cost
    cash -= paid
    day_cost += paid
    total_wholesale += paid
    carrying = index
    resident_offer_decided = true
    resident_purchases_total += 1
    resident_purchase_spending += paid
    _set_carried_model(index)
    _play_click()
    _save_game()
    _close_resident_offer()
    _message("Local trade-in bought: %s for $%d. Place it on its display." % [str(PRODUCTS[index]["name"]), paid])
    _refresh_ui()

func _decline_resident_offer() -> void:
    if not _resident_offer_available():
        _close_resident_offer()
        return
    resident_offer_decided = true
    _save_game()
    _close_resident_offer()
    _message("You passed on today's local offer. Another neighbour may visit tomorrow.")

func _show_community_finale_stage() -> void:
    if community_finale_stage != null and is_instance_valid(community_finale_stage):
        return
    community_finale_stage = Node3D.new()
    community_finale_stage.name = "CommunityDayDecorations"
    world.add_child(community_finale_stage)
    _box(community_finale_stage, Vector3(0.0, 2.7, -8.18), Vector3(5.6, 0.58, 0.09), Color("536f5c"), "CommunityBanner")
    var banner: Label3D = Label3D.new()
    banner.name = "CommunityDayBannerText"
    banner.text = "OLD THINGS · NEW STORIES"
    banner.font_size = 37
    banner.pixel_size = 0.0048
    banner.position = Vector3(0.0, 2.7, -8.09)
    banner.modulate = Color("f7e8c9")
    community_finale_stage.add_child(banner)
    # Three locals greet visitors during the finale, using bundled CC0 actors.
    # These temporary models do not affect live customer queues or commerce.
    var guest_specs: Array[Dictionary] = [
        {"model":"character-female-a", "where":Vector3(-2.45,0.0,0.9), "facing":180.0},
        {"model":"character-male-a", "where":Vector3(1.95,0.0,-1.1), "facing":160.0},
        {"model":"character-female-c", "where":Vector3(4.25,0.0,1.6), "facing":190.0},
    ]
    for guest_data in guest_specs:
        var guest: Node3D = _model(community_finale_stage, str(guest_data["model"]), guest_data["where"], 2.05)
        guest.rotation_degrees.y = float(guest_data["facing"])
        var player_anim: AnimationPlayer = _find_customer_animation_player(guest)
        if player_anim != null:
            for candidate in player_anim.get_animation_list():
                if str(candidate) == "emote-yes" or str(candidate).ends_with("/emote-yes"):
                    player_anim.play(candidate)
                    break

func _clear_community_finale_stage() -> void:
    if community_finale_stage != null and is_instance_valid(community_finale_stage):
        community_finale_stage.queue_free()
    community_finale_stage = null

func _community_finale_unlocked() -> bool:
    return community_finale_seen or (day >= 4 and total_sales >= 8 and display_level >= 1)

func _create_community_finale_ui(parent: Node) -> void:
    community_finale_ui = _panel(parent, Vector2(235, 106), Vector2(810, 508), Color(0.04,0.115,0.095,0.985))
    _center_panel(community_finale_ui)
    var ribbon: Label = _text(community_finale_ui, Vector2(45, 21), Vector2(720, 40), 17, Color("d8bd85"))
    ribbon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ribbon.text = "LITTLE COZY GAMES  ·  AN OPTIONAL SHOP FINALE"
    community_finale_heading = _text(community_finale_ui, Vector2(48, 75), Vector2(714, 65), 34, Color("f6ecda"))
    community_finale_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    community_finale_body = _text(community_finale_ui, Vector2(62, 154), Vector2(686, 205), 23, Color("f1e7d4"))
    community_finale_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    community_finale_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    community_finale_progress = _text(community_finale_ui, Vector2(280, 366), Vector2(250, 35), 17, Color("d8bd85"))
    community_finale_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    community_finale_next = _button(community_finale_ui, "NEXT", Vector2(417, 419), Vector2(328, 56), _advance_community_finale)
    _button(community_finale_ui, "BACK TO SHOP", Vector2(65, 419), Vector2(326, 56), _close_community_finale)
    community_finale_ui.visible = false

func _open_community_finale() -> void:
    if not playing or community_finale_ui.visible or not _community_finale_unlocked():
        return
    community_finale_page = 0
    community_finale_ui.visible = true
    _show_community_finale_stage()
    desk_ui.visible = false
    _refresh_community_finale_page()
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _refresh_community_finale_page() -> void:
    var scene_data: Dictionary = COMMUNITY_FINALE_SCENES[community_finale_page]
    community_finale_heading.text = str(scene_data["title"])
    community_finale_body.text = str(scene_data["body"])
    community_finale_progress.text = "%d  /  %d" % [community_finale_page + 1, COMMUNITY_FINALE_SCENES.size()]
    community_finale_next.text = "FINISH & KEEP SHOPPING" if community_finale_page == COMMUNITY_FINALE_SCENES.size() - 1 else "NEXT CHAPTER"

func _advance_community_finale() -> void:
    if not community_finale_ui.visible:
        return
    if community_finale_page < COMMUNITY_FINALE_SCENES.size() - 1:
        community_finale_page += 1
        _refresh_community_finale_page()
        return
    community_finale_seen = true
    _save_game()
    _close_community_finale()
    _message("Community Day complete. Your shop stays open; carry on whenever you like.")

func _close_community_finale() -> void:
    community_finale_ui.visible = false
    _clear_community_finale_stage()
    if playing:
        desk_ui.visible = true
    _refresh_ui()
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _create_day_end_confirm_ui(parent: Node) -> void:
    # Closing a business day is a consequential action. A stray N key must
    # never skip a day without a clear, reversible confirmation.
    close_day_confirm_ui = _panel(parent, Vector2(360, 204), Vector2(560, 314), Color(0.05, 0.12, 0.11, 0.99))
    _center_panel(close_day_confirm_ui)
    var heading := _text(close_day_confirm_ui, Vector2(38, 20), Vector2(484, 66), 29, Color("f5ead8"))
    heading.text = "CLOSE THE SHOP FOR TODAY?"
    var picture := TextureRect.new()
    picture.texture = load("res://assets/ui_guides/guide_3.png")
    picture.position = Vector2(33, 105)
    picture.size = Vector2(78, 78)
    picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
    close_day_confirm_ui.add_child(picture)
    var hint := _text(close_day_confirm_ui, Vector2(130, 104), Vector2(396, 94), 18, Color("f3e7d0"))
    hint.text = "Finish today's trading and view your day report.\nYou can return now without losing progress."
    _button(close_day_confirm_ui, "KEEP SHOPPING / ESC", Vector2(26, 230), Vector2(242, 52), _cancel_finish_day)
    _button(close_day_confirm_ui, "YES, CLOSE DAY", Vector2(285, 230), Vector2(248, 52), _confirm_finish_day)
    close_day_confirm_ui.visible = false

func _request_finish_day() -> void:
    if not playing or report_ui.visible or paused or close_day_confirm_ui.visible or settings_ui.visible or community_finale_ui.visible or resident_offer_ui.visible or customer_bargain_ui.visible or help_ui.visible or ledger_ui.visible:
        return
    close_day_return_to_desk = desk_ui.visible
    desk_ui.visible = false
    close_day_confirm_ui.visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _refresh_tutorial_ui()

func _cancel_finish_day() -> void:
    if close_day_confirm_ui == null or not close_day_confirm_ui.visible:
        return
    close_day_confirm_ui.visible = false
    desk_ui.visible = close_day_return_to_desk
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if close_day_return_to_desk else Input.MOUSE_MODE_CAPTURED
    _refresh_tutorial_ui()
    _refresh_ui()

func _confirm_finish_day() -> void:
    if close_day_confirm_ui == null or not close_day_confirm_ui.visible:
        return
    close_day_confirm_ui.visible = false
    close_day_return_to_desk = false
    _finish_day()

func _create_report_ui(parent: Node) -> void:
    report_ui = _panel(parent, Vector2(315, 130), Vector2(650, 460), Color(0.06,0.13,0.11,0.99))
    _center_panel(report_ui)
    report_title = _text(report_ui, Vector2(28, 20), Vector2(600, 64), 29, Color("f4e6cf"))
    report_text = _text(report_ui, Vector2(30, 110), Vector2(590, 240), 23, Color("efe9dd"))
    _button(report_ui, "CONTINUE SHOPPING", Vector2(181, 362), Vector2(290, 50), _close_report)
    report_ui.visible = false

func _create_pause_ui(parent: Node) -> void:
    pause_ui = _panel(parent, Vector2(383, 145), Vector2(514, 480), Color(0.055, 0.12, 0.11, 0.98))
    _center_panel(pause_ui)
    var title := _text(pause_ui, Vector2(30, 24), Vector2(460, 65), 34, Color("f4eee1"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.text = "PAUSED"
    var info := _text(pause_ui, Vector2(34, 95), Vector2(446, 55), 17, Color("d9d6c9"))
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.text = "Trading stops while the game is paused."
    pause_status_label = info
    _button(pause_ui, "RESUME", Vector2(120, 145), Vector2(274, 43), _resume_pause)
    _button(pause_ui, "SAVE PROGRESS", Vector2(120, 191), Vector2(274, 43), _pause_save)
    _button(pause_ui, "AUDIO + ACCESSIBILITY", Vector2(120, 237), Vector2(274, 43), _open_settings_menu)
    _button(pause_ui, "CONTROLS / TUTORIAL", Vector2(120, 283), Vector2(274, 43), _open_help)
    _button(pause_ui, "HEALTHY PLAY / FAMILY", Vector2(120, 329), Vector2(274, 43), _open_healthy_play)
    _button(pause_ui, "PRIVACY / SAFETY", Vector2(120, 375), Vector2(274, 43), _open_privacy_safety)
    _button(pause_ui, "SAVE & MAIN MENU", Vector2(120, 421), Vector2(274, 43), _pause_to_menu)
    pause_ui.visible = false

func _open_healthy_play() -> void:
    if healthy_play != null:
        healthy_play.call("open_panel")

func _open_privacy_safety() -> void:
    if privacy_safety != null:
        privacy_safety.call("open_panel")

func _create_ledger_ui(parent: Node) -> void:
    ledger_ui = _panel(parent, Vector2(255, 76), Vector2(770, 565), Color(0.05, 0.12, 0.115, 0.98))
    _center_panel(ledger_ui)
    var title := _text(ledger_ui, Vector2(30, 18), Vector2(530, 53), 30, Color("f4eee1"))
    title.text = "BUSINESS LEDGER"
    _button(ledger_ui, "BACK TO DESK", Vector2(535, 20), Vector2(202, 41), _close_ledger)
    ledger_text = _text(ledger_ui, Vector2(32, 88), Vector2(706, 451), 19, Color("eee8d8"))
    ledger_ui.visible = false

func _open_ledger() -> void:
    if not playing or report_ui.visible or paused:
        return
    desk_ui.visible = false
    ledger_ui.visible = true
    _refresh_ledger()
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _focus_menu_controls(ledger_ui)

func _close_ledger() -> void:
    ledger_ui.visible = false
    if playing and not paused:
        desk_ui.visible = true
        _refresh_ui()
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if playing and not paused:
        _focus_menu_controls(desk_ui)

func _refresh_ledger() -> void:
    if ledger_text == null:
        return
    var goods_value := 0
    for i in range(PRODUCTS.size()):
        goods_value += (stock[i] - consignment_stock[i]) * int(PRODUCTS[i]["cost"])
    var summary := "Cash $%d    |    Owned stock at supplier cost $%d    |    Sales %d\n" % [cash, goods_value, total_sales]
    summary += "Revenue $%d    |    Goods purchases $%d\n" % [total_revenue, total_wholesale]
    summary += "Local trade-ins %d | Cash spent $%d (included in goods purchases)\n" % [resident_purchases_total, resident_purchase_spending]
    summary += "Customers helped to another stocked item: %d\n" % total_assisted_shoppers
    summary += "Supplier-funded items are not counted as owned inventory.\n"
    summary += _demand_message() + "\n\n"
    summary += "RECENT CLOSED DAYS   (cash movement, not accounting profit)\n"
    if daily_history.is_empty():
        summary += "No completed days yet. Close a business day to add a report."
    else:
        var start: int = maxi(0, daily_history.size() - 7)
        for i in range(daily_history.size() - 1, start - 1, -1):
            var entry: Dictionary = daily_history[i]
            summary += "Day %d | %s | %d visitors | %d sales (%d hot) | helped %d | revenue $%d | cash %d\n" % [int(entry.get("day",0)),str(entry.get("trend","—")),int(entry.get("visitors",0)),int(entry.get("sales",0)),int(entry.get("hot_sales",0)),int(entry.get("assisted",0)),int(entry.get("revenue",0)),int(entry.get("cash_change",0))]
    ledger_text.text = summary

func _open_pause() -> void:
    if not playing or report_ui.visible or settings_ui.visible or resident_offer_ui.visible or customer_bargain_ui.visible:
        return
    paused = true
    desk_ui.visible = false
    ledger_ui.visible = false
    resident_offer_ui.visible = false
    pause_ui.visible = true
    if pause_status_label != null:
        pause_status_label.text = "Trading stops while the game is paused."
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _focus_menu_controls(pause_ui, "RESUME")

func _resume_pause() -> void:
    paused = false
    pause_ui.visible = false
    if playing:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        _refresh_ui()
    _refresh_tutorial_ui()

func _pause_save() -> void:
    var ok: bool = _save_game()
    if pause_status_label != null:
        pause_status_label.text = "Progress saved locally." if ok else "Save failed. Stay here, check disk space and try again."
    _message("Progress saved locally." if ok else "Save failed. Your shop is still open in pause mode.")

func _pause_to_menu() -> void:
    if not _save_game():
        if pause_status_label != null:
            pause_status_label.text = "SAVE FAILED. Still in the shop; please try again."
        _message("Save failed; main menu was not opened. Check storage and retry.")
        return
    paused = false
    pause_ui.visible = false
    _show_title()

func _create_credits_ui(parent: Node) -> void:
    credits_ui = _panel(parent, Vector2(201, 77), Vector2(878, 566), Color(0.06,0.12,0.11,0.99))
    _center_panel(credits_ui)
    var title := _text(credits_ui, Vector2(27, 16), Vector2(821, 52), 28, Color("f4e6cf"))
    title.text = "CREDITS · SOURCES · LICENCES"
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(27, 82)
    scroll.size = Vector2(823, 406)
    credits_ui.add_child(scroll)
    credits_scroll = scroll
    var legal := RichTextLabel.new()
    legal.scroll_active = false
    legal.fit_content = false
    legal.add_theme_font_size_override("normal_font_size", 18)
    # One source of truth: the player-facing notice is rebuilt from the media ledger.
    # Do not maintain a second hardcoded credits list in this script.
    var notice_text: String = FileAccess.get_file_as_string("res://licenses/PLAYER_THIRD_PARTY_NOTICES.txt")
    var godot_license: String = FileAccess.get_file_as_string("res://licenses/GODOT_ENGINE_MIT_LICENSE_NOTICE.txt")
    if notice_text.is_empty():
        notice_text = "Credits file unavailable; please consult the bundled THIRD-PARTY notices."
    if godot_license.is_empty():
        godot_license = "Godot Engine MIT terms: https://godotengine.org/license/"
    var ai_note: String = FileAccess.get_file_as_string("res://licenses/AI_ASSISTED_PRODUCTION_NOTICE.txt")
    credits_default_text = notice_text + "\n\n" + godot_license
    if not ai_note.is_empty():
        credits_default_text += "\n\n" + ai_note
    legal.text = credits_default_text
    credits_legal_label = legal
    var legal_lines: int = 0
    for part in legal.text.split("\n"):
        legal_lines += maxi(1, ceili(float(part.length()) / 70.0))
    var legal_height: float = maxf(790.0, float(legal_lines) * 29.0)
    legal.custom_minimum_size = Vector2(771.0, legal_height)
    legal.size = Vector2(771.0, legal_height)
    scroll.add_child(legal)
    _button(credits_ui, "ASSET CREDITS", Vector2(27, 505), Vector2(196, 45), _show_media_licenses)
    _button(credits_ui, "ENGINE COMPONENTS", Vector2(232, 505), Vector2(375, 45), _show_engine_component_licenses)
    _button(credits_ui, "BACK", Vector2(655, 505), Vector2(191, 45), _close_credits)
    credits_ui.visible = false

func _create_settings_ui(parent: Node) -> void:
    settings_ui = _panel(parent, Vector2(360, 20), Vector2(560, 680), Color(0.06,0.125,0.115,0.99))
    _center_panel(settings_ui)
    var title := _text(settings_ui, Vector2(30, 16), Vector2(500, 47), 29, Color("f4e6cf"))
    title.text = "AUDIO & ACCESSIBILITY"
    var descriptions := ["Master Volume", "Music Volume", "Sound Effects"]
    var values := [master_volume, music_volume, sfx_volume]
    for i in range(3):
        var index: int = i
        var lab := _text(settings_ui, Vector2(35, 70 + i*76), Vector2(460, 32), 19, Color("f4efe6"))
        lab.text = "%s  ·  %d%%" % [descriptions[i], roundi(values[i]*100.0)]
        volume_labels.append(lab)
        var slider := HSlider.new()
        slider.position = Vector2(35, 107 + i*76)
        slider.size = Vector2(475, 24)
        slider.min_value = 0.0
        slider.max_value = 1.0
        slider.step = 0.05
        slider.value = values[i]
        settings_ui.add_child(slider)
        slider.value_changed.connect(func(value: float): _change_volume(index,value))
        volume_sliders.append(slider)
    var note := _text(settings_ui, Vector2(36, 290), Vector2(485, 18), 13, Color("e5d6ad"))
    note.text = "Flashing avoided; photosensitivity testing is still required."
    mouse_speed_button = _button(settings_ui, "", Vector2(45, 314), Vector2(466, 38), _cycle_mouse_speed)
    mouse_speed_button.add_theme_font_size_override("font_size", 14)
    mouse_speed_button.set_meta("ui_original_font_size", 14)
    mouse_speed_button.tooltip_text = "Mouse-look speed: slow, standard (original), or fast. No flashing."
    for i in range(7):
        var n: int = i
        var b: Button = _button(settings_ui, "", Vector2(45, 360 + i*37), Vector2(466, 35), func(): _toggle_accessibility(n))
        b.add_theme_font_size_override("font_size", 16)
        b.set_meta("ui_original_font_size", 16)
        accessibility_buttons.append(b)
    _button(settings_ui, "DONE", Vector2(189, 628), Vector2(182, 43), _close_settings)
    settings_ui.visible = false
    _refresh_accessibility_buttons()

func _refresh_accessibility_buttons() -> void:
    if accessibility_buttons.size() != 7:
        return
    accessibility_buttons[0].text = "LARGER UI TEXT:  " + ("ON" if large_text else "OFF")
    accessibility_buttons[1].text = "HIGH CONTRAST:  " + ("ON" if high_contrast else "OFF")
    accessibility_buttons[2].text = "REDUCED MOTION:  " + ("ON" if reduced_motion else "OFF")
    accessibility_buttons[3].text = "PICTURE GUIDE:  " + ("ON" if picture_guides else "OFF")
    accessibility_buttons[4].text = "COMPACT HUD:  " + ("ON" if compact_hud else "OFF")
    accessibility_buttons[5].text = "GENTLE CAMERA:  " + ("ON" if gentle_camera else "OFF")
    accessibility_buttons[6].text = "SOFT LIGHTING:  " + ("ON" if soft_lighting else "OFF")
    if mouse_speed_button != null:
        mouse_speed_button.text = "MOUSE LOOK SPEED:  " + str(LOOK_SPEED_LABELS[mouse_speed_mode])

func _cycle_mouse_speed() -> void:
    mouse_speed_mode = (mouse_speed_mode + 1) % LOOK_SPEED_MULTIPLIERS.size()
    _refresh_accessibility_buttons()
    _save_audio_settings()

func _toggle_accessibility(which: int) -> void:
    if which == 0:
        large_text = not large_text
    elif which == 1:
        high_contrast = not high_contrast
    elif which == 2:
        reduced_motion = not reduced_motion
    elif which == 3:
        picture_guides = not picture_guides
    elif which == 4:
        compact_hud = not compact_hud
    elif which == 5:
        gentle_camera = not gentle_camera
    elif which == 6:
        soft_lighting = not soft_lighting
    else:
        return
    _apply_accessibility()
    _refresh_picture_guides()
    _refresh_accessibility_buttons()
    _refresh_ui()
    _save_audio_settings()

func _apply_visual_comfort() -> void:
    # Static, non-pulsing lighting and player-controlled camera parameters.
    # These lower discomfort potential but do not certify seizure safety.
    if camera != null:
        camera.fov = 70.0 if gentle_camera else 74.0
    if sunlight_light != null:
        sunlight_light.light_energy = 0.72 if soft_lighting else 0.95
    if shop_environment != null:
        shop_environment.ambient_light_energy = 0.74 if soft_lighting else 0.82

func _apply_accessibility() -> void:
    _apply_visual_comfort()
    if ui_layer == null:
        return
    _apply_accessibility_node(ui_layer)

func _apply_accessibility_node(node: Node) -> void:
    if node is Label and node.has_meta("ui_original_font_size"):
        var lab: Label = node as Label
        var base_size: int = int(node.get_meta("ui_original_font_size"))
        lab.add_theme_font_size_override("font_size", roundi(float(base_size) * (1.12 if large_text else 1.0)))
        var normal_color: Color = node.get_meta("ui_original_color")
        lab.add_theme_color_override("font_color", Color.WHITE if high_contrast else normal_color)
    elif node is Button and node.has_meta("ui_original_font_size"):
        var btn: Button = node as Button
        btn.add_theme_font_size_override("font_size", roundi(float(node.get_meta("ui_original_font_size")) * (1.12 if large_text else 1.0)))
        # XAG 102 recommends at least 7:1 in high-contrast mode. White text
        # over the old green hover style was only about 4:1; use black surfaces
        # while the mode is enabled and restore exact originals on exit.
        if node.has_meta("ui_original_button_styles"):
            var originals: Dictionary = node.get_meta("ui_original_button_styles")
            for state in ["normal", "hover", "pressed", "disabled"]:
                if not originals.has(state):
                    continue
                var current_style: StyleBoxFlat = (originals[state] as StyleBoxFlat).duplicate() as StyleBoxFlat
                if high_contrast:
                    current_style.bg_color = Color("0d0d0d") if state != "disabled" else Color("212121")
                    current_style.border_color = Color.WHITE if state != "disabled" else Color("b6b6b6")
                btn.add_theme_stylebox_override(state, current_style)
    elif node is Panel and node.has_meta("ui_original_background"):
        var panel: Panel = node as Panel
        var flat: StyleBoxFlat = (panel.get_theme_stylebox("panel") as StyleBoxFlat).duplicate() as StyleBoxFlat
        flat.bg_color = Color(0.014,0.018,0.020,0.99) if high_contrast else node.get_meta("ui_original_background")
        panel.add_theme_stylebox_override("panel", flat)
    for child in node.get_children():
        _apply_accessibility_node(child)

func _change_volume(index: int, value: float) -> void:
    if index == 0:
        master_volume = value
    elif index == 1:
        music_volume = value
    else:
        sfx_volume = value
    var labels := ["Master Volume", "Music Volume", "Sound Effects"]
    volume_labels[index].text = "%s  ·  %d%%" % [labels[index], roundi(value*100.0)]
    _apply_audio()
    _save_audio_settings()

func _open_settings_menu() -> void:
    if paused:
        settings_source = "pause"
    elif playing:
        settings_source = "desk"
    else:
        settings_source = "title"
    settings_ui.visible = true
    title_ui.visible = false
    desk_ui.visible = false
    pause_ui.visible = false
    for i in range(3):
        var volume: float = master_volume if i == 0 else (music_volume if i == 1 else sfx_volume)
        volume_sliders[i].set_value_no_signal(volume)
        var labels := ["Master Volume", "Music Volume", "Sound Effects"]
        volume_labels[i].text = "%s  ·  %d%%" % [labels[i], roundi(volume*100.0)]
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _focus_menu_controls(settings_ui)

func _close_settings() -> void:
    settings_ui.visible = false
    if settings_source == "pause":
        pause_ui.visible = true
    elif settings_source == "desk" and playing:
        desk_ui.visible = true
        _refresh_ui()
    else:
        _show_title()
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if settings_source == "pause":
        _focus_menu_controls(pause_ui, "AUDIO + ACCESSIBILITY")
    elif settings_source == "desk" and playing:
        _focus_menu_controls(desk_ui)
    else:
        _focus_menu_controls(title_ui, "AUDIO + ACCESSIBILITY")

func _create_new_game_confirm_ui(parent: Node) -> void:
    new_game_confirm_ui = _panel(parent, Vector2(355, 216), Vector2(570, 278), Color(0.055,0.09,0.09,0.99))
    _center_panel(new_game_confirm_ui)
    var title := _text(new_game_confirm_ui, Vector2(32, 27), Vector2(506, 55), 28, Color("fff1e4"))
    title.text = "START A NEW GAME?"
    var warning := _text(new_game_confirm_ui, Vector2(35, 95), Vector2(500, 102), 20, Color("f9e6bc"))
    warning.text = "Your existing local shop save will be replaced.\nThis cannot be undone from the main menu."
    _button(new_game_confirm_ui, "CANCEL", Vector2(33, 207), Vector2(236, 46), _cancel_new_game)
    _button(new_game_confirm_ui, "OVERWRITE & START", Vector2(284, 207), Vector2(256, 46), _confirm_new_game)
    new_game_confirm_ui.visible = false

func _request_new_game() -> void:
    if FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(SAVE_PATH + ".bak"):
        new_game_confirm_ui.visible = true
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        _focus_menu_controls(new_game_confirm_ui, "CANCEL")
    else:
        _new_game()

func _cancel_new_game() -> void:
    new_game_confirm_ui.visible = false
    _focus_menu_controls(title_ui, "NEW GAME")

func _confirm_new_game() -> void:
    new_game_confirm_ui.visible = false
    _new_game()

func _create_help_ui(parent: Node) -> void:
    help_ui = _panel(parent, Vector2(225, 82), Vector2(830, 555), Color(0.045,0.115,0.105,0.99))
    _center_panel(help_ui)
    var heading := _text(help_ui, Vector2(29, 19), Vector2(760, 57), 29, Color("faf4e5"))
    heading.text = "HOW TO PLAY · CONTROLS  (F1)"
    var guide_scroll := ScrollContainer.new()
    guide_scroll.position = Vector2(26, 80)
    guide_scroll.size = Vector2(780, 370)
    help_ui.add_child(guide_scroll)
    var guide := _text(guide_scroll, Vector2.ZERO, Vector2(748, 750), 19, Color("f6eee2"))
    guide.custom_minimum_size = Vector2(748, 750)
    guide.text = "LOOK FOR FOUR PICTURES: BUY > PLACE > SELL > DAY.\nThe 5-step tutorial also shows a picture and a key/action for each step.\nCATALOG: Each item has its own picture + small category symbol.\nBUY = basket icon, STOCK = shelf icon, 3-PACK = three boxes.\nMOUSE LOOK SPEED is adjustable in AUDIO & ACCESSIBILITY.\nCLOSE DAY / N now requests confirmation; ESC cancels.\nMOVE: WASD or arrow keys. LOOK: mouse.\nTAB: store desk (buy, place, and price goods).\nE: stand near the shelf marked with ▼, then place the carried item.\n+ / -: change a shelf price. ESC: pause or back.\nN: close the business day and review your numbers.\n\nSHOP LOOP: Buy a product > put it on a shelf > set its price >\nlet a customer browse and check out. High prices can lose sales.\nBrowse 3 desk pages (PREV / NEXT) for 27 types of goods.\nNine displays hold up to six mixed items each.\n[HOT] shows the daily preferred group. Extra supplier finds rotate.\nLOCAL OFFER: One optional neighbour trade-in per day from Day 2.\nStock can be limited and money can run out; CONSIGNMENT\nhelps when your shelves are completely empty and you are broke.\n\nYou may skip or replay the tutorial.\nCOMMUNITY DAY: Day 4 + 8 sales + Display LV1; optional finale in Store Desk.\nThe shop stays open afterward."
    _button(help_ui, "REPLAY 5-STEP TUTORIAL", Vector2(29, 473), Vector2(380, 50), _restart_tutorial)
    _button(help_ui, "BACK", Vector2(611, 473), Vector2(188, 50), _close_help)
    help_ui.visible = false

func _create_tutorial_ui(parent: Node) -> void:
    # Picture guide is anchored at y=14..146; do not overlap it.
    tutorial_panel = _panel(parent, Vector2(886, 158), Vector2(375, 242), Color(0.065,0.12,0.11,0.97))
    tutorial_panel.anchor_left = 1.0
    tutorial_panel.anchor_right = 1.0
    tutorial_panel.offset_left = -394.0
    tutorial_panel.offset_right = -19.0
    tutorial_panel.offset_top = 158.0
    tutorial_panel.offset_bottom = 400.0
    tutorial_icon = TextureRect.new()
    tutorial_icon.position = Vector2(15, 15)
    tutorial_icon.size = Vector2(60, 60)
    tutorial_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    tutorial_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    tutorial_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tutorial_panel.add_child(tutorial_icon)
    tutorial_heading = _text(tutorial_panel, Vector2(84, 13), Vector2(278, 37), 18, Color("f9e3a8"))
    tutorial_keycap = _text(tutorial_panel, Vector2(84, 52), Vector2(278, 31), 19, Color("fff7e8"))
    tutorial_body = _text(tutorial_panel, Vector2(16, 92), Vector2(342, 90), 17, Color("fff8e8"))
    _button(tutorial_panel, "SKIP / REPLAY IN HELP", Vector2(126, 191), Vector2(231, 36), _skip_tutorial)
    tutorial_panel.visible = false

func _start_tutorial() -> void:
    tutorial_active = true
    tutorial_step = 0
    _refresh_tutorial_ui()
    _save_game()

func _skip_tutorial() -> void:
    tutorial_active = false
    tutorial_step = TUTORIAL_ACTIONS.size()
    _save_game()
    _refresh_tutorial_ui()
    _message("Tutorial skipped. Open HOW TO PLAY anytime to review the controls.")

func _tutorial_event(action: String) -> void:
    if not tutorial_active or tutorial_step < 0 or tutorial_step >= TUTORIAL_ACTIONS.size():
        return
    if action != TUTORIAL_ACTIONS[tutorial_step]:
        return
    tutorial_step += 1
    if tutorial_step >= TUTORIAL_ACTIONS.size():
        tutorial_active = false
        _message("Tutorial complete! You can now grow your shop freely.")
    else:
        _message("Step complete! Next: " + str(TUTORIAL_TITLES[tutorial_step]))
    _save_game()
    _refresh_tutorial_ui()

func _refresh_tutorial_ui() -> void:
    if tutorial_panel == null:
        return
    var show_tip: bool = playing and tutorial_active and not desk_ui.visible and not paused and not help_ui.visible and not report_ui.visible and not settings_ui.visible and not ledger_ui.visible and not community_finale_ui.visible and not customer_bargain_ui.visible and not close_day_confirm_ui.visible and not (secondhand_events != null and bool(secondhand_events.call("is_open")))
    tutorial_panel.visible = show_tip
    if tutorial_active and tutorial_step < TUTORIAL_ACTIONS.size():
        var heading: String = "STEP %d / %d · %s" % [tutorial_step + 1,TUTORIAL_ACTIONS.size(),str(TUTORIAL_TITLES[tutorial_step])]
        var text_line: String = str(TUTORIAL_INSTRUCTIONS[tutorial_step])
        tutorial_heading.text = heading
        tutorial_body.text = text_line
        tutorial_icon.texture = load("res://assets/ui_guides/guide_%d.png" % TUTORIAL_PICTURE_IDS[tutorial_step])
        tutorial_keycap.text = "KEY / ACTION: " + str(TUTORIAL_KEYCAPS[tutorial_step])
        desk_tutorial_label.text = "STEP %d/%d · %s" % [tutorial_step + 1,TUTORIAL_ACTIONS.size(),str(TUTORIAL_KEYCAPS[tutorial_step]) + " · " + text_line.split(".")[0] + "."]
    else:
        if _community_finale_unlocked():
            desk_tutorial_label.text = "OPTIONAL: COMMUNITY DAY is ready. Open it at the top; you can keep trading afterward."
        else:
            desk_tutorial_label.text = "COMMUNITY DAY: Day 4 + 8 sales + Display LV1. Keep trading at your own pace."

func _open_help() -> void:
    if help_ui.visible:
        return
    help_source = "pause" if paused else ("desk" if playing and desk_ui.visible else ("game" if playing else "title"))
    help_ui.visible = true
    title_ui.visible = false
    desk_ui.visible = false
    pause_ui.visible = false
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _refresh_tutorial_ui()
    _focus_menu_controls(help_ui)

func _close_help() -> void:
    help_ui.visible = false
    if help_source == "pause":
        pause_ui.visible = true
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif help_source == "desk":
        desk_ui.visible = true
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif help_source == "game":
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    else:
        _show_title()
    _refresh_ui()
    if help_source == "pause":
        _focus_menu_controls(pause_ui, "CONTROLS / TUTORIAL")
    elif help_source == "desk":
        _focus_menu_controls(desk_ui, "HELP")
    elif help_source == "title":
        _focus_menu_controls(title_ui, "CONTROLS / HOW TO PLAY")

func _restart_tutorial() -> void:
    if not playing:
        _close_help()
        _request_new_game()
        return
    _start_tutorial()
    help_source = "game"
    _close_help()
    _message("Tutorial restarted. Press TAB to open the store desk.")

func _create_splash_ui(parent: Node) -> void:
    splash_ui = _panel(parent, Vector2(286, 77), Vector2(710, 565), Color(0.035,0.095,0.078,0.99))
    _center_panel(splash_ui)
    # Restored for PRIVATE / INTERNAL QA after the project owner confirmed that
    # ChatGPT created this mark at their direction. This is provenance evidence,
    # NOT proof of trademark registration or freedom from similar marks.
    var studio_logo := TextureRect.new()
    studio_logo.position = Vector2(130, 46)
    studio_logo.size = Vector2(450, 340)
    studio_logo.texture = load("res://assets/branding/lcg_logo.png")
    studio_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    studio_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    studio_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    studio_logo.modulate.a = 0.0
    splash_ui.add_child(studio_logo)
    splash_logo = studio_logo
    var lab := _text(splash_ui, Vector2(95, 410), Vector2(520, 64), 19, Color("e7c993"))
    lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lab.text = "OLD THINGS, NEW DAYS · INTERNAL PLAYTEST ONLY"
    _button(splash_ui, "SKIP", Vector2(285, 492), Vector2(140, 40), _skip_splash)

func _show_splash() -> void:
    playing = false
    title_ui.visible = false
    hud_ui.visible = false
    desk_ui.visible = false
    report_ui.visible = false
    ledger_ui.visible = false
    close_day_confirm_ui.visible = false
    pause_ui.visible = false
    credits_ui.visible = false
    settings_ui.visible = false
    help_ui.visible = false
    community_finale_ui.visible = false
    customer_bargain_ui.visible = false
    splash_ui.visible = true
    splash_remaining = BRAND_SPLASH_SECONDS
    if splash_logo != null:
        splash_logo.modulate.a = 0.0
        splash_logo.position = Vector2(130, 46)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if reduced_motion:
        _skip_splash()

func _skip_splash() -> void:
    # Idempotent: a skip button and an input event may arrive in the same frame.
    if splash_ui == null or not splash_ui.visible:
        return
    splash_remaining = 0.0
    splash_ui.visible = false
    _show_title()

func _show_title() -> void:
    if privacy_safety != null:
        privacy_safety.call("hide_panel")
    if healthy_play != null:
        healthy_play.call("finish_session")
    playing = false
    paused = false
    _clear_community_finale_stage()
    title_ui.visible = true
    title_continue.disabled = not FileAccess.file_exists(SAVE_PATH) and not FileAccess.file_exists(SAVE_PATH + ".bak") and not FileAccess.file_exists(SAVE_PATH + SAVE_PENDING_SUFFIX)
    hud_ui.visible = false
    desk_ui.visible = false
    report_ui.visible = false
    ledger_ui.visible = false
    close_day_confirm_ui.visible = false
    pause_ui.visible = false
    credits_ui.visible = false
    settings_ui.visible = false
    splash_ui.visible = false
    help_ui.visible = false
    community_finale_ui.visible = false
    resident_offer_ui.visible = false
    customer_bargain_ui.visible = false
    if secondhand_events != null and secondhand_events.call("is_open"):
        (secondhand_events.get("panel") as Panel).visible = false
    new_game_confirm_ui.visible = false
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    audio_music.stop()
    _focus_menu_controls(title_ui, "NEW GAME")

func _new_game() -> void:
    new_game_confirm_ui.visible = false
    _reset_model()
    tutorial_active = true
    tutorial_step = 0
    _recreate_shelf_views()
    _enter_game()
    if not _save_game():
        _message("SAVE FAILED. You can still play, but your progress is not stored. Check storage before leaving.")
        return
    _message("Welcome! TAB opens the store desk. " + _demand_message())

func _continue_game() -> void:
    # Customers aren't persisted; discard any active visitor from the menu.
    _dismiss_customer()
    customer_timer = 3.0
    if _load_game():
        _recreate_shelf_views()
        _enter_game()
        _message("Recovered backup save! " + _demand_message() if recovered_save else "Shop restored. " + _demand_message())
    else:
        _new_game()

func _enter_game() -> void:
    playing = true
    if healthy_play != null:
        healthy_play.call("begin_session")
    paused = false
    title_ui.visible = false
    splash_ui.visible = false
    credits_ui.visible = false
    settings_ui.visible = false
    community_finale_ui.visible = false
    resident_offer_ui.visible = false
    customer_bargain_ui.visible = false
    if secondhand_events != null and secondhand_events.call("is_open"):
        (secondhand_events.get("panel") as Panel).visible = false
    desk_ui.visible = false
    report_ui.visible = false
    ledger_ui.visible = false
    close_day_confirm_ui.visible = false
    pause_ui.visible = false
    hud_ui.visible = true
    player.position = Vector3(0, 0.12, 5.2)
    player.rotation = Vector3.ZERO
    head.rotation = Vector3.ZERO
    footstep_elapsed = 0.0
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    # Automated gameplay QA is silent to avoid retaining active OGG playbacks at exit.
    # Actual gameplay audio (qa_mode=false) is unchanged.
    if audio_music != null and not audio_music.playing and not qa_mode:
        audio_music.play()
    _refresh_ui()
    _refresh_tutorial_ui()

func _toggle_desk() -> void:
    if not playing or report_ui.visible or settings_ui.visible or paused or ledger_ui.visible or help_ui.visible or community_finale_ui.visible or resident_offer_ui.visible or customer_bargain_ui.visible or close_day_confirm_ui.visible or (secondhand_events != null and bool(secondhand_events.call("is_open"))) or (secondhand_events != null and bool(secondhand_events.call("is_open"))):
        return
    desk_ui.visible = not desk_ui.visible
    if desk_ui.visible:
        _tutorial_event("open_desk")
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if desk_ui.visible else Input.MOUSE_MODE_CAPTURED
    _refresh_ui()
    _refresh_tutorial_ui()

func _show_credits() -> void:
    credits_ui.visible = true
    _show_media_licenses()
    title_ui.visible = false

func _set_credits_body(content: String) -> void:
    if credits_legal_label == null:
        return
    credits_legal_label.text = content
    var text_lines: int = 0
    for part in content.split("\n"):
        text_lines += maxi(1, ceili(float(part.length()) / 70.0))
    var content_height: float = maxf(790.0, float(text_lines) * 29.0)
    credits_legal_label.custom_minimum_size = Vector2(771.0, content_height)
    credits_legal_label.size = Vector2(771.0, content_height)
    if credits_scroll != null:
        credits_scroll.scroll_vertical = 0

func _show_media_licenses() -> void:
    _set_credits_body(credits_default_text)

func _show_engine_component_licenses() -> void:
    # Source-of-truth: the exact Godot binary actually running the game.
    # Details may change between engine builds; never hardcode component licenses.
    _set_credits_body(ENGINE_NOTICES_SCRIPT.render())

func _close_credits() -> void:
    credits_ui.visible = false
    _show_title()

func _back_to_menu() -> void:
    if not _save_game():
        _message("Save failed. You are still in the shop. Check storage and retry.")
        return
    _show_title()

func _prepare_desktop_exit() -> bool:
    # Shared by the menu button, window-close X, and Alt+F4. Failure must
    # never be ignored: do not end the session when its save could not commit.
    if playing:
        if not _save_game():
            if pause_status_label != null:
                pause_status_label.text = "SAVE FAILED. The game is still open; check storage and retry."
            _message("SAVE FAILED. Shop remains open. Check disk permissions and retry.")
            return false
    else:
        _save_audio_settings()
    if healthy_play != null:
        healthy_play.call("finish_session")
    return true

func _quit_desktop() -> void:
    if exit_committed:
        return
    if not _prepare_desktop_exit():
        return
    # quit() may notify nodes again; this guard prevents repeated saves.
    exit_committed = true
    get_tree().quit()

func _featured_category(for_day: int = -1) -> int:
    var target_day: int = day if for_day < 0 else for_day
    return posmod(maxi(1, target_day) - 1, CATEGORY_NAMES.size())

func _is_featured_product(index: int) -> bool:
    return index >= 0 and index < PRODUCT_CATEGORIES.size() and int(PRODUCT_CATEGORIES[index]) == _featured_category()

func _demand_message() -> String:
    var today_name: String = str(CATEGORY_NAMES[_featured_category()])
    var next_name: String = str(CATEGORY_NAMES[_featured_category(day + 1)])
    return "TODAY: %s | NEXT: %s | %s" % [today_name, next_name, _day_event_description()]

func _daily_sales_target() -> int:
    # Prototype targets: day 1 = 2, day 2 = 3, day 3+ = 4.
    return mini(4, day + 1)

func _bulk_price(index: int) -> int:
    return ceili(float(_supplier_cost(index) * 3) * BULK_DISCOUNT)

func _buy_bulk(index: int) -> void:
    # Three-unit supplier delivery; discount unlocks at 3 completed sales.
    if index < 0 or index >= PRODUCTS.size():
        return
    if total_sales < 3 or total_sales < int(PRODUCTS[index]["unlock"]):
        _message("Supplier 3-packs unlock after 3 sales and the product tier is unlocked.")
        return
    if not _supplier_available(index) or supplier_remaining[index] < 3:
        _message("A three-item supplier bundle is unavailable today. Try a single find or check tomorrow.")
        return
    if _shelf_inventory_count(_product_shelf(index)) > SHELF_CAPACITY - 3:
        _message("This display has room for fewer than three items. Sell stock first.")
        return
    var cost: int = _bulk_price(index)
    if cash < cost:
        _message("Not enough cash for the $%d supplier 3-pack." % cost)
        return
    cash -= cost
    day_cost += cost
    total_wholesale += cost
    stock[index] += 3
    supplier_remaining[index] -= 3
    _refresh_shelf(index)
    _save_game()
    _play_click()
    _message("Supplier delivery: three %s items for $%d, 10%% discount." % [str(PRODUCTS[index]["name"]), cost])
    _refresh_ui()

func _save_button() -> void:
    if _save_game():
        _message("Shop saved locally.")
    else:
        _message("SAVE FAILED. Your current session is still active; check disk space or permissions.")

func _message(message_text: String) -> void:
    if hud_message != null:
        hud_message.text = message_text
    message_time = 6.0

func _is_stranded() -> bool:
    # Player cannot buy any unlocked stock, has nothing displayed and carries nothing.
    if carrying >= 0:
        return false
    for qty in stock:
        if qty > 0:
            return false
    for i in range(PRODUCTS.size()):
        if total_sales >= int(PRODUCTS[i]["unlock"]) and _supplier_available(i) and _shelf_inventory_count(_product_shelf(i)) < SHELF_CAPACITY and cash >= _supplier_cost(i):
            return false
    return true

func _request_consignment() -> void:
    if not _is_stranded():
        _message("Consignment is only available when you cannot afford any stock and all shelves are empty.")
        return
    var index: int = CONSIGNMENT_PRODUCT_INDEX
    # A single book set is loaned by the supplier: the wholesale fee is due only on sale.
    # Prevent loss-making prices for supplier-funded inventory.
    prices[index] = maxi(prices[index], int(PRODUCTS[index]["cost"]) + 1)
    stock[index] += 1
    consignment_stock[index] += 1
    _refresh_shelf(index)
    _save_game()
    _play_click()
    _message("Supplier consignment: one Old Book Set. Pay its $%d cost only after it sells." % int(PRODUCTS[index]["cost"]))
    _refresh_ui()

func _buy_product(index: int) -> void:
    if index < 0 or index >= PRODUCTS.size():
        return
    if total_sales < int(PRODUCTS[index]["unlock"]):
        _message("This item unlocks after %d successful sales." % int(PRODUCTS[index]["unlock"]))
        return
    if not _supplier_available(index):
        _message("Today's local suppliers have no more of this item. Try again tomorrow.")
        return
    if _shelf_inventory_count(_product_shelf(index)) >= SHELF_CAPACITY:
        _message("This display is full (6/6). Sell an item before ordering more.")
        return
    if carrying != -1:
        _message("Stock the item you already carry before buying another.")
        return
    var cost: int = _supplier_cost(index)
    if cash < cost:
        _message("Not enough cash to order %s." % str(PRODUCTS[index]["name"]))
        return
    cash -= cost
    day_cost += cost
    total_wholesale += cost
    supplier_remaining[index] -= 1
    carrying = index
    _tutorial_event("buy")
    _set_carried_model(index)
    _play_click()
    _save_game()
    _message("Bought %s for $%d. Use STOCK in desk or aim at its shelf and press E." % [str(PRODUCTS[index]["name"]), cost])
    _refresh_ui()

func _set_carried_model(index: int) -> void:
    for item in held_item.get_children():
        item.queue_free()
    held_item.visible = index >= 0
    if index >= 0:
        var held_scale: float = clampf(float(PRODUCTS[index]["scale"]) * 0.48, 0.44, 1.15)
        _model(held_item, str(PRODUCTS[index]["model"]), Vector3.ZERO, held_scale)

func _stock_from_desk(index: int) -> void:
    if carrying != index:
        _message("You must BUY this specific item before stocking it.")
        return
    if _shelf_inventory_count(_product_shelf(index)) >= SHELF_CAPACITY:
        _message("The shared display is full. Sell stock before placing this item.")
        return
    stock[index] += 1
    carrying = -1
    _tutorial_event("stock")
    _set_carried_model(-1)
    _refresh_shelf(index)
    _play_stock_sound()
    _save_game()
    _message("Stocked %s. Visible products now appear on the shelf." % str(PRODUCTS[index]["name"]))
    _refresh_ui()

func _change_price(index: int, delta: int) -> void:
    if index < 0 or index >= PRODUCTS.size():
        return
    var proposed_price: int = clampi(prices[index] + delta, 1, 999)
    if consignment_stock[index] > 0 and proposed_price <= int(PRODUCTS[index]["cost"]):
        _message("Consignment must be priced above its supplier settlement cost.")
        return
    prices[index] = proposed_price
    _tutorial_event("price")
    _refresh_shelf(index)
    _play_click()
    _save_game()
    _refresh_ui()

func _buy_display_upgrade() -> void:
    if display_level >= DISPLAY_LEVEL_PRICES.size():
        _message("Display upgrades are already at the prototype maximum.")
        return
    var cost: int = DISPLAY_LEVEL_PRICES[display_level]
    if cash < cost:
        _message("Upgrade costs $%d. Not enough cash." % cost)
        return
    cash -= cost
    day_cost += cost
    display_level += 1
    _update_display_decor()
    _save_game()
    _play_click()
    _message("Display upgraded to Level %d. Customers have a higher buying budget." % display_level)
    _refresh_ui()

func _recreate_shelf_views() -> void:
    for i in range(SHELF_POINTS.size()):
        _refresh_shelf(i)
    _update_display_decor()
    _set_carried_model(carrying)

func _refresh_ui() -> void:
    if hud_status == null:
        return
    var carry_string := "empty hands" if carrying < 0 else str(PRODUCTS[carrying]["name"])
    hud_status.text = ("DAY %d  |  CASH $%d  |  SOLD %d" % [day,cash,total_sales]) if compact_hud else "LCG-P05 · DAY %d · CASH $%d · SOLD %d · Hot: %s\nGoal %d/%d | Display LV%d | Carrying: %s" % [day,cash,total_sales,str(CATEGORY_NAMES[_featured_category()]),day_sales,_daily_sales_target(),display_level,carry_string]
    hud_help_panel.visible = not compact_hud
    if hud_bottom_panel != null:
        hud_bottom_panel.visible = not compact_hud or message_time > 0.0
    _refresh_picture_guides()
    _refresh_context_action_hint()
    var hit: int = _looked_shelf()
    if customer_phase == "needs_help" and _player_can_assist_customer():
        hud_hint.text = "[E ?] Help the shopper find a stocked alternative. No charge and entirely optional."
    elif _looking_at_counter():
        hud_hint.text = "[E] Open shop desk at the checkout counter  ·  TAB also works."
    elif carrying >= 0 and _near_matching_shelf():
        hud_hint.text = "[E] Place %s on the marked display. No exact aiming needed." % str(PRODUCTS[carrying]["name"])
    elif hit >= 0:
        hud_hint.text = "%s  |  Stock: %d  |  Price: $%d\nE = place carried item  ·  +/- = adjust price  ·  TAB = store desk" % [str(PRODUCTS[hit]["name"]), stock[hit], prices[hit]]
    else:
        var shopper_state: String = "No shopper inside" if customer_phase == "idle" else "Shopper: %s" % customer_phase.capitalize()
        hud_hint.text = "WASD move · mouse look · TAB desk · F1 help · ESC pause · E stock · N end day\n%s · Visit shelves and checkout to complete sales." % shopper_state
    if community_finale_access != null:
        community_finale_access.disabled = not _community_finale_unlocked()
        community_finale_access.text = "REPLAY FINALE" if community_finale_seen else "COMMUNITY DAY"
    if desk_stats != null:
        desk_stats.text = "Cash $%d | Goal %d/%d | Visitors %d | Display LV%d | Consignment %s\n%s · 9 shared displays" % [cash,day_sales,_daily_sales_target(),day_visitors,display_level,("AVAILABLE" if _is_stranded() else "LOCKED"),_demand_message()]
    if desk_page_label != null:
        desk_page_label.text = "PAGE %d / %d" % [desk_page + 1, ceili(float(PRODUCTS.size()) / float(CATALOG_PAGE_SIZE))]
    for row_index in range(CATALOG_PAGE_SIZE):
        var i: int = _catalog_index(row_index)
        var row: Dictionary = desk_rows[row_index]
        var available: bool = total_sales >= int(PRODUCTS[i]["unlock"])
        var in_supplier_stock: bool = _supplier_available(i)
        var hot_tag: String = "  [HOT]" if _is_featured_product(i) else ""
        var condition: String = str(PRODUCTS[i].get("condition", "Good"))
        var description: String = "%s%s · %s\nCost $%d | Price $%d | Shelf %d/6" % [str(PRODUCTS[i]["name"]), hot_tag, condition, _supplier_cost(i), prices[i], _shelf_inventory_count(_product_shelf(i))]
        if not available:
            description += "  [unlock %d sales]" % int(PRODUCTS[i]["unlock"])
        elif not in_supplier_stock:
            description += "  [no supplier stock today]"
        else:
            description += "  [available %d]" % supplier_remaining[i]
        (row["label"] as Label).text = description
        (row["picture"] as TextureRect).texture = PRODUCT_PICTURE_TEXTURES[i]
        (row["icon"] as TextureRect).texture = load("res://assets/comfort_icons/category_%d.png" % int(PRODUCT_CATEGORIES[i]))
        (row["buy"] as Button).disabled = not available or not in_supplier_stock or carrying != -1 or cash < _supplier_cost(i) or _shelf_inventory_count(_product_shelf(i)) >= SHELF_CAPACITY
        (row["stock"] as Button).disabled = carrying != i
        (row["minus"] as Button).disabled = not available
        (row["plus"] as Button).disabled = not available
        var can_bulk: bool = available and in_supplier_stock and supplier_remaining[i] >= 3 and total_sales >= 3 and _shelf_inventory_count(_product_shelf(i)) <= SHELF_CAPACITY - 3 and cash >= _bulk_price(i)
        (row["bulk"] as Button).disabled = not can_bulk
        (row["bulk"] as Button).tooltip_text = "Three items on the shared display, 10%% off supplier total: $%d" % _bulk_price(i)
        (row["label"] as Label).tooltip_text = "Item %02d: %s. Image shows its game model; BUY purchases it; STOCK places it." % [i + 1, str(PRODUCTS[i]["name"])]
    _refresh_tutorial_ui()
    if secondhand_events != null:
        secondhand_events.call("refresh_entry")
    if desk_upgrade_button != null:
        if display_level < DISPLAY_LEVEL_PRICES.size():
            var cost: int = DISPLAY_LEVEL_PRICES[display_level]
            desk_upgrade_button.text = "DISPLAY LV%d -> LV%d   $%d" % [display_level,display_level+1,cost]
            desk_upgrade_button.disabled = cash < cost
        else:
            desk_upgrade_button.text = "DISPLAY LEVEL MAX"
            desk_upgrade_button.disabled = true

func _looked_shelf() -> int:
    if ray == null:
        return -1
    ray.force_raycast_update()
    if ray.is_colliding():
        var collider: Object = ray.get_collider()
        if collider is StaticBody3D and (collider as StaticBody3D).has_meta("item_index"):
            var display_slot: int = int((collider as StaticBody3D).get_meta("item_index"))
            if carrying >= 0 and _product_shelf(carrying) == display_slot:
                return carrying
            return _shelf_focus(display_slot)
    return -1

func _looking_at_counter() -> bool:
    if ray == null:
        return false
    ray.force_raycast_update()
    var obj: Object = ray.get_collider() if ray.is_colliding() else null
    return obj is StaticBody3D and (obj as StaticBody3D).get_meta("kind", "") == "desk"

func _interact_shelf() -> void:
    if customer_phase == "needs_help" and _player_can_assist_customer():
        _assist_customer()
        return
    if _looking_at_counter():
        _toggle_desk()
        return
    var idx: int = _looked_shelf()
    # Counter always wins; otherwise the correct nearby shelf can accept the
    # carried item without demanding precise mouse aiming at a small collider.
    if carrying >= 0 and _near_matching_shelf():
        _stock_from_desk(carrying)
        return
    if idx < 0:
        _message("Move closer to your marked shelf, or point at the checkout desk and press E. TAB opens the desk.")
    elif carrying == idx:
        _stock_from_desk(idx)
    elif carrying >= 0:
        _message("Wrong shelf. You are carrying %s." % str(PRODUCTS[carrying]["name"]))
    else:
        _message("%s: %d in stock, priced $%d. Use +/- or the store desk to change price." % [str(PRODUCTS[idx]["name"]),stock[idx],prices[idx]])

func _unhandled_input(event: InputEvent) -> void:
    # One press skips the studio ident. It never forces the player to sit through
    # an animation, and no second ident is shown on New Game or Continue.
    if splash_ui != null and splash_ui.visible:
        var skip_now: bool = false
        if event is InputEventKey and event.pressed and not event.echo:
            skip_now = event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE
        elif event is InputEventMouseButton and event.pressed:
            skip_now = event.button_index == MOUSE_BUTTON_LEFT
        elif event is InputEventScreenTouch and event.pressed:
            skip_now = true
        if skip_now:
            _skip_splash()
            get_viewport().set_input_as_handled()
        return
    if close_day_confirm_ui != null and close_day_confirm_ui.visible:
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            _cancel_finish_day()
            get_viewport().set_input_as_handled()
        return
    if privacy_safety != null and bool(privacy_safety.call("is_open")):
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            privacy_safety.call("close_or_cancel")
            get_viewport().set_input_as_handled()
        return
    if healthy_play != null and bool(healthy_play.call("is_open")):
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            healthy_play.call("close_panel")
            get_viewport().set_input_as_handled()
        return
    if customer_bargain_ui != null and customer_bargain_ui.visible:
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            _decline_customer_bargain()
            get_viewport().set_input_as_handled()
        return
    if secondhand_events != null and bool(secondhand_events.call("is_open")):
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            secondhand_events.call("_close")
            get_viewport().set_input_as_handled()
        return
    if resident_offer_ui != null and resident_offer_ui.visible:
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            _close_resident_offer()
            get_viewport().set_input_as_handled()
        return
    if community_finale_ui != null and community_finale_ui.visible:
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            _close_community_finale()
            get_viewport().set_input_as_handled()
        return
    if help_ui != null and help_ui.visible:
        if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_F1):
            _close_help()
            get_viewport().set_input_as_handled()
        return
    if new_game_confirm_ui != null and new_game_confirm_ui.visible:
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            _cancel_new_game()
            get_viewport().set_input_as_handled()
        return
    if not playing or settings_ui.visible:
        return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F1:
            _open_help()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_TAB:
            _toggle_desk()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_ESCAPE:
            if ledger_ui.visible:
                _close_ledger()
            elif pause_ui.visible:
                _resume_pause()
            elif desk_ui.visible:
                _toggle_desk()
            elif report_ui.visible:
                _close_report()
            else:
                _open_pause()
        elif not desk_ui.visible and not report_ui.visible and not pause_ui.visible and not ledger_ui.visible:
            if event.keycode == KEY_E:
                _interact_shelf()
            elif event.keycode == KEY_N:
                _request_finish_day()
            elif event.keycode == KEY_EQUAL or event.keycode == KEY_KP_ADD:
                _change_price(_looked_shelf(), 1)
            elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
                _change_price(_looked_shelf(), -1)
    elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not desk_ui.visible and not report_ui.visible and not paused and not ledger_ui.visible:
        var sensitivity: float = LOOK_SENSITIVITY * (0.78 if gentle_camera else 1.0) * float(LOOK_SPEED_MULTIPLIERS[mouse_speed_mode])
        player.rotate_y(-event.relative.x * sensitivity)
        head.rotation.x = clampf(head.rotation.x - event.relative.y * sensitivity, -1.12, 1.12)
    elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not desk_ui.visible and not report_ui.visible and not paused and not ledger_ui.visible:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    if not playing or desk_ui.visible or report_ui.visible or settings_ui.visible or paused or ledger_ui.visible or help_ui.visible or community_finale_ui.visible or resident_offer_ui.visible or customer_bargain_ui.visible or close_day_confirm_ui.visible or (secondhand_events != null and bool(secondhand_events.call("is_open"))) or not DisplayServer.window_is_focused() or (healthy_play != null and bool(healthy_play.call("is_open"))) or (privacy_safety != null and bool(privacy_safety.call("is_open"))):
        return
    var motion := Vector3.ZERO
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        motion.z -= 1
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        motion.z += 1
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        motion.x -= 1
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        motion.x += 1
    motion = motion.normalized().rotated(Vector3.UP, player.rotation.y)
    player.velocity.x = motion.x * MOVEMENT_SPEED
    player.velocity.z = motion.z * MOVEMENT_SPEED
    player.velocity.y -= 9.8 * delta
    player.move_and_slide()
    _update_footsteps(delta, player.is_on_floor() and motion.length_squared() > 0.01)
    if player.position.y < -2.0:
        player.position = Vector3(0,0.12,5.2)
        player.velocity = Vector3.ZERO

func _advance_splash(delta: float) -> void:
    # Deterministic function so the actual alpha envelope can be checked in
    # Godot QA without depending on a headless process having window focus.
    if splash_ui == null or not splash_ui.visible:
        return
    splash_remaining = maxf(0.0, splash_remaining - maxf(delta, 0.0))
    if splash_logo != null:
        var elapsed: float = BRAND_SPLASH_SECONDS - splash_remaining
        var fade_in: float = clampf(elapsed / BRAND_FADE_IN_SECONDS, 0.0, 1.0)
        var fade_out: float = clampf(splash_remaining / BRAND_FADE_OUT_SECONDS, 0.0, 1.0)
        splash_logo.modulate.a = minf(fade_in, fade_out)
        # Always static and non-flashing; no rotation or particle strobe.
    # Float additions (0.25 + 0.75 + 0.64 + 0.16) can leave a sub-millisecond remainder.
    # Closing at an epsilon preserves the 1.8s timing promise in the actual game.
    if splash_remaining <= 0.0001:
        _skip_splash()

func _process(delta: float) -> void:
    if splash_ui != null and splash_ui.visible and DisplayServer.window_is_focused():
        _advance_splash(delta)
    # The world simulation pauses behind menus; keep the skeletal animation
    # on the same clock so shoppers do not walk in place while the day is frozen.
    if customer_animation_player != null and is_instance_valid(customer_animation_player):
        var freeze_customer: bool = not DisplayServer.window_is_focused() or not playing or desk_ui.visible or report_ui.visible or settings_ui.visible or paused or ledger_ui.visible or help_ui.visible or community_finale_ui.visible or resident_offer_ui.visible or customer_bargain_ui.visible or close_day_confirm_ui.visible or (secondhand_events != null and bool(secondhand_events.call("is_open")))
        customer_animation_player.speed_scale = 0.0 if freeze_customer else 1.0
    if not playing or not DisplayServer.window_is_focused() or report_ui.visible or settings_ui.visible or paused or ledger_ui.visible or help_ui.visible or community_finale_ui.visible or resident_offer_ui.visible or customer_bargain_ui.visible or close_day_confirm_ui.visible or (secondhand_events != null and bool(secondhand_events.call("is_open"))):
        return
    if message_time > 0.0:
        message_time -= delta
        if message_time <= 0.0:
            hud_message.text = "TAB: shop desk · N: close day · ESC: pause"
    if not desk_ui.visible:
        day_clock += delta
        if day_clock >= DAY_SECONDS:
            _finish_day()
            return
        customer_timer -= delta
        if customer_phase == "idle" and customer_timer <= 0.0:
            _spawn_customer()
        elif customer_phase != "idle":
            _update_customer(delta)
    _refresh_ui()

func _dismiss_customer() -> void:
    # One active visitor at a time. Dismiss at closing and between saved sessions.
    if customer != null and is_instance_valid(customer):
        customer.queue_free()
    customer = null
    shopper_reaction = null
    customer_visual = null
    customer_animation_player = null
    customer_animation_state = ""
    customer_agreed_price = -1
    customer_bargain_offer = -1
    if customer_bargain_ui != null:
        customer_bargain_ui.visible = false
    customer_phase = "idle"
    customer_target = -1
    customer_route.clear()
    customer_waypoint = 0
    customer_walk_phase = 0.0

func _find_customer_alternative() -> int:
    # A physical, affordable and category-relevant substitute; never invent merchandise.
    if customer_target < 0 or customer_target >= PRODUCTS.size():
        return -1
    var group_id: int = int(PRODUCT_CATEGORIES[customer_target])
    var best_index: int = -1
    var cheapest_price: int = 100000
    for i in range(PRODUCTS.size()):
        if i == customer_target or int(PRODUCT_CATEGORIES[i]) != group_id:
            continue
        if stock[i] > 0 and prices[i] <= customer_budget and prices[i] < cheapest_price:
            cheapest_price = prices[i]
            best_index = i
    return best_index

func _player_can_assist_customer() -> bool:
    return player != null and customer != null and is_instance_valid(customer) and player.global_position.distance_to(customer.global_position) <= 3.2

func _assist_customer() -> void:
    if customer_phase != "needs_help" or not _player_can_assist_customer():
        return
    var alternative: int = _find_customer_alternative()
    if alternative < 0:
        _message("No matching in-stock alternative; the visitor can leave normally.")
        return
    customer_target = alternative
    day_assisted_shoppers += 1
    total_assisted_shoppers += 1
    customer_phase = "enter"
    customer_wait = 0.0
    if shopper_reaction != null:
        shopper_reaction.text = "+"
        shopper_reaction.modulate = Color("c2ebc5")
    _route_customer_to_shelf()
    _play_customer_animation("walk")
    _message("You suggested %s. The visitor will look before deciding." % str(PRODUCTS[alternative]["name"]))
    _save_game()

func _route_customer_to_shelf() -> void:
    customer_route.clear()
    customer_waypoint = 0
    # Central aisle -> target aisle -> shelf. Avoid the register and display furniture.
    var arrival: Vector3 = shelves[_product_shelf(customer_target)].to_global(Vector3(0.0, -0.95, 1.68))
    arrival.y = 0.0
    customer_route.append(Vector3(0.0, 0.0, 5.2))
    # The front-left display is behind a low coffee table. Approach from
    # the outer aisle instead of walking visually through that furniture.
    if _product_shelf(customer_target) == 5:
        customer_route.append(Vector3(0.0, 0.0, 2.0))
        customer_route.append(Vector3(-4.9, 0.0, 2.0))
    else:
        customer_route.append(Vector3(0.0, 0.0, arrival.z))
    customer_route.append(arrival)

func _route_customer_to_checkout() -> void:
    customer_route.clear()
    customer_waypoint = 0
    # Transactions only settle after the visitor reaches the register.
    if customer_target >= 0 and _product_shelf(customer_target) == 5:
        customer_route.append(Vector3(-4.9, 0.0, 2.0))
        customer_route.append(Vector3(0.0, 0.0, 2.0))
    else:
        customer_route.append(Vector3(0.0, 0.0, customer.position.z))
    customer_route.append(Vector3(0.0, 0.0, customer_checkout.z))
    customer_route.append(customer_checkout)
    customer_phase = "checkout"
    _play_customer_animation("walk")
    _message("Shopper is heading to the checkout counter.")

func _route_customer_to_exit() -> void:
    customer_route.clear()
    customer_waypoint = 0
    if customer_target >= 0 and _product_shelf(customer_target) == 5 and customer_phase == "decline":
        customer_route.append(Vector3(-4.9, 0.0, 2.0))
        customer_route.append(Vector3(0.0, 0.0, 2.0))
    else:
        customer_route.append(Vector3(0.0, 0.0, customer.position.z))
    customer_route.append(customer_entry)
    customer_phase = "exit"
    _play_customer_animation("walk")

func _walk_customer(delta: float) -> bool:
    if customer_waypoint >= customer_route.size():
        return true
    var destination: Vector3 = customer_route[customer_waypoint]
    var offset: Vector3 = destination - customer.position
    offset.y = 0.0
    if offset.length() <= 0.14:
        customer.position = destination
        customer_waypoint += 1
        return customer_waypoint >= customer_route.size()
    var step: Vector3 = offset.normalized() * minf(delta * CUSTOMER_WALK_SPEED, offset.length())
    customer.position += step
    if step.length() > 0.0001:
        # Interpolate body yaw to avoid instant 90-degree character snaps.
        var desired_yaw: float = atan2(-step.x, -step.z)
        customer.rotation.y = lerp_angle(customer.rotation.y, desired_yaw, clampf(delta * CUSTOMER_TURN_SPEED, 0.0, 1.0))
        _play_customer_animation("walk")
        customer_walk_phase += delta * 11.0
        if customer_visual != null:
            # Imported characters animate their own skeleton. Bob is only a fallback.
            customer_visual.position.y = 0.0 if reduced_motion or customer_animation_player != null else 0.025 * absf(sin(customer_walk_phase))
    return false

func _spawn_customer() -> void:
    if customer != null and is_instance_valid(customer):
        return
    customer_timer = _customer_arrival_time()
    customer_agreed_price = -1
    customer_bargain_offer = -1
    var available: Array[int] = []
    var stocked: Array[int] = []
    for i in range(PRODUCTS.size()):
        if total_sales >= int(PRODUCTS[i]["unlock"]):
            available.append(i)
            if stock[i] > 0:
                stocked.append(i)
    if available.is_empty():
        return
    # Most visitors seek goods in stock, but some ask for unavailable categories.
    var candidates: Array[int] = available
    if stocked.size() > 0 and rng.randf() < 0.75:
        candidates = stocked
    # More visitors target the clearly signposted daily category, provided
    # that category is present in the candidate pool. Unstocked requests remain possible.
    var featured: Array[int] = []
    for item_index in candidates:
        if _is_featured_product(item_index):
            featured.append(item_index)
    if not featured.is_empty() and rng.randf() < HOT_CATEGORY_INTEREST:
        customer_target = featured[rng.randi_range(0, featured.size() - 1)]
    else:
        customer_target = candidates[rng.randi_range(0, candidates.size() - 1)]
    var reference_price: float = float(PRODUCTS[customer_target]["target"])
    var demand_budget: float = HOT_CATEGORY_BUDGET_BONUS if _is_featured_product(customer_target) else 1.0
    customer_budget = maxi(1, roundi(reference_price * demand_budget * rng.randf_range(0.80, 1.35)) + display_level * 4)
    day_visitors += 1
    total_visitors += 1
    customer_phase = "enter"
    customer = Node3D.new()
    customer.name = "VisitingShopper"
    customer.position = customer_entry
    world.add_child(customer)
    # Existing Kenney characters plus three new CC0 variants; all bundled locally.
    var appearance_pool := ["character-male-a", "character-female-a", "character-female-c",
        "character-female-b", "character-female-d", "character-male-b"]
    # A small cast is acceptable in an early prototype, but the same model
    # should never be selected twice in a row when five alternatives exist.
    var appearance_id: int = rng.randi_range(0, appearance_pool.size() - 1 if last_customer_appearance < 0 else appearance_pool.size() - 2)
    if appearance_id >= last_customer_appearance and last_customer_appearance >= 0:
        appearance_id += 1
    last_customer_appearance = appearance_id
    var character_name: String = appearance_pool[appearance_id]
    if character_name in ["character-female-b", "character-female-d", "character-male-b"]:
        customer_visual = _third_party_character(customer, "res://assets/selected_v015/characters/%s.glb" % character_name, 2.15)
    else:
        customer_visual = _model(customer, character_name, Vector3.ZERO, 2.15)
    customer_animation_player = _find_customer_animation_player(customer_visual)
    customer_animation_state = ""
    # Symbols are recognizable without reading a line of English. Never flash them.
    shopper_reaction = Label3D.new()
    shopper_reaction.name = "CustomerReactionSymbol"
    shopper_reaction.position = Vector3(0.0, 2.45, 0.0)
    shopper_reaction.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    shopper_reaction.font_size = 64
    shopper_reaction.pixel_size = 0.005
    shopper_reaction.modulate = Color("f6e4b0")
    shopper_reaction.text = "?"
    customer.add_child(shopper_reaction)
    _play_customer_animation("walk")
    _play_entry_bell()
    _route_customer_to_shelf()
    _message("A shopper is looking for %s." % str(PRODUCTS[customer_target]["name"]))

func _update_customer(delta: float) -> void:
    if customer == null or not is_instance_valid(customer):
        _dismiss_customer()
        return
    match customer_phase:
        "enter":
            if _walk_customer(delta):
                customer_phase = "browse"
                customer_wait = 1.15
                _play_customer_animation("interact-right")
        "browse":
            customer_wait -= delta
            if customer_wait <= 0.20 and customer_wait > 0.0:
                _play_customer_animation("idle")
            if customer_wait <= 0.0:
                # Unavailable or overpriced products are rejected at the shelf.
                if stock[customer_target] <= 0 or prices[customer_target] > customer_budget:
                    if _find_customer_alternative() >= 0 and rng.randf() < 0.28:
                        customer_phase = "needs_help"
                        customer_wait = 7.0
                        if shopper_reaction != null:
                            shopper_reaction.text = "E ?"
                        _play_customer_animation("idle")
                        _message("This shopper is asking about another item. Walk nearby and press E to help, or ignore it.")
                    elif _can_offer_bargain() and rng.randf() < 0.45:
                        _open_customer_bargain()
                    else:
                        _complete_sale()
                        customer_phase = "decline"
                        customer_wait = 0.50
                        _play_customer_animation("emote-no")
                else:
                    customer_phase = "pickup"
                    customer_wait = 0.6
                    _play_customer_animation("pick-up")
        "negotiating":
            pass # The world stops until the player accepts or declines the offer.
        "needs_help":
            customer_wait -= delta
            if customer_wait <= 0.0:
                # A newly stocked or discounted requested item still goes via checkout.
                if stock[customer_target] > 0 and prices[customer_target] <= customer_budget:
                    customer_phase = "pickup"
                    customer_wait = 0.6
                    _play_customer_animation("pick-up")
                else:
                    _complete_sale() # A refusal only, never a phantom transaction.
                    customer_phase = "decline"
                    customer_wait = 0.50
                    _play_customer_animation("emote-no")
        "pickup":
            customer_wait -= delta
            if customer_wait <= 0.0:
                _route_customer_to_checkout()
        "decline":
            customer_wait -= delta
            if customer_wait <= 0.0:
                _route_customer_to_exit()
        "checkout":
            if _walk_customer(delta):
                customer_phase = "pay"
                customer_wait = 0.65
                _play_customer_animation("interact-left")
        "pay":
            customer_wait -= delta
            if customer_wait <= 0.18 and customer_wait > 0.0:
                _play_customer_animation("idle")
            if customer_wait <= 0.0:
                # Recheck stock and price in case the player changed them mid-visit.
                _complete_sale()
                _route_customer_to_exit()
        "exit":
            if _walk_customer(delta):
                _dismiss_customer()
        _:
            _dismiss_customer()

func _complete_sale() -> void:
    if customer_target < 0:
        return
    var product_name: String = str(PRODUCTS[customer_target]["name"])
    if stock[customer_target] <= 0:
        if shopper_reaction != null:
            shopper_reaction.text = "!"
            shopper_reaction.modulate = Color("f6d3a6")
        day_feedback["missing"] = int(day_feedback.get("missing", 0)) + 1
        day_no_stock += 1
        _message("No sale: %s is out of stock." % product_name)
        return
    var actual_price: int = prices[customer_target] if customer_agreed_price < 0 else mini(prices[customer_target],customer_agreed_price)
    if actual_price > customer_budget:
        if shopper_reaction != null:
            shopper_reaction.text = "!"
            shopper_reaction.modulate = Color("f6d3a6")
        day_feedback["expensive"] = int(day_feedback.get("expensive", 0)) + 1
        day_over_budget += 1
        _message("No sale: %s priced at $%d, shopper budget $%d." % [product_name,prices[customer_target],customer_budget])
        return
    if shopper_reaction != null:
        shopper_reaction.text = "+"
        shopper_reaction.modulate = Color("c2ebc5")
    stock[customer_target] -= 1
    var supplier_settlement: int = 0
    if consignment_stock[customer_target] > 0:
        consignment_stock[customer_target] -= 1
        supplier_settlement = int(PRODUCTS[customer_target]["cost"])
        day_cost += supplier_settlement
        total_wholesale += supplier_settlement
        day_consignment_paid += supplier_settlement
        total_consignment_paid += supplier_settlement
    cash += actual_price - supplier_settlement
    total_sales += 1
    day_sales += 1
    day_feedback["pleased"] = int(day_feedback.get("pleased", 0)) + 1
    _tutorial_event("sale")
    if _is_featured_product(customer_target):
        day_hot_sales += 1
    day_revenue += actual_price
    total_revenue += actual_price
    _refresh_shelf(customer_target)
    _play_sale()
    _save_game()
    _message("SOLD! %s for $%d%s. Cash, inventory and save updated." % [product_name,actual_price,(" (supplier $%d settled)" % supplier_settlement if supplier_settlement > 0 else "")])
    if total_sales == 5 and not sold_milestone:
        sold_milestone = true
        _message("Milestone: 5 sales! More second-hand finds unlock as you grow. Check the supplier catalogue.")
        _save_game()
    _refresh_ui()

func _finish_day() -> void:
    if not playing or report_ui.visible or customer_bargain_ui.visible:
        return
    if customer_phase != "idle":
        # Visitors already exiting after a sale/refusal are NOT unserved.
        if customer_phase != "exit":
            day_unserved_at_close += 1
        _dismiss_customer()
    var goal_bonus: int = 0
    if day_sales >= _daily_sales_target() and not day_goal_awarded:
        goal_bonus = 8 + mini(day, 10) * 2
        cash += goal_bonus
        total_goal_rewards += goal_bonus
        day_goal_awarded = true
    var day_cash_change: int = day_revenue - day_cost + goal_bonus
    var record: Dictionary = {"day":day,"visitors":day_visitors,"sales":day_sales,"revenue":day_revenue,"outlays":day_cost,"bonus":goal_bonus,"cash_change":day_cash_change,"consignment_paid":day_consignment_paid,"trend":str(CATEGORY_NAMES[_featured_category()]),"hot_sales":day_hot_sales,"shop_event":day_event_id,"feedback":day_feedback.duplicate(true),"bargains":day_bargain_offers,"bargains_accepted":day_bargain_accepted,"assisted":day_assisted_shoppers}
    daily_history.append(record)
    if daily_history.size() > LEDGER_MAX_DAYS:
        daily_history.pop_front()
    # A completed business day is durably recorded before the summary is shown.
    # On load, matching current day + last ledger day rolls forward once.
    _save_game()
    var conversion: float = 0.0
    if day_visitors > 0:
        conversion = 100.0 * float(day_sales) / float(day_visitors)
    report_title.text = "DAY %d  ·  BUSINESS SUMMARY" % day
    report_text.add_theme_font_size_override("font_size", 19)
    report_text.text = "Visitors: %d | Sales: %d | Conversion: %.0f%%\n%s\nDaily target: %d/%d | Reward: $%d\nRevenue: $%d | Expenses: $%d | Net cash: $%d\nFeedback: happy %d / missing %d / costly %d\nPrice offers: %d (%d accepted) | Customers helped: %d | Closing missed: %d\nLifetime sales: %d | Cash: $%d | Display LV%d" % [day_visitors,day_sales,conversion,_day_event_description(),day_sales,_daily_sales_target(),goal_bonus,day_revenue,day_cost,day_revenue-day_cost+goal_bonus,int(day_feedback.get("pleased",0)),int(day_feedback.get("missing",0)),int(day_feedback.get("expensive",0)),day_bargain_offers,day_bargain_accepted,day_assisted_shoppers,day_unserved_at_close,total_sales,cash,display_level]
    report_ui.visible = true
    desk_ui.visible = false
    _refresh_tutorial_ui()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _advance_day() -> void:
    day += 1
    day_clock = 0.0
    day_revenue = 0
    day_sales = 0
    day_cost = 0
    day_visitors = 0
    day_no_stock = 0
    day_over_budget = 0
    day_unserved_at_close = 0
    day_goal_awarded = false
    day_consignment_paid = 0
    day_hot_sales = 0
    day_feedback = {"pleased":0,"missing":0,"expensive":0}
    day_bargain_offers = 0
    day_bargain_accepted = 0
    day_bargain_rejected = 0
    day_assisted_shoppers = 0
    _roll_day_event()
    supplier_remaining.clear()
    for i in range(PRODUCTS.size()):
        supplier_remaining.append(_daily_supplier_quota(i))
    _roll_resident_offer()
    if secondhand_events != null:
        secondhand_events.call("new_day", day, total_sales)

func _close_report() -> void:
    if not report_ui.visible:
        return
    report_ui.visible = false
    _advance_day()
    _save_game()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _message("New day! " + _demand_message())
    _refresh_ui()

func _save_game() -> bool:
    if qa_mode:
        return not qa_force_save_failure
    var payload := {
        "version":21,
        "cash":cash,"total_sales":total_sales,"total_revenue":total_revenue,"total_wholesale":total_wholesale,
        "day":day,"day_clock":day_clock,"day_revenue":day_revenue,"day_cost":day_cost,"day_sales":day_sales,
        "display_level":display_level,"carrying":carrying,"stock":stock.duplicate(),"prices":prices.duplicate(),
        "supplier_remaining":supplier_remaining.duplicate(),
        "resident_offer_index":resident_offer_index,"resident_offer_cost":resident_offer_cost,"resident_offer_decided":resident_offer_decided,
        "resident_purchases_total":resident_purchases_total,"resident_purchase_spending":resident_purchase_spending,
        "day_event_id":day_event_id,"last_day_event_id":last_day_event_id,"last_day_event_day":last_day_event_day,
        "event_days_total":event_days_total,"day_feedback":day_feedback.duplicate(true),"last_customer_appearance":last_customer_appearance,
        "day_bargain_offers":day_bargain_offers,"day_bargain_accepted":day_bargain_accepted,"day_bargain_rejected":day_bargain_rejected,
        "day_assisted_shoppers":day_assisted_shoppers,"total_assisted_shoppers":total_assisted_shoppers,
        "day_visitors":day_visitors,"total_visitors":total_visitors,"day_no_stock":day_no_stock,
        "day_over_budget":day_over_budget,"day_unserved_at_close":day_unserved_at_close,"total_goal_rewards":total_goal_rewards,"day_goal_awarded":day_goal_awarded,
        "milestone":sold_milestone,"community_finale_seen":community_finale_seen,"music_volume":music_volume,"sfx_volume":sfx_volume,"master_volume":master_volume,
        "consignment_stock":consignment_stock.duplicate(),"day_consignment_paid":day_consignment_paid,"day_hot_sales":day_hot_sales,
        "tutorial_active":tutorial_active,"tutorial_step":tutorial_step,
        "total_consignment_paid":total_consignment_paid,"daily_history":daily_history.duplicate(true),
        "secondhand_events":secondhand_events.call("export_state") if secondhand_events != null else {}
    }
    return _write_save_safely(SAVE_PATH, payload)

func _write_save_safely(path: String, data: Dictionary) -> bool:
    # Write a complete, parseable .pending first. Never truncate the last
    # committed file until the staged file has been validated.
    # Unit tests use a separate user://QA path; no test may touch real saves.
    if qa_mode and path == SAVE_PATH:
        return false
    var pending_path: String = path + SAVE_PENDING_SUFFIX
    var pending: FileAccess = FileAccess.open(pending_path, FileAccess.WRITE)
    if pending == null:
        push_warning("Shop save: could not open temporary file")
        return false
    pending.store_string(JSON.stringify(data))
    pending.flush()
    var pending_error: Error = pending.get_error()
    pending.close()
    if pending_error != OK or _read_save_data(pending_path).is_empty():
        push_warning("Shop save: temporary data is incomplete or invalid")
        return false
    # Keep a complete older version available across interrupted writes.
    # Never replace a good backup with an already-corrupt primary save.
    if not _read_save_data(path).is_empty():
        var previous: String = FileAccess.get_file_as_string(path)
        var backup: FileAccess = FileAccess.open(path + ".bak", FileAccess.WRITE)
        if backup == null:
            push_warning("Shop save: could not write backup")
            return false
        backup.store_string(previous)
        backup.flush()
        var backup_error: Error = backup.get_error()
        backup.close()
        if backup_error != OK or _read_save_data(path + ".bak").is_empty():
            push_warning("Shop save: backup verification failed; original kept")
            return false
    var source_abs: String = ProjectSettings.globalize_path(pending_path)
    var target_abs: String = ProjectSettings.globalize_path(path)
    if DirAccess.rename_absolute(source_abs, target_abs) == OK:
        return true
    # Some Windows filesystems cannot rename over an existing destination.
    # The verified .bak must exist before removing the original file.
    if FileAccess.file_exists(path):
        if _read_save_data(path + ".bak").is_empty():
            push_warning("Shop save: refusing unsafe replace without backup")
            return false
        if DirAccess.remove_absolute(target_abs) != OK:
            push_warning("Shop save: cannot replace existing file")
            return false
    if DirAccess.rename_absolute(source_abs, target_abs) != OK:
        push_warning("Shop save: staged data remains available for recovery")
        return false
    return not _read_save_data(path).is_empty()

func _read_save_data(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    # JSON.parse_string logs engine ERROR for deliberately corrupt saves.
    # Instance parsing returns ERR_PARSE_ERROR without turning safe recovery into a false engine failure.
    var parser: JSON = JSON.new()
    if parser.parse(FileAccess.get_file_as_string(path)) != OK:
        return {}
    var parsed: Variant = parser.data
    if not (parsed is Dictionary):
        return {}
    var data: Dictionary = parsed
    if not data.has("stock") or not data.has("prices"):
        return {}
    if not (data["stock"] is Array) or not (data["prices"] is Array):
        return {}
    var stored_count: int = (data["stock"] as Array).size()
    if stored_count != (data["prices"] as Array).size() or not (stored_count == SHELF_POINTS.size() or stored_count == PRODUCTS.size()):
        return {}
    return data

func _select_valid_save_data(path: String) -> Dictionary:
    # Order matters: a validated .pending is the most recent crash-survivable
    # version. All paths must pass _read_save_data validation before use.
    var staged: Dictionary = _read_save_data(path + SAVE_PENDING_SUFFIX)
    if not staged.is_empty():
        recovered_save = true
        return staged
    var primary: Dictionary = _read_save_data(path)
    if not primary.is_empty():
        return primary
    var backup: Dictionary = _read_save_data(path + ".bak")
    if not backup.is_empty():
        recovered_save = true
    return backup

func _resume_after_saved_day() -> bool:
    # A prior session may have saved the day's ledger before the player
    # dismissed the end-of-day report. Move to the next day exactly once.
    if daily_history.is_empty():
        return false
    var last_record: Dictionary = daily_history[daily_history.size() - 1]
    if int(last_record.get("day", -1)) != day:
        return false
    _advance_day()
    return true

func _load_game() -> bool:
    recovered_save = false
    var data: Dictionary = _select_valid_save_data(SAVE_PATH)
    if data.is_empty():
        return false
    if not data.has("stock") or not data.has("prices"):
        return false
    if not (data["stock"] is Array) or not (data["prices"] is Array):
        return false
    var stored_count: int = (data["stock"] as Array).size()
    if stored_count != (data["prices"] as Array).size() or not (stored_count == SHELF_POINTS.size() or stored_count == PRODUCTS.size()):
        return false
    cash = maxi(0, int(data.get("cash",80)))
    total_sales = maxi(0,int(data.get("total_sales",0)))
    total_revenue = maxi(0,int(data.get("total_revenue",0)))
    total_wholesale = maxi(0,int(data.get("total_wholesale",0)))
    day = maxi(1,int(data.get("day",1)))
    day_clock = clampf(float(data.get("day_clock",0.0)),0.0,DAY_SECONDS - 1.0)
    day_revenue = maxi(0,int(data.get("day_revenue",0)))
    day_cost = maxi(0,int(data.get("day_cost",0)))
    day_sales = maxi(0,int(data.get("day_sales",0)))
    day_visitors = maxi(0,int(data.get("day_visitors",0)))
    total_visitors = maxi(0,int(data.get("total_visitors",0)))
    day_no_stock = maxi(0,int(data.get("day_no_stock",0)))
    day_over_budget = maxi(0,int(data.get("day_over_budget",0)))
    day_unserved_at_close = maxi(0,int(data.get("day_unserved_at_close",0)))
    total_goal_rewards = maxi(0,int(data.get("total_goal_rewards",0)))
    day_goal_awarded = bool(data.get("day_goal_awarded",false))
    display_level = clampi(int(data.get("display_level",0)),0,DISPLAY_LEVEL_PRICES.size())
    carrying = clampi(int(data.get("carrying",-1)),-1,PRODUCTS.size()-1)
    sold_milestone = bool(data.get("milestone",false))
    community_finale_seen = bool(data.get("community_finale_seen",false))
    # Legacy saves are already ongoing games, so their tutorial is optional.
    tutorial_active = bool(data.get("tutorial_active",false))
    tutorial_step = clampi(int(data.get("tutorial_step",TUTORIAL_ACTIONS.size())),0,TUTORIAL_ACTIONS.size())
    if tutorial_step >= TUTORIAL_ACTIONS.size():
        tutorial_active = false
    day_consignment_paid = maxi(0,int(data.get("day_consignment_paid",0)))
    day_hot_sales = maxi(0,int(data.get("day_hot_sales",0)))
    resident_purchases_total = maxi(0,int(data.get("resident_purchases_total",0)))
    resident_purchase_spending = maxi(0,int(data.get("resident_purchase_spending",0)))
    day_event_id = str(data.get("day_event_id", "none"))
    if day_event_id != "none" and day_event_id not in DAY_EVENT_IDS:
        day_event_id = "none"
    last_day_event_id = str(data.get("last_day_event_id", "none"))
    if last_day_event_id != "none" and last_day_event_id not in DAY_EVENT_IDS:
        last_day_event_id = "none"
    last_day_event_day = mini(day, int(data.get("last_day_event_day", -100)))
    event_days_total = maxi(0,int(data.get("event_days_total", 0)))
    last_customer_appearance = clampi(int(data.get("last_customer_appearance", -1)),-1,5)
    day_bargain_offers = clampi(int(data.get("day_bargain_offers",0)),0,1)
    day_bargain_accepted = clampi(int(data.get("day_bargain_accepted",0)),0,day_bargain_offers)
    day_bargain_rejected = clampi(int(data.get("day_bargain_rejected",0)),0,day_bargain_offers)
    day_assisted_shoppers = maxi(0,int(data.get("day_assisted_shoppers",0)))
    total_assisted_shoppers = maxi(0,int(data.get("total_assisted_shoppers",0)))
    day_feedback = {"pleased":0,"missing":0,"expensive":0}
    var saved_feedback: Variant = data.get("day_feedback", {})
    if saved_feedback is Dictionary:
        for label in day_feedback.keys():
            day_feedback[label] = maxi(0,int((saved_feedback as Dictionary).get(label,0)))
    total_consignment_paid = maxi(0,int(data.get("total_consignment_paid",0)))
    daily_history.clear()
    var history_value: Variant = data.get("daily_history",[])
    if history_value is Array:
        for entry in history_value:
            if entry is Dictionary and daily_history.size() < LEDGER_MAX_DAYS:
                daily_history.append(entry)
    stock.clear()
    consignment_stock.clear()
    prices.clear()
    for i in range(PRODUCTS.size()):
        var old_quantity: int = int((data["stock"] as Array)[i]) if i < stored_count else 0
        stock.append(clampi(old_quantity, 0, SHELF_CAPACITY))
        var consigned: int = 0
        var saved_consignment: Variant = data.get("consignment_stock", [])
        if saved_consignment is Array and i < (saved_consignment as Array).size():
            consigned = clampi(int((saved_consignment as Array)[i]), 0, stock[i])
        consignment_stock.append(consigned)
        var existing_price: int = int((data["prices"] as Array)[i]) if i < stored_count else int(PRODUCTS[i]["base"])
        var loaded_price: int = clampi(existing_price,1,999)
        if consigned > 0:
            loaded_price = maxi(loaded_price, int(PRODUCTS[i]["cost"]) + 1)
        prices.append(loaded_price)
    # Restore daily quotas for v0.15.4 saves; older saves get the baseline
    # allocation once, then preserve consumption on subsequent saves.
    supplier_remaining.clear()
    var saved_supplier: Variant = data.get("supplier_remaining", [])
    for i in range(PRODUCTS.size()):
        var daily_quota: int = _daily_supplier_quota(i)
        var remaining: int = daily_quota
        if saved_supplier is Array and i < (saved_supplier as Array).size():
            remaining = clampi(int((saved_supplier as Array)[i]), 0, daily_quota)
        supplier_remaining.append(remaining)
    # v0.15.5 keeps one resident offer per day; missing keys from v0.15.4
    # receive an ordinary deterministic offer, while new saves retain the
    # accepted/declined decision and asking price.
    if data.has("resident_offer_index") and data.has("resident_offer_decided") and data.has("resident_offer_cost"):
        resident_offer_index = clampi(int(data.get("resident_offer_index", -1)), -1, PRODUCTS.size() - 1)
        resident_offer_cost = maxi(0, int(data.get("resident_offer_cost", 0)))
        resident_offer_decided = bool(data.get("resident_offer_decided", false))
        if day < 2 or (resident_offer_index >= 0 and resident_offer_cost <= 0):
            _roll_resident_offer()
    else:
        _roll_resident_offer()
    # A malformed imported save may contain 6 units in each of three
    # products sharing one shelf. Trim to the shared physical capacity.
    for slot in range(SHELF_POINTS.size()):
        var room: int = SHELF_CAPACITY
        for i in range(PRODUCTS.size()):
            if _product_shelf(i) != slot:
                continue
            stock[i] = mini(stock[i], room)
            consignment_stock[i] = mini(consignment_stock[i], stock[i])
            room -= stock[i]
    # Prefer separate audio preferences; v0.9 saves can still restore legacy values.
    if not FileAccess.file_exists(SETTINGS_PATH):
        music_volume = clampf(float(data.get("music_volume",0.5)),0.0,1.0)
        sfx_volume = clampf(float(data.get("sfx_volume",0.7)),0.0,1.0)
        master_volume = clampf(float(data.get("master_volume",0.75)),0.0,1.0)
    _apply_audio()
    if secondhand_events != null:
        secondhand_events.call("import_state", data.get("secondhand_events", {}), day, total_sales)
    # v0.12 and v0.13 can store a closed-day report immediately before
    # the user clicks CONTINUE. Resume safely into the following day instead
    # of closing the same date twice and awarding another report entry.
    if _resume_after_saved_day():
        _save_game()
    return true

func _save_audio_settings() -> void:
    if qa_mode:
        return
    var prefs: Dictionary = {"master":master_volume,"music":music_volume,"sfx":sfx_volume,"large_text":large_text,"high_contrast":high_contrast,"reduced_motion":reduced_motion,"picture_guides":picture_guides,"compact_hud":compact_hud,"gentle_camera":gentle_camera,"soft_lighting":soft_lighting,"mouse_speed_mode":mouse_speed_mode}
    var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(prefs))
        file.close()

func _load_audio_settings() -> void:
    if not FileAccess.file_exists(SETTINGS_PATH):
        return
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS_PATH))
    if not (parsed is Dictionary):
        return
    var prefs: Dictionary = parsed
    master_volume = clampf(float(prefs.get("master",0.75)),0.0,1.0)
    music_volume = clampf(float(prefs.get("music",0.50)),0.0,1.0)
    sfx_volume = clampf(float(prefs.get("sfx",0.70)),0.0,1.0)
    large_text = bool(prefs.get("large_text", false))
    high_contrast = bool(prefs.get("high_contrast", false))
    reduced_motion = bool(prefs.get("reduced_motion", true))
    picture_guides = bool(prefs.get("picture_guides", true))
    compact_hud = bool(prefs.get("compact_hud", false))
    gentle_camera = bool(prefs.get("gentle_camera", true))
    soft_lighting = bool(prefs.get("soft_lighting", true))
    mouse_speed_mode = clampi(int(prefs.get("mouse_speed_mode", 1)), 0, LOOK_SPEED_MULTIPLIERS.size() - 1)
