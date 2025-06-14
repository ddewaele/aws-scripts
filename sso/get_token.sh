#!/bin/bash

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "❌ This script must be sourced, not executed."
    echo "💡 Use: source get_token.sh"
    exit 1
fi

# Source the common functions
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

# Prompt for SSO session
read -p "Enter your SSO session name (as configured in ~/.aws/config): " SSO_SESSION

# Get SSO session
if ! get_sso_session "$SSO_SESSION"; then
    return 1
fi

# Export the token
export ACCESS_TOKEN

# Print the token
echo "🔑 Access Token:"
echo "$ACCESS_TOKEN"
echo -e "\n✅ ACCESS_TOKEN has been exported to your environment"

# Print token info
echo -e "\n📝 Token Information:"
echo "----------------------------------------"
jq -r '. | {startUrl, region, expiresAt}' ~/.aws/sso/cache/$(ls -t ~/.aws/sso/cache/ | head -1)

# Print usage example
echo -e "\n💡 Usage example:"
echo "aws sso list-accounts --access-token \$ACCESS_TOKEN" 