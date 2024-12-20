#!/bin/bash

# Check if .env file exists
if [ ! -f .env ]; then
  echo ".env file not found!"
  exit 1
fi

# Create or overwrite the .env.example file
> .env.example

# Read the .env file line by line, including the last line even without newline
while IFS= read -r line || [ -n "$line" ]
do
  # Skip empty lines and comments
  if [[ -z "$line" || "$line" == \#* ]]; then
    echo "$line" >> .env.example
  else
    # Extract the key by finding first '=' and keep the key only
    key=$(echo "$line" | sed 's/=.*//')
    echo "$key=" >> .env.example
  fi
done < .env

echo ".env.example file created successfully."