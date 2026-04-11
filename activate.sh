#!/bin/bash

# Activate virtual environment and cd to dbt project
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/venv/bin/activate"
export DBT_PROFILES_DIR="$SCRIPT_DIR/.dbt"
cd "$SCRIPT_DIR/my_online_store"

echo "✓ venv activated"
echo "✓ DBT_PROFILES_DIR set to: $DBT_PROFILES_DIR"
echo "✓ Now in: $(pwd)"