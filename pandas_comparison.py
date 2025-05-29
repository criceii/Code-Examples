import pandas as pd

# Define the file paths
file_path_unupdatedsystems = r'path_to_your_first_excel_file.xlsx'
file_path_mastertracking = r'path_to_your_second_excel_file.xlsx'

# Load the Excel files into DataFrames
df_unupdatedsystems = pd.read_excel(file_path_unupdatedsystems)
df_mastertracking = pd.read_excel(file_path_mastertracking)

# Assuming the column name for identifiers is 'Identifier' in both DataFrames
# If the column name is different, replace 'Identifier' with the correct column name

# Find identifiers in df_unupdatedsystems that are not in df_mastertracking
missing_identifiers = df_unupdatedsystems[~df_unupdatedsystems['Identifier'].isin(df_mastertracking['Identifier'])]

# Write the missing identifiers to a new sheet in the original Excel file
with pd.ExcelWriter(file_path_unupdatedsystems, engine='openpyxl', mode='a') as writer:
    missing_identifiers.to_excel(writer, sheet_name='Missing Identifiers', index=False)

print("Missing identifiers have been added to a new sheet in the Excel file.")
