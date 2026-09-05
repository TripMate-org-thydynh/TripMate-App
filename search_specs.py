import os

scratch_dir = r"C:\Users\ASUS\.gemini\antigravity\brain\7289e55c-3ffb-45c9-8f6f-02e68c844b16\scratch"
for filename in os.listdir(scratch_dir):
    if filename.endswith(".txt"):
        filepath = os.path.join(scratch_dir, filename)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            if "58" in content:
                print(f"Found '58' in {filename}")
                # print lines containing 58
                lines = content.splitlines()
                for i, line in enumerate(lines):
                    if "58" in line or "analytics" in line or "expense" in line or "Monthly" in line:
                        print(f"  Line {i+1}: {line}")
