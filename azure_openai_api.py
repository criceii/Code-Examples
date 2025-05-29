import os
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    api_version="2024-02-15-preview",
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
)

# Desired deployment name
deployment_name = "gpt-4o"

# Prepare the conversation messages
messages = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Write a tagline for a spaceship."},
]

# Send a chat completion call to generate an answer
print("Sending a test chat completion job")
response = client.chat.completions.create(
    model=deployment_name, messages=messages, max_tokens=100
)

# Print the content of the first message from the assistant
print(response.choices[0].message.content)
