import os

scratch_dir = r"C:\Users\ASUS\.gemini\antigravity\brain\7289e55c-3ffb-45c9-8f6f-02e68c844b16\scratch"
out_lines = []

for filename in os.listdir(scratch_dir):
    if filename.endswith(".txt"):
        filepath = os.path.join(scratch_dir, filename)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        if "58" in content or "monthly_analytics" in content:
            out_lines.append(f"=== Found in {filename} ===")
            idx = 0
            while True:
                idx = content.find("58", idx)
                if idx == -1:
                    break
                start = max(0, idx - 100)
                end = min(len(content), idx + 300)
                out_lines.append(f"Snippet at {idx}:\n{content[start:end]}\n---")
                idx += 2
                
            idx = 0
            while True:
                idx = content.find("monthly_analytics", idx)
                if idx == -1:
                    break
                start = max(0, idx - 100)
                end = min(len(content), idx + 300)
                out_lines.append(f"Snippet at {idx} (monthly_analytics):\n{content[start:end]}\n---")
                idx += len("monthly_analytics")

with open("search_58_results.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(out_lines))
print("Done! Wrote findings to search_58_results.txt")
