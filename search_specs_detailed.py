import os

scratch_dir = r"C:\Users\ASUS\.gemini\antigravity\brain\7289e55c-3ffb-45c9-8f6f-02e68c844b16\scratch"
out_lines = []

for filename in os.listdir(scratch_dir):
    if filename.endswith(".txt"):
        filepath = os.path.join(scratch_dir, filename)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            lines = content.splitlines()
            for i, line in enumerate(lines):
                if any(x in line.lower() for x in ["58_monthly", "58_", "monthly_analytics", "monthly analytics", "screen: 58"]):
                    out_lines.append(f"{filename} | Line {i+1}: {line}")
                    # Capture 20 lines after the match
                    for j in range(1, 40):
                        if i + j < len(lines):
                            out_lines.append(f"  + {j}: {lines[i+j]}")

with open("search_results.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(out_lines))
print("Done searching! Wrote results to search_results.txt")
