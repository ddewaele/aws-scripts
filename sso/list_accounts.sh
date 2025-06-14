#!/bin/bash

# Source the common functions
source "$(dirname "$0")/functions.sh"

# Prompt for SSO session
read -p "Enter your SSO session name (as configured in ~/.aws/config): " SSO_SESSION

# Get SSO session
if ! get_sso_session "$SSO_SESSION"; then
  exit 1
fi

# List all accounts user has access to
echo "📋 Listing all accounts you have access to:"
echo "----------------------------------------"

# Store accounts in a variable first
ACCOUNTS=$(aws sso list-accounts \
  --access-token "$ACCESS_TOKEN" \
  --query "accountList[*].[accountId,accountName]" \
  --output table)

# Then display them
echo "$ACCOUNTS"

# For each account, list available roles
echo -e "\n👥 Available roles per account:"
echo "----------------------------------------"

ACCOUNT_JSON=$(aws sso list-accounts \
  --access-token "$ACCESS_TOKEN" \
  --output json)

ACCOUNT_IDS=$(echo "$ACCOUNT_JSON" | jq -r '.accountList[].accountId')

for ACCOUNT_ID in $ACCOUNT_IDS; do
  ACCOUNT_NAME=$(echo "$ACCOUNT_JSON" | jq -r ".accountList[] | select(.accountId==\"$ACCOUNT_ID\") | .accountName")
  
  echo -e "\nAccount: $ACCOUNT_NAME ($ACCOUNT_ID)"
  echo "Roles:"
  
  # Store roles in a variable first
  ROLES=$(aws sso list-account-roles \
    --account-id "$ACCOUNT_ID" \
    --access-token "$ACCESS_TOKEN" \
    --query "roleList[*].roleName" \
    --output table)
  
  # Then display them
  echo "$ROLES"
done 