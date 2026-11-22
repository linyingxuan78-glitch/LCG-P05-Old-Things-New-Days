extends RefCounted
## Legal notices from the exact engine binary that loaded this game.
## Engine API documented at https://docs.godotengine.org/en/4.4/classes/class_engine.html
static func render() -> String:
    var lines: PackedStringArray = PackedStringArray()
    lines.append("GODOT ENGINE: BUNDLED COMPONENTS & LICENCE TEXTS")
    lines.append("Source: Engine.get_copyright_info(), Engine.get_license_info() from the running binary")
    lines.append("This is not a commercial trademark clearance or legal certificate.")
    lines.append("Engine version: " + str(Engine.get_version_info().get("string", "unknown")))
    lines.append("")
    lines.append("ENGINE-REPORTED THIRD-PARTY COPYRIGHTS")
    var copyright_info: Array[Dictionary] = Engine.get_copyright_info()
    for component in copyright_info:
        lines.append("COMPONENT: " + str(component.get("name", "Unnamed")))
        var parts: Array = component.get("parts", [])
        for part in parts:
            if not (part is Dictionary):
                continue
            lines.append("  Licence: " + str(part.get("license", "not reported")))
            for owner in part.get("copyright", []):
                lines.append("  Copyright: " + str(owner))
            for file_path in part.get("files", []):
                lines.append("  File: " + str(file_path))
    lines.append("")
    lines.append("ENGINE-REPORTED THIRD-PARTY LICENCE TEXTS")
    var licenses: Dictionary = Engine.get_license_info()
    var keys: Array = licenses.keys()
    keys.sort()
    for key in keys:
        lines.append("--- " + str(key) + " ---")
        lines.append(str(licenses[key]))
        lines.append("")
    lines.append("GODOT CORE MIT LICENCE")
    lines.append(Engine.get_license_text())
    lines.append("Official source: https://godotengine.org/license/")
    return "\n".join(lines)
