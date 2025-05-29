import pandas as pd

# Load the spreadsheet
file_path = 'dummy_data_with_costs_v2.xlsx'
df = pd.read_excel(file_path)

# Display the first few rows of the dataframe
print("Data Overview:")
print(df.head())

# Replace NaN with 0 for cost columns
df['Hardware-Cost'] = df['Hardware-Cost'].fillna(0)
df['Shared-Service-Cost'] = df['Shared-Service-Cost'].fillna(0)
df['OS-Version-Cost'] = df['OS-Version-Cost'].fillna(0)
df['Function-Cost'] = df['Function-Cost'].fillna(0)

# Calculate total cost for each row
df['Total Cost'] = df['Hardware-Cost'] + df['Shared-Service-Cost'] + df['OS-Version-Cost'] + df['Function-Cost']

# Calculate total cost for each customer and business unit for the summary sheet
customer_business_unit_total_cost = df.groupby(['Primary-Customer', 'Business-Unit'])['Total Cost'].sum().reset_index()
customer_business_unit_total_cost.columns = ['Primary-Customer', 'Business-Unit', 'Customer Total Cost']

# Calculate total cost for each customer across all business units for the second sheet
customer_total_cost = df.groupby('Primary-Customer')['Total Cost'].sum().reset_index()
customer_total_cost.columns = ['Primary-Customer', 'Customer Total Cost']

# Format the Customer Total Cost columns to dollars
customer_business_unit_total_cost['Customer Total Cost'] = customer_business_unit_total_cost['Customer Total Cost'].apply(lambda x: f"${x:,.0f}")
customer_total_cost['Customer Total Cost'] = customer_total_cost['Customer Total Cost'].apply(lambda x: f"${x:,.0f}")

# Map the total cost for each customer and business unit back to the original DataFrame
df = df.merge(customer_business_unit_total_cost, on=['Primary-Customer', 'Business-Unit'], how='left', suffixes=('', '_y'))

# Format the Total Cost column to dollars
df['Total Cost'] = df['Total Cost'].apply(lambda x: f"${x:,.0f}")

# Select the desired columns for the output
output_df = df[['Primary-Customer', 'Business-Unit', 'Hardware', 'Hardware-Cost', 'Shared-Service', 'Shared-Service-Cost', 'OS-Version', 'OS-Version-Cost', 'Function', 'Function-Cost', 'Total Cost', 'Customer Total Cost']]

# Analyze the data
# Example 1: Count the number of each hardware type
hardware_counts = df['Hardware'].value_counts()
print("\nHardware Counts:")
print(hardware_counts)

# Example 2: Count the number of each OS version
os_version_counts = df['OS-Version'].value_counts()
print("\nOS Version Counts:")
print(os_version_counts)

# Example 3: Count the number of each function type
function_counts = df['Function'].value_counts()
print("\nFunction Counts:")
print(function_counts)

# Example 4: Group by Business Unit and count the number of entries per unit
business_unit_counts = df.groupby('Business-Unit').size()
print("\nBusiness Unit Counts:")
print(business_unit_counts)

# Example 5: Group by Primary Customer and count the number of entries per customer
customer_counts = df.groupby('Primary-Customer').size()
print("\nPrimary Customer Counts:")
print(customer_counts)

# Example 6: Cross-tabulation of Hardware and OS Version
hardware_os_crosstab = pd.crosstab(df['Hardware'], df['OS-Version'])
print("\nHardware and OS Version Crosstab:")
print(hardware_os_crosstab)

# Example 7: Cross-tabulation of Function and Business Unit
function_business_unit_crosstab = pd.crosstab(df['Function'], df['Business-Unit'])
print("\nFunction and Business Unit Crosstab:")
print(function_business_unit_crosstab)

# Example 8: Calculate total cost per hardware type
total_hardware_cost = df.groupby('Hardware')['Hardware-Cost'].sum()
print("\nTotal Hardware Cost:")
print(total_hardware_cost)

# Example 9: Calculate total cost per function type
total_function_cost = df.groupby('Function')['Function-Cost'].sum()
print("\nTotal Function Cost:")
print(total_function_cost)

# Example 10: Calculate total cost per OS version
total_os_version_cost = df.groupby('OS-Version')['OS-Version-Cost'].sum()
print("\nTotal OS Version Cost:")
print(total_os_version_cost)

# Example 11: Count the number of each shared service type
shared_service_counts = df['Shared-Service'].value_counts()
print("\nShared Service Counts:")
print(shared_service_counts)

# Example 12: Calculate total cost per shared service type
total_shared_service_cost = df.groupby('Shared-Service')['Shared-Service-Cost'].sum()
print("\nTotal Shared Service Cost:")
print(total_shared_service_cost)

# Save the analysis results to a new Excel file
output_file_path = 'C:/temp/analysis_results_with_total_cost_v2.xlsx'
with pd.ExcelWriter(output_file_path) as writer:
    output_df.to_excel(writer, sheet_name='Summary', index=False)
    customer_total_cost.to_excel(writer, sheet_name='Customer Total Cost', index=False)
    hardware_counts.to_excel(writer, sheet_name='Hardware Counts')
    os_version_counts.to_excel(writer, sheet_name='OS Version Counts')
    function_counts.to_excel(writer, sheet_name='Function Counts')
    business_unit_counts.to_excel(writer, sheet_name='Business Unit Counts')
    customer_counts.to_excel(writer, sheet_name='Customer Counts')
    hardware_os_crosstab.to_excel(writer, sheet_name='Hardware-OS Crosstab')
    function_business_unit_crosstab.to_excel(writer, sheet_name='Function-Business Unit Crosstab')
    total_hardware_cost.to_excel(writer, sheet_name='Total Hardware Cost')
    total_function_cost.to_excel(writer, sheet_name='Total Function Cost')
    total_os_version_cost.to_excel(writer, sheet_name='Total OS Version Cost')
    shared_service_counts.to_excel(writer, sheet_name='Shared Service Counts')
    total_shared_service_cost.to_excel(writer, sheet_name='Total Shared Service Cost')

print(f"\nAnalysis results saved to {output_file_path}")

print("\nAnalysis complete.")
