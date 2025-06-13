# AWS SSO Profile Configuration Script

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
  - Converting spaces, forward slashes, and dots to underscores
  - Keeping only letters, numbers, and underscores
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