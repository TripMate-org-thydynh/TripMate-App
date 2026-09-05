with open("screen_58_found.txt", "r", encoding="utf-8") as f:
    text = f.read()

# Let's split by "Found section:"
blocks = text.split("Found section:")
for block in blocks:
    if "58_" in block or "monthly_analytics" in block or "Monthly Analytics" in block:
        print("--- BLOCK ---")
        print(block[:2000])
