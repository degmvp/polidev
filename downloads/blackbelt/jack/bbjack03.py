bbjack03.py

import os
import csv

root = "."

extensions = [".csv", ".txt", ".sql"]

for current_path, dirs, files in os.walk(root):

    for file in files:

        ext = os.path.splitext(file)[1].lower()

        if ext in extensions:

            full_path = os.path.join(current_path, file)

            print(f"\nIMPORTING: {full_path}")

            try:

                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:

                    lines = f.readlines()

                    print(f"LINES: {len(lines)}")

            except Exception as e:

                print(f"ERROR: {e}")