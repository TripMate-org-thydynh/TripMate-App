import os

filepath = r"C:\Users\ASUS\.gemini\antigravity\brain\7289e55c-3ffb-45c9-8f6f-02e68c844b16\scratch\ui_specifications.txt"
if os.path.exists(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        
    sections = content.split("=========================================")
    found = []
    for sec in sections:
        if "58" in sec or "monthly_analytics" in sec:
            found.append("Found section:\n" + sec)
            
    with open("screen_58_found.txt", "w", encoding="utf-8") as out:
        out.write("\n\n\n".join(found))
    print("Done! Wrote findings to screen_58_found.txt")
