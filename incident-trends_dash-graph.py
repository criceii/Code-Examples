import dash
from dash import dcc, html, dash_table
import pandas as pd
from sqlalchemy import create_engine

# Create SQLAlchemy engine
engine = create_engine("mssql+pyodbc://YourDatabaseConnectionString")

# Define your query
query = """
SELECT column1, column2
FROM YourTableName
WHERE condition1 = 'YourCondition'
AND condition2 = 'AnotherCondition'
AND column2 > '2023-01-01'
"""

# Execute the query and load data into a DataFrame
data = pd.read_sql(query, engine)

# Create new column filled with 1s
data["Count"] = 1

# Ensure the 'column2' is in datetime format
data["column2"] = pd.to_datetime(data["column2"])

# Group data by month-year and count the occurrences for each month
data_grouped = (
    data.groupby(data["column2"].dt.strftime("%Y-%m"))["Count"].sum().reset_index()
)

# Calculate the monthly percentage change
data_grouped["Percentage Change"] = (data_grouped["Count"].pct_change() * 100).round(2)

# Handle the first entry separately
data_grouped.loc[0, "Percentage Change"] = 0.0

# Add percentage symbol to the formatted column
data_grouped["Percentage Change"] = data_grouped["Percentage Change"].astype(str) + "%"

# Create a Dash app
app = dash.Dash(__name__)

# Define the layout of the Dash app
app.layout = html.Div(
    [
        dcc.Graph(
            id="line-chart",
            figure={
                "data": [
                    {
                        "x": data_grouped["column2"],
                        "y": data_grouped["Count"],
                        "type": "line",
                        "name": "Monthly Count",
                    },
                ],
                "layout": {
                    "title": "Monthly Count of Records",
                    "xaxis": {"title": "Month"},
                    "yaxis": {"title": "Count"},
                    "height": 0.9 * 400,  # Decrease height by 10%
                    "width": 0.9 * 800,  # Decrease width by 10%
                },
            },
        ),
        dash_table.DataTable(
            id="table",
            columns=[
                {"name": "Month-Year", "id": "column2"},
                {"name": "Percentage Change", "id": "Percentage Change", "type": "text"},
            ],
            data=data_grouped.to_dict("records"),
            style_table={"width": "40%"},  # Decrease table width by 40%
        ),
    ]
)

if __name__ == "__main__":
    app.run_server(debug=True)
