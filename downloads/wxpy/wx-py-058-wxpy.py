bbpy05.py
import os

extensions = [
    ".py",
    ".sql",
    ".js",
    ".html",
    ".css",
    ".cpp",
    ".rs",
    ".go"
]

root = "."

index = []

for current_path, dirs, files in os.walk(root):

    for file in files:

        ext = os.path.splitext(file)[1].lower()

        if ext in extensions:

            full_path = os.path.join(current_path, file)

            index.append(full_path)

print("\nUNIVERSAL CODE INDEX\n")

for item in sorted(index):
    print(item)

print(f"\nTOTAL FILES: {len(index)}")