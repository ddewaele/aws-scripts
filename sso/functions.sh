#!/bin/bash

# Function to handle cleanup on script interruption
function cleanup() {
  echo -e "\n\n⚠️  Script interrupted. Cleaning up..."
  exit 1
}

# Set up trap for SIGINT (Ctrl+C)
trap cleanup SIGINT

# Function to handle SSO session management
# Returns the access token in the ACCESS_TOKEN variable
function get_sso_session() {
  local SSO_SESSION="$1"
  
  # Try to get access token from latest cached session
  ACCESS_TOKEN=$(jq -r '.accessToken' ~/.aws/sso/cache/$(ls -t ~/.aws/sso/cache/ | head -1))

  # Test if the token is valid by checking caller identity
  if ! aws sts get-caller-identity &>/dev/null; then
    echo "🔐 Session expired or invalid. Logging in..."
    aws sso login --sso-session "$SSO_SESSION"
    ACCESS_TOKEN=$(jq -r '.accessToken' ~/.aws/sso/cache/$(ls -t ~/.aws/sso/cache/ | head -1))
  else
    echo "✅ Using existing SSO session"
  fi

  if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
    echo "❌ Failed to retrieve SSO access token. Make sure you're logged in."
    return 1
  fi

  return 0
} 