import yaml

# Open the YAML file and load the data into a Python object
with open("config2.yml", "r") as f:
    data = yaml.safe_load(f)

# Extract the database host and port information
dbHost = data["database"]["host"]
dbPort = data["database"]["port"]

# Extract the first table name and column names
tableName = data["database"]["tables"][0]["name"]
columnNames = [c["name"] for c in data["database"]["tables"][0]["columns"]]

# Extract the customer names from the "customers" table
#customers = data["database"]["tables"][0]["data"]
#customerNames = [row["name"] for row in customers]


# Print the extracted information
print(f"Database host: {dbHost}")
print(f"Database port: {dbPort}")
print(f"Table name: {tableName}")
print(f"Column names: {columnNames}")

#print(f"Customer names: {customer_names}")
