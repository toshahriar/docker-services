#!/bin/bash

# Define the list of services with their respective directories
SERVICES=(
  "."
  "minio"
  "mongo"
  "mysql"
  "postgres"
  "rabbitmq"
  "redis"
  "sftp"
)

# Flag to force replace existing files
FORCE_REPLACE=false

# Function to display help
show_help() {
  echo "Usage: setup.sh [-f | --force] [-h | --help]"
  echo ""
  echo "This script copies .env.example files to .env and any other .example files to their respective names without .example suffix."
  echo ""
  echo "Options:"
  echo "  -f, --force    Force replace existing files"
  echo "  -h, --help     Show this help message and exit"
  echo ""
  echo "Services:"
  for service in "${SERVICES[@]}"; do
    echo "  - ${service}"
  done
  echo ""
  exit 0
}

# Parse command-line arguments for force replace and help
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -f|--force)
      FORCE_REPLACE=true
      shift
      ;;
    -h|--help)
      show_help
      shift
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

# Function to copy example files
copy_example_files() {
  local service_dir="$1"

  # Check if the directory exists
  if [ ! -d "$service_dir" ]; then
    echo "Directory $service_dir does not exist. Skipping."
    return
  fi

  # Find all .example files in the directory
  local example_files=$(find "$service_dir" -maxdepth 1 -name "*.example")

  for example_file in $example_files; do
    # Determine the target file by removing the .example suffix
    local target_file="${example_file%.example}"

    # Check if the target file already exists
    if [ -f "$target_file" ]; then
      if [ "$FORCE_REPLACE" = true ]; then
        echo "Replacing existing $target_file with $example_file."
        cp "$example_file" "$target_file"
      else
        echo "Skipping. $target_file already exists. Use -f or --force to force replace."
      fi
    else
      echo "Copying $example_file to $target_file."
      cp "$example_file" "$target_file"
    fi
  done
}

# Iterate over each service directory and copy the example files
for service in "${SERVICES[@]}"; do
  copy_example_files "$service"
done

echo "Setup complete."
