#!/bin/bash

# Function to generate new filename
generate_filename() {
  local counter=$1
  local rename_pattern=$2
  local padding=$3
  
  if [ "$padding" -gt 0 ]; then
    padded_counter=$(printf "%0${padding}d" $counter)
  else
    padded_counter=$counter
  fi
  
  echo "${rename_pattern/\#/$padded_counter}"
}

# Get file pattern from user input
read -p "Enter file pattern (e.g., *.xls): " pattern
read -p "Enter renaming pattern (e.g., new_name_#.pdf where # will be replaced with numbers): " rename_pattern
read -p "Enter padding length for counter (e.g., 3 for 001, 002, etc. or 0 for no padding): " padding
read -p "Enter starting number (offset, e.g., 1, 10, 100): " offset

# Default offset to 1 if empty
offset=${offset:-1}

echo "Preview of renaming:"
counter=$offset
for i in $pattern ; do 
  # Exit with error if no files match the pattern
  if [ ! -f "$i" ]; then
    echo "Error: Files with pattern '$i' not found!"
    exit 1
  fi
  new_name=$(generate_filename $counter "$rename_pattern" $padding)
  echo "$i -> $new_name"
  ((counter++))
done

read -p "Proceed with renaming? (y/N): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "Renaming files..."
  counter=$offset
  for i in $pattern ; do 
    new_name=$(generate_filename $counter "$rename_pattern" $padding)
    mv "$i" "$new_name"
    echo "Renamed: $i -> $new_name"
    ((counter++))
  done
  echo "Renaming complete!"
else
  echo "Renaming cancelled."
fi