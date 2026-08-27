bbpy03.py
import os

root = "."

for current_path, dirs, files in os.walk(root):

    print(f"\nDIRECTORY: {current_path}")

    for file in files:

        full_path = os.path.join(current_path, file)

        try:
            size = os.path.getsize(full_path)
        except:
            size = 0

        print(f"{file} | {size} bytes")