from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError, InterfaceError
import sys
import getpass

# Konfigurerar UTF-8 för att svenska tecken ska fungera korrekt i terminalen.
sys.stdout.reconfigure(encoding='utf-8')
sys.stdin.reconfigure(encoding='utf-8')

# SQL Server instance och databas.
server = r"FANNY\SQLEXPRESS"
database = "BookStoreDB"

# Användarnamn och lösenord för SQL Server. 
# Lösenordet hämtas säkert via getpass så att det inte visas i terminalen.
db_user = "BookStorePythonUser"
db_password = getpass.getpass(
    "Ange lösenord för BookStorePythonUser (Notera att texten du skriver inte visas): "
)

# Skapar anslutningssträng för SQL Server via ODBC Driver 17.
connection_string = (
    f"mssql+pyodbc://{db_user}:{db_password}@"
    + server +
    "/" + database +
    "?driver=ODBC+Driver+17+for+SQL+Server"
)

# Skapar SQLAlchemy engine för databaskopplingen.
engine = create_engine(connection_string)

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

# try-except -block för att hantera potentiella fel vid inloggning och input från användaren.
try:
    # Öppnar databaskopplingen och verifierar att inloggningen fungerar.
    with engine.connect() as connection:
        
        search_term = input("Sök efter boktitel: ")

        # Exekverar SQL-frågan med parameteriserad sökning.
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

# Hanterar fel vid felaktigt användarnamn/lösenord eller anslutningsproblem.
except (OperationalError, InterfaceError) as e:
    print("""
Fel vid inloggning eller anslutning till databasen.
Kontrollera lösenordet och försök igen.
""")