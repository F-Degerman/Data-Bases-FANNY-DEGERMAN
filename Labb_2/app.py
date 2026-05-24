from sqlalchemy import create_engine, text
import sys
import getpass

# Konfigurerar UTF-8 för att svenska tecken ska fungera korrekt i terminalen.
sys.stdout.reconfigure(encoding='utf-8')
sys.stdin.reconfigure(encoding='utf-8')

# SQL Server instance och databas.
server = r"FANNY\SQLEXPRESS"
database = "BookStoreDB"

# Användaren anger inloggningsuppgifter.
db_user = input("Ange användarnamn: ")
db_password = getpass.getpass("Ange lösenord (texten visas inte medan du skriver): ")

# Skapar anslutningssträng för SQL Server via ODBC Driver 17.
# Inloggningsuppgifter skrivs inte direkt i koden.
connection_string = (
    f"mssql+pyodbc://{db_user}:{db_password}@"
    + server +
    "/" + database +
    "?driver=ODBC+Driver+17+for+SQL+Server"
)

# Skapar SQLAlchemy engine för databaskopplingen.
engine = create_engine(connection_string)

# Användaren anger en boktitel att söka efter.
search_term = input("Sök efter boktitel: ")

# Parameteriserad SQL-fråga som hämtar böcker och lagerstatus.
# LIKE används för fritextsökning.
query = text("""
SELECT 
    Title,
    ISBN13,
    Store,
    Quantity
FROM BookSearchView
WHERE Title LIKE :search
ORDER BY Title, Store;
""")

# Öppnar databaskopplingen och exekverar SQL-frågan.
with engine.connect() as connection:
    result = connection.execute(query, {"search": f"%{search_term}%"})
    rows = result.fetchall()

    # Skriver ut meddelande om inga böcker hittades.
    if not rows:
        print("Inga böcker matchade din sökning.")

    # Skriver annars ut resultaten i läsbart format.
    else:
        for row in rows:
            print(f"""
Title: {row.Title}
ISBN13: {row.ISBN13}
Store: {row.Store}
Quantity: {row.Quantity}
-------------------------
""")