bbjack01.py

import os

import sqlite3

conn = sqlite3.connect("inventory.db")

cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS inventory(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_name TEXT,
    extension TEXT,
    size_bytes INTEGER,
    full_path TEXT
)
""")

root = "."

for current_path, dirs, files in os.walk(root):

    for file in files:

        full_path = os.path.join(current_path, file)

        try:
            size = os.path.getsize(full_path)
        except:
            size = 0

        ext = os.path.splitext(file)[1]

        cursor.execute("""
        INSERT INTO inventory(
            file_name,
            extension,
            size_bytes,
            full_path
        )
        VALUES(?,?,?,?)
        """, (file, ext, size, full_path))

conn.commit()

print("Inventory generated.")