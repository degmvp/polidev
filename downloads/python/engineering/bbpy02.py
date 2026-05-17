bbpy02.py
import pyodbc
import csv

conn = pyodbc.connect(
    "DRIVER={SQL Server};SERVER=localhost;DATABASE=master;Trusted_Connection=yes;"
)

cursor = conn.cursor()

cursor.execute("""
SELECT
    s.name AS schema_name,
    o.name AS object_name,
    o.type_desc
FROM sys.objects o
INNER JOIN sys.schemas s
    ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
ORDER BY s.name, o.type_desc, o.name
""")

with open("metadata_inventory.csv", "w", newline="", encoding="utf-8") as f:

    writer = csv.writer(f)

    writer.writerow([
        "schema_name",
        "object_name",
        "type_desc"
    ])

    for row in cursor.fetchall():
        writer.writerow(row)

print("Metadata inventory exported.")