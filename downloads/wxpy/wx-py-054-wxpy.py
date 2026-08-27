bbpy01.py
import pyodbc

conn = pyodbc.connect(
    "DRIVER={SQL Server};SERVER=localhost;DATABASE=master;Trusted_Connection=yes;"
)

cursor = conn.cursor()

cursor.execute("""
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION
""")

html = """
<html>
<head>
<title>SQL Documentation</title>
</head>
<body>
<h1>SQL Documentation</h1>
<table border='1'>
<tr>
<th>Schema</th>
<th>Table</th>
<th>Column</th>
<th>Type</th>
</tr>
"""

for row in cursor.fetchall():
    html += f"""
    <tr>
        <td>{row.TABLE_SCHEMA}</td>
        <td>{row.TABLE_NAME}</td>
        <td>{row.COLUMN_NAME}</td>
        <td>{row.DATA_TYPE}</td>
    </tr>
    """

html += "</table></body></html>"

with open("sql_documentation.html", "w", encoding="utf-8") as f:
    f.write(html)

print("Documentation generated.")