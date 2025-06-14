# AWS SSO Scripts

This directory contains scripts for managing AWS SSO (Single Sign-On) configurations and profiles.

## Available Scripts

### set_profiles.sh
Configures AWS CLI profiles from your SSO permissions. See detailed documentation below.

### list_accounts.sh
Lists AWS accounts and roles you have access to via IAM Identity Center (formerly AWS SSO).

Prerequisites:
- fzf (Fuzzy Finder) installed
  - macOS: `brew install fzf`
  - Ubuntu: `apt install fzf`

Usage:
```bash
./list_accounts.sh
```

The script will:
1. Prompt for your SSO session name
2. Log you into AWS SSO if needed
3. Show an interactive interface where:
   - Left side: List of accounts (use ↑/↓ to navigate, type to filter)
   - Right side: Available roles for the currently selected account
   - Roles update automatically as you move through the account list
4. Press Enter to select an account

Example:
```
📋 Select an account (use ↑/↓ to navigate, type to filter):
----------------------------------------
> Production (123456789)    |  👥 Available roles:
  Development (987654321)   |  ------------------------
  Staging (456789123)      |  |  RoleName  |
                           |  |------------|
                           |  |  Admin     |
                           |  |  Developer |
```

### get_token.sh
Prints the current SSO access token and its information.

Usage:
```bash
# IMPORTANT: The script must be SOURCED, not executed
source get_token.sh
# or
. get_token.sh
```

The script will:
1. Prompt for your SSO session name
2. Log you into AWS SSO if needed
3. Display the current access token
4. Export the token as ACCESS_TOKEN environment variable
5. Show token information (start URL, region, expiry)

This is useful for:
- Debugging SSO issues
- Using the token in other scripts
- Checking token expiry
- Verifying SSO configuration
- Running AWS CLI commands that need the token

Example usage:
```bash
# Source the script to get the token
source get_token.sh

# The token is now available in your current shell
echo $ACCESS_TOKEN

# Use it in AWS CLI commands
aws sso list-accounts --access-token $ACCESS_TOKEN
```

Note: If you run the script with `./get_token.sh`, the ACCESS_TOKEN variable will not be available in your shell. You must use `source get_token.sh` or `. get_token.sh`.

## set_profiles.sh

This script automates the creation of AWS CLI profiles for AWS SSO (Single Sign-On) accounts and roles. It helps you set up multiple AWS profiles based on your SSO permissions, making it easier to switch between different AWS accounts and roles.

## Prerequisites

- AWS CLI v2 installed
- AWS SSO configured in your `~/.aws/config`
- `jq` command-line tool installed
- An active AWS SSO session

## Features

- Automatically discovers all AWS accounts you have access to
- Creates profiles for all available roles in each account
- Sanitizes account and role names for profile creation
- Sets up profiles with the correct SSO session, account ID, and role name
- Configures a default region (eu-central-1)

## Usage

1. Make sure you have AWS SSO configured in your `~/.aws/config` file
2. Run the script:
   ```bash
   ./set_profiles.sh
   ```
3. When prompted, enter your SSO session name as configured in your AWS config
4. The script will:
   - Log you into AWS SSO
   - Discover all accounts and roles you have access to
   - Create profiles for each account-role combination
   - Configure the profiles with the correct settings

## Profile Naming Convention

Profiles are created using the following format:
```
{AccountName}_{RoleName}
```

Where:
- AccountName is sanitized by:
- Converting all non-alphanumeric characters to underscores
- RoleName is sanitized using the same rules

For example:
- Account: "Development Account/Prod" → "Development_Account_Prod"
- Account: "dev.team.account" → "dev_team_account"
- Role: "Admin Access" → "Admin_Access"
- Final profile name: "Development_Account_Prod_Admin_Access" or "dev_team_account_Admin_Access"

This sanitization ensures consistent and valid profile names that work reliably with AWS CLI and shell scripts.

## Example

If you have access to:
- Account: "Development Account"
- Role: "AdministratorAccess"

The script will create a profile named: `DevelopmentAccount_AdministratorAccess`

## Configuration

The script uses the following default settings:
- Region: eu-central-1

You can modify these settings by editing the script.

## Troubleshooting

If you encounter issues:
1. Ensure you're logged into AWS SSO
2. Verify your SSO session name is correct
3. Check that you have the necessary permissions
4. Ensure `jq` is installed and available in your PATH

## License

This script is provided as-is under the MIT License. 