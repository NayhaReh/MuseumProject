# Nayha Rehman
# Himaal Ishaq
# Simon Ryabinkin

import mysql.connector

# ------------------------
# Helper function to print results neatly
def print_results(cursor, results):
    if not results:
        print("No records found.\n")
        return

    columns = [desc[0] for desc in cursor.description]
    col_widths = [
        max(len(str(col)), max(len(str(row[i])) if row[i] is not None else 4 for row in results))
        for i, col in enumerate(columns)
    ]

    # Print header
    header = " | ".join(f"{col:{col_widths[i]}}" for i, col in enumerate(columns))
    print(header)
    print("-" * len(header))

    # Print rows
    for row in results:
        row_str = " | ".join(f"{str(item) if item is not None else 'NULL':{col_widths[i]}}" for i, item in enumerate(row))
        print(row_str)
    print()


# ------------------------
# Admin Access
def admin_access(db):
    while True:
        choice = input("To execute a query from console, type 1.\nTo execute an SQL file, type anything else ('exit' to quit): ").strip()
        if choice.lower() == "exit":
            break

        if choice == "1":
            query = input("Enter SQL query (or 'exit' to quit): ").strip()
            if query.lower() == "exit":
                continue

            try:
                with db.cursor() as cursor:
                    cursor.execute(query)
                    if query.strip().lower().startswith("select"):
                        results = cursor.fetchall()
                        print_results(cursor, results)
                    else:
                        db.commit()
                        print("Query executed successfully.\n")
            except mysql.connector.Error as err:
                print(f"Error: {err}\n")

        else:
            file_path = input("Enter the path to the SQL file: ").strip()
            try:
                with open(file_path, 'r') as file:
                    sql_script = file.read()
                statements = [stmt.strip() for stmt in sql_script.split(';') if stmt.strip()]
                for stmt in statements:
                    try:
                        with db.cursor() as cursor:
                            cursor.execute(stmt)
                            if stmt.lower().startswith("select"):
                                results = cursor.fetchall()
                                print_results(cursor, results)
                            else:
                                db.commit()
                    except mysql.connector.Error as err:
                        print(f"Error in statement: {stmt}\n{err}\n")
                print("SQL file executed successfully!\n")
            except FileNotFoundError:
                print("File not found. Please check the path and try again.\n")


