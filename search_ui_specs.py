import os

filepath = r"C:\Users\ASUS\.gemini\antigravity\brain\7289e55c-3ffb-45c9-8f6f-02e68c844b16\scratch\ui_specifications.txt"
out_lines = []

if os.path.exists(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        lines = content.splitlines()
        for i, line in enumerate(lines):
            if "58" in line or "analytics" in line.lower() or "expense" in line.lower():
                out_lines.append(f"Line {i+1}: {line}")
                # print 10 lines after
                for j in range(1, 15):
                    if i + j < len(lines):
                        out_lines.append(f"  + {j}: {lines[i+j]}")

with open("ui_spec_search.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(out_lines))
print("Done searching ui_specifications.txt! Wrote results to ui_spec_search.txt")
