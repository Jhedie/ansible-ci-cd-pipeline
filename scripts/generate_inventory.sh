#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Generate inventory from Terraform output
cd "$PROJECT_ROOT/terraform"
terraform output -raw ansible_inventory >"$PROJECT_ROOT/inventory.ini"

echo "Inventory file generated at $PROJECT_ROOT/inventory.ini"
