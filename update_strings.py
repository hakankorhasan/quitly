import json

file_path = "quitly/quitly/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_strings = {}
for key, value in data.get("strings", {}).items():
    new_key = key.replace("Quitly", "Quit Smoking")
    
    # Update translations inside the value
    for lang, loc in value.get("localizations", {}).items():
        if "stringUnit" in loc and "value" in loc["stringUnit"]:
            loc["stringUnit"]["value"] = loc["stringUnit"]["value"].replace("Quitly", "Quit Smoking")
            
    new_strings[new_key] = value

if "strings" in data:
    data["strings"] = new_strings

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
