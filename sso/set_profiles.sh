#!/bin/bash

# Prompt for SSO session
read -p "Enter your SSO session name (as configured in ~/.aws/config): " SSO_SESSION

# Set region (optional: prompt if needed)
REGION="eu-central-1"

# Login
echo "🔐 Logging in with SSO session: $SSO_SESSION"
aws sso login --sso-session "$SSO_SESSION"

# Get access token from latest cached session
ACCESS_TOKEN=$(jq -r '.accessToken' ~/.aws/sso/cache/$(ls -t ~/.aws/sso/cache/ | head -1))

if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
  echo "❌ Failed to retrieve SSO access token. Make sure you're logged in."
  exit 1
fi

# List all accounts user has access to
ACCOUNT_JSON=$(aws sso list-accounts \
  --access-token "$ACCESS_TOKEN" \
  --output json)

ACCOUNT_IDS=$(echo "$ACCOUNT_JSON" | jq -r '.accountList[].accountId')

for ACCOUNT_ID in $ACCOUNT_IDS; do
  ACCOUNT_NAME=$(echo "$ACCOUNT_JSON" | jq -r ".accountList[] | select(.accountId==\"$ACCOUNT_ID\") | .accountName")

  ROLES=$(aws sso list-account-roles \
    --account-id "$ACCOUNT_ID" \
    --access-token "$ACCESS_TOKEN" \
    --query "roleList[*].roleName" \
    --output text)

  for ROLE in $ROLES; do
    SAFE_ACCOUNT=$(echo "$ACCOUNT_NAME" | tr ' /.' '_' | tr -cd '[:alnum:]_')
    SAFE_ROLE=$(echo "$ROLE" | tr ' /.' '_' | tr -cd '[:alnum:]_')
    PROFILE_NAME="${SAFE_ACCOUNT}_${SAFE_ROLE}"

    echo "🛠️ Creating profile [$PROFILE_NAME]..."

    aws configure set sso_session "$SSO_SESSION" --profile "$PROFILE_NAME"
    aws configure set sso_account_id "$ACCOUNT_ID" --profile "$PROFILE_NAME"
    aws configure set sso_role_name "$ROLE" --profile "$PROFILE_NAME"
    aws configure set region "$REGION" --profile "$PROFILE_NAME"
  done
done

echo "✅ All profiles generated using SSO session: $SSO_SESSION"
