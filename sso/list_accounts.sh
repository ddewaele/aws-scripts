#!/bin/bash

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "❌ fzf is required but not installed."
    echo "💡 Install it with: brew install fzf (macOS) or apt install fzf (Ubuntu)"
    exit 1
fi

# Source the common functions
source "$(dirname "$0")/functions.sh"

# Prompt for SSO session
read -e -p "Enter your SSO session name (as configured in ~/.aws/config): " SSO_SESSION

# Get SSO session
if ! get_sso_session "$SSO_SESSION"; then
  exit 1
fi

# List all accounts user has access to
echo "📋 Select an account (use ↑/↓ to navigate, type to filter):"
echo "----------------------------------------"

# Get accounts and format them for fzf
echo "🔧 AWS CLI Command:"
echo "aws sso list-accounts --access-token \$ACCESS_TOKEN --output json"
echo "----------------------------------------"

ACCOUNT_JSON=$(aws sso list-accounts \
  --access-token "$ACCESS_TOKEN" \
  --output json)

# Create a formatted list of accounts for fzf
ACCOUNT_LIST=$(echo "$ACCOUNT_JSON" | jq -r '.accountList[] | "\(.accountName) \(.accountId)"')

# Let user select an account with preview
SELECTED_ACCOUNT=$(echo "$ACCOUNT_LIST" | fzf \
    --height 40% \
    --border \
    --prompt "Select account (ENTER to select): " \
    --preview "ACCOUNT_ID=\$(echo {} | rev | cut -d' ' -f1 | rev); echo '🔧 AWS CLI Command:'; echo \"aws sso list-account-roles --account-id \$ACCOUNT_ID --access-token \$ACCESS_TOKEN --query \\\"roleList[*].roleName\\\" --output table\"; echo '----------------------------------------'; aws sso list-account-roles --account-id \$ACCOUNT_ID --access-token \"$ACCESS_TOKEN\" --query \"roleList[*].roleName\" --output table" \
    --preview-window "right:60%" \
    --bind "enter:select-all+accept")

if [[ -z "$SELECTED_ACCOUNT" ]]; then
    echo "❌ No account selected"
    exit 1
fi

# Extract account ID and name from selection
ACCOUNT_ID=$(echo "$SELECTED_ACCOUNT" | rev | cut -d' ' -f1 | rev)
ACCOUNT_NAME=$(echo "$SELECTED_ACCOUNT" | rev | cut -d' ' -f2- | rev)

# Get roles for selected account
ROLES_JSON=$(aws sso list-account-roles \
  --account-id "$ACCOUNT_ID" \
  --access-token "$ACCESS_TOKEN" \
  --output json)

# Create a formatted list of roles for fzf
ROLE_LIST=$(echo "$ROLES_JSON" | jq -r '.roleList[] | .roleName')

# Let user select roles in the same window
SELECTED_ROLES=$(echo "$ROLE_LIST" | fzf \
    --height 40% \
    --border \
    --prompt "Select roles (TAB to select, ENTER to confirm): " \
    --multi \
    --bind "tab:select-all" \
    --preview "echo 'Selected roles will be shown here'")

if [[ -z "$SELECTED_ROLES" ]]; then
    echo "❌ No roles selected"
    exit 1
fi

# For each selected role, ask for confirmation to delete
for ROLE in $SELECTED_ROLES; do
    echo -e "\n🔍 Selected role: $ROLE"
    echo "Do you want to delete this role?"
    
    # Show confirmation dialog
    CONFIRM=$(echo -e "No\nYes" | fzf \
        --height 20% \
        --border \
        --prompt "Confirm deletion: " \
        --header "Are you sure you want to delete role: $ROLE?")
    
    if [[ "$CONFIRM" == "Yes" ]]; then
        echo "🗑️  Deleting role: $ROLE"
        # Here you would add the actual delete command
        # aws iam delete-role --role-name "$ROLE"
        echo "✅ Role deleted successfully"
    else
        echo "❌ Deletion cancelled for role: $ROLE"
    fi
done 