from sqlalchemy import create_engine, text
import sys

# Konfigurerar UTF-8 för att svenska tecken ska fungera korrekt i terminalen.
sys.stdout.reconfigure(encoding='utf-8')
sys.stdin.reconfigure(encoding='utf-8')

# SQL Server instance och databas.
server = r"FANNY\SQLEXPRESS"
database = "BookStoreDB"

# Skapar anslutningssträng för SQL Server via ODBC Driver 17.
connection_string = (
    "mssql+pyodbc://@"
    + server +
    "/" + database +
    "?driver=ODBC+Driver+17+for+SQL+Server"
    "&trusted_connection=yes"
)

# Skapar SQLAlchemy engine för databaskopplingen.
engine = create_engine(connection_string)

# Användaren anger en boktitel att söka efter.
search_term = input("Sök efter boktitel: ")

# Parameteriserad SQL-fråga som hämtar böcker och lagerstatus.
# LIKE används för fritextsökning.
query = text("""
SELECT 
    b.Title,
    b.ISBN13,
    s.Name AS Store,
    i.Quantity
FROM Books b
JOIN Inventory i ON b.ISBN13 = i.ISBN13
JOIN Stores s ON i.StoreID = s.StoreID
WHERE b.Title LIKE :search
ORDER BY b.Title, s.Name;
""")

# Öppnar databaskopplingen och exekverar SQL-frågan.
with engine.connect() as connection:
    result = connection.execute(query, {"search": f"%{search_term}%"})
    rows = result.fetchall()

    if not rows:
        print("Inga böcker matchade din sökning.")
    else:
        for row in rows:
            print(f"""
Title: {row.Title}
ISBN13: {row.ISBN13}
Store: {row.Store}
Quantity: {row.Quantity}
-------------------------
""")