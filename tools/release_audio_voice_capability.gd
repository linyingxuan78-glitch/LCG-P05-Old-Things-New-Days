extends SceneTree
## A real Windows Godot audio import and OS voice-availability check.
## This does NOT prove that sound can be heard on a human PC.
const OUTPUT: String = "res://documentation/windows_visual_previews/audio_voice_capability.json"
const AUDIO_FILES: Array[String] = [
    "res://assets/audio/A Brand New Wisdom.ogg",
    "res://assets/audio/Just Saying Tho.ogg",
    "res://assets/audio/Swinging Sweet.ogg",
    "res://assets/audio/Winter Dust.ogg",
    "res://assets/audio/ui_1.ogg",
    "res://assets/audio/ui_2.ogg",
    "res://assets/audio/ui_3.ogg",
    "res://assets/audio/ui_4.ogg"
]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var sounds: Array[Dictionary] = []
    var bad: bool = false
    for path in AUDIO_FILES:
        var stream: AudioStream = load(path) as AudioStream
        if stream == null or stream.get_length() <= 0.0:
            bad = true
            push_error("RELEASE AUDIO IMPORT FAILED: " + path)
        else:
            sounds.append({"file":path.trim_prefix("res://"),
                "length_seconds":snappedf(stream.get_length(),0.001)})
    var english_voices: PackedStringArray = DisplayServer.tts_get_voices_for_language("en")
    var tts_configured: bool = bool(ProjectSettings.get_setting("audio/general/text_to_speech",false))
    var record: Dictionary = {"platform":OS.get_name(),"audio_imports":sounds,
        "audio_files_expected":AUDIO_FILES.size(),
        "audio_imports_ok":not bad and sounds.size()==AUDIO_FILES.size(),
        "godot_text_to_speech_enabled":tts_configured,
        "english_system_voices_available":english_voices.size(),
        "note":"Availability only; no sound was played to a human listener and this does not prove TTS intelligibility"}
    var out: FileAccess = FileAccess.open(ProjectSettings.globalize_path(OUTPUT),FileAccess.WRITE)
    if out != null:
        out.store_string(JSON.stringify(record,"  "))
        out.close()
    print("RELEASE AUDIO/VOICE CAPABILITY: ",JSON.stringify(record))
    if bad or not tts_configured:
        push_error("RELEASE AUDIO/VOICE FAILED: missing audio stream or disabled TTS configuration")
        quit(1)
        return
    print("RELEASE AUDIO/VOICE IMPORT PASSED; physical playback and comprehension still NOT TESTED")
    quit(0)
