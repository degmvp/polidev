bbjack02.py

import os

root = "."

stats = {
    "directories":0,
    "files":0,
    "extensions":{}
}

for current_path, dirs, files in os.walk(root):

    stats["directories"] += len(dirs)

    for file in files:

        stats["files"] += 1

        ext = os.path.splitext(file)[1].lower()

        if ext not in stats["extensions"]:
            stats["extensions"][ext] = 0

        stats["extensions"][ext] += 1

print("\n=== METADATA ENGINE ===\n")

print(f"Directories : {stats['directories']}")
print(f"Files       : {stats['files']}")

print("\nExtensions:\n")

for ext, total in sorted(stats["extensions"].items()):
    print(f"{ext:10} -> {total}")