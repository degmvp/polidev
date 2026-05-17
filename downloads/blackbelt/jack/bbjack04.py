bbjack04.py

import os

file_path = input("Binary file: ")

if not os.path.exists(file_path):

    print("File not found.")
    exit()

with open(file_path, "rb") as f:

    data = f.read(256)

print("\n=== BINARY INSPECTOR ===\n")

for i in range(0, len(data), 16):

    chunk = data[i:i+16]

    hex_values = " ".join(f"{b:02X}" for b in chunk)

    ascii_values = "".join(
        chr(b) if 32 <= b <= 126 else "."
        for b in chunk
    )

    print(f"{i:08X}  {hex_values:<48}  {ascii_values}")