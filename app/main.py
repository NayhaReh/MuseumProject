# Nayha Rehman
# Himaal Ishaq
# Simon Ryabinkin

import mysql.connector
import json
from access_lvls import admin_access, data_entry_access, user_access

# Load host, port, database from JSON
with open(".vscode/settings.json") as f:
    config = json.load(f)

print("Welcome to the Art Museum Database Management System")
print("Access levels: \n1. Admin \n2. Data entry \n3. Browsing")

# Ask user for access level
while True:
    access_level = input("Enter access level (1/2/3): ").strip()
    if access_level not in ['1', '2', '3']:
        print("Invalid access level. Try again.\n")
    else:
        break

# Connect to MySQL
conn = None
while conn is None:
    password = input("Enter MySQL password (or type 'exit' to quit): ").strip()

    if password.lower() == "exit":
        print("Exiting program.")
        exit(0)

    try:
        conn = mysql.connector.connect(
            host=config.get("host", "localhost"),
            port=config.get("port", 3306),
            user="root",
            password=password
        )
        print("Connected to MySQL server!\n")

    except mysql.connector.Error as err:
        print("Incorrect password.")
        print("Please try again.\n")


# Ensure database exists
try:
    with conn.cursor() as cursor:
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {config.get('database', 'art_museum')}")
        cursor.execute(f"USE {config.get('database', 'art_museum')}")
    print(f"Using database: {config.get('database', 'art_museum')}\n")
except mysql.connector.Error as err:
    print(f"Error creating/using database: {err}")
    conn.close()
    exit(1)

# Load SQL file
try:
    with open('art_museum.sql', 'r') as f:
        sql_script = f.read()

    # Split statements and execute
    statements = [stmt.strip() for stmt in sql_script.split(';') if stmt.strip()]
    for stmt in statements:
        try:
            with conn.cursor() as cursor:
                cursor.execute(stmt)
            conn.commit()
        except mysql.connector.Error as err:
            print(f"Error executing statement:\n{stmt}\n{err}\n")
    print("Database tables and data loaded successfully!\n")
except FileNotFoundError:
    print("SQL file not found. Please make sure 'art_museum.sql' is in the same folder.\n")

# Access level functions
if access_level == '1':
    admin_access(conn)
elif access_level == '2':
    data_entry_access(conn)
else:
    user_access(conn)

conn.close()