# ------------------------
# Data Entry Access
def data_entry_access(db):
    table_dict = {
        '0': 'ARTIST', '1': 'ART_OBJECT', '2': 'COLLECTIONS', '3': 'EXHIBITION',
        '4': 'PAINTING', '5': 'SCULPTURE', '6': 'STATUE', '7': 'OTHER',
        '8': 'PERMANENT_COLLECTION', '9': 'BORROWED'
    }

    while True:
        print("\nSelect data table:")
        print("0. Artists\n1. Art objects\n2. Collections\n3. Exhibitions")
        print("4. Paintings\n5. Sculptures\n6. Statues\n7. Other objects")
        print("8. Permanent collection\n9. Borrowed\nType 'exit' to quit.")
        table_selection = input(">> ").strip()

        if table_selection.lower() == "exit":
            break
        if table_selection not in table_dict:
            print("Invalid choice.\n")
            continue

        table = table_dict[table_selection]
        action = input(f"Type 'view', 'insert', 'search', 'delete' or 'exit' for {table}: ").strip().lower()
        if action == "exit":
            continue

        # ------------------------
        # VIEW
        if action == "view":
            try:
                with db.cursor() as cursor:
                    cursor.execute(f"SELECT * FROM {table}")
                    results = cursor.fetchall()
                    print_results(cursor, results)
            except mysql.connector.Error as err:
                print(f"Error: {err}\n")

        # ------------------------
        # INSERT
        elif action == "insert":
            try:
                with db.cursor() as cursor:
                    cursor.execute(f"DESCRIBE {table}")
                    desc = cursor.fetchall()
                    columns = [row[0] for row in desc]
                    types = [row[1] for row in desc]
                print("\nColumn order:", columns)

                source = input("\nType '1' for guided input\nType '2' to load from file\nChoice: ").strip()
                if source == "1":
                    values = []
                    for i, col in enumerate(columns):
                        col_type = types[i]
                        if 'date' in col_type.lower():
                            prompt = f"Enter value for {col} (YYYY-MM-DD or NULL): "
                        else:
                            prompt = f"Enter value for {col} (or NULL): "
                        value = input(prompt).strip()
                        values.append(None if value.upper() == "NULL" else value)
                    
                    # Special handling for ART_OBJECT: ensure artist exists
                    if table == 'ART_OBJECT':
                        artist_name = values[1]  # Artist is the second column
                        if artist_name is not None:
                            with db.cursor() as cursor:
                                cursor.execute("SELECT Name FROM ARTIST WHERE Name = %s", (artist_name,))
                                if not cursor.fetchone():
                                    print(f"Artist '{artist_name}' does not exist. Let's add them to the database.")
                                    date_born = input("Date born (YYYY-MM-DD or NULL): ").strip()
                                    date_born = None if date_born.upper() == "NULL" else date_born
                                    date_died = input("Date died (YYYY-MM-DD or NULL): ").strip()
                                    date_died = None if date_died.upper() == "NULL" else date_died
                                    country = input("Country of origin: ").strip()
                                    epoch = input("Epoch: ").strip()
                                    main_style = input("Main style: ").strip()
                                    desc = input("Description: ").strip()
                                    cursor.execute("INSERT INTO ARTIST (Name, Date_born, Date_died, Country_of_origin, Epoch, Main_style, Description) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                                                   (artist_name, date_born, date_died, country, epoch, main_style, desc))
                                    db.commit()
                                    print("Artist added successfully.\n")
                    
                    placeholders = ", ".join(["%s"] * len(columns))
                    query = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})"
                    with db.cursor() as cursor:
                        cursor.execute(query, values)
                        db.commit()
                        print("Record inserted successfully.\n")

                elif source == "2":
                    file_path = input("Enter file path: ").strip()
                    try:
                        with open(file_path, 'r') as file:
                            lines = file.readlines()
                        placeholders = ", ".join(["%s"] * len(columns))
                        query = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})"
                        with db.cursor() as cursor:
                            for line in lines:
                                raw_values = [v.strip() for v in line.split(',')]
                                values = [None if v.upper() == "NULL" else v for v in raw_values]
                                
                                # Special handling for ART_OBJECT: ensure artist exists
                                if table == 'ART_OBJECT':
                                    artist_name = values[1] if len(values) > 1 else None
                                    if artist_name is not None:
                                        cursor.execute("SELECT Name FROM ARTIST WHERE Name = %s", (artist_name,))
                                        if not cursor.fetchone():
                                            print(f"Artist '{artist_name}' does not exist in file. Skipping this record.")
                                            continue  # Skip inserting this art object
                                
                                cursor.execute(query, values)
                            db.commit()
                        print("All records inserted successfully from file.\n")
                    except FileNotFoundError:
                        print("File not found.\n")
                else:
                    print("Invalid source.\n")
            except mysql.connector.Error as err:
                print(f"Error: {err}\n")

        # ------------------------
        # SEARCH
        elif action == "search":
            try:
                with db.cursor() as cursor:
                    cursor.execute(f"DESCRIBE {table}")
                    columns = [col[0] for col in cursor.fetchall()]
                    print("\nColumn order:", columns)
                    column = input("Enter column name to search by: ").strip()
                    value = input(f"Enter value for {column}: ").strip()
                    cursor.execute(f"SELECT * FROM {table} WHERE {column} = %s", (value,))
                    results = cursor.fetchall()
                    print_results(cursor, results)
            except mysql.connector.Error as err:
                print(f"Error: {err}\n")

        # ------------------------
        # DELETE
        elif action == "delete":
            try:
                with db.cursor() as cursor:
                    cursor.execute(f"DESCRIBE {table}")
                    columns = [col[0] for col in cursor.fetchall()]
                    print("\nColumn order:", columns)
                    column = input("Enter column name to search by: ").strip()
                    value = input(f"Enter value for {column}: ").strip()
                    cursor.execute(f"DELETE FROM {table} WHERE {column} = %s", (value,))
                    if cursor.rowcount > 0:
                        db.commit()
                        print("Record(s) deleted successfully.\n")
                    else:
                        print("No matching records found.\n")
            except mysql.connector.Error as err:
                print(f"Error: {err}\n")

        else:
            print("Invalid action.\n")


# ------------------------
# User Access
def user_access(db):
    table_dict = {
        '0': 'ARTIST', '1': 'ART_OBJECT', '2': 'COLLECTIONS', '3': 'EXHIBITION',
        '4': 'PAINTING', '5': 'SCULPTURE', '6': 'STATUE', '7': 'OTHER',
        '8': 'PERMANENT_COLLECTION', '9': 'BORROWED'
    }

    while True:
        print("Select data table to view:\n0. Artists\n1. Art objects\n2. Collections\n3. Exhibitions")
        print("4. Paintings\n5. Sculptures\n6. Statues\n7. Other objects\n8. Permanent collection\n9. Borrowed items\nType 'exit' to quit.")
        choice = input(">> ").strip()
        if choice.lower() == "exit":
            break
        if choice not in table_dict:
            print("Invalid choice. Please try again.\n")
            continue

        table_name = table_dict[choice]
        try:
            with db.cursor() as cursor:
                cursor.execute(f"SELECT * FROM {table_name}")
                results = cursor.fetchall()
                print_results(cursor, results)
        except mysql.connector.Error as err:
            print(f"Error: {err}\n")
