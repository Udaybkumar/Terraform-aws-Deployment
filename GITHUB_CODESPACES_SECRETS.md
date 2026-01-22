# GitHub Codespaces Secrets Setup Guide

## Overview
This project uses GitHub Codespaces Secrets to securely store AWS credentials. Credentials are **NOT** stored in code or terraform.tfvars files.

## How to Add Secrets to GitHub Codespaces

### Step 1: Navigate to Codespaces Settings
1. Go to your GitHub repository
2. Click **Settings** → **Codespaces** → **Secrets and variables** → **Codespaces**
3. Click **New Codespace secret**

### Step 2: Add AWS Credentials
Add these two secrets:

| Secret Name | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key |

### Step 3: Verify in Codespace
When you launch a Codespace, these secrets are automatically available as environment variables:

```bash
# These will be available in your Codespace environment
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

## How Terraform Uses These Secrets

### Provider Configuration
The `provider.tf` files now use environment variables automatically:

```terraform
provider "aws" {
  region = "ap-southeast-1"
  # AWS credentials are automatically picked up from:
  # - AWS_ACCESS_KEY_ID environment variable
  # - AWS_SECRET_ACCESS_KEY environment variable
}
```

### Running Terraform
In your Codespace, simply run:

```bash
cd Non-Modularized/VPC
terraform init
terraform plan
terraform apply
```

No need to pass credentials or create `.tfvars` files!

## How GitHub Actions Uses These Secrets

The GitHub Actions workflow is configured to use GitHub Secrets:

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

When you push code to GitHub, the workflow automatically gets these secrets.

## Security Best Practices

✅ **What we're doing right:**
- Secrets stored in GitHub Codespaces (encrypted at rest)
- No hardcoded credentials in code
- `.tfvars` files are git-ignored
- Credentials marked as `sensitive` in Terraform
- Different secrets for different environments

## Important Notes

⚠️ **Do NOT:**
- Commit any files with actual credentials
- Print secrets in logs
- Share secrets outside your organization
- Use the same credentials across multiple projects

✅ **DO:**
- Rotate credentials regularly
- Use IAM roles when possible (recommended for production)
- Review GitHub Actions logs for any credential exposure
- Keep Codespaces secrets updated

## For CI/CD (GitHub Actions)

The workflow file already has GitHub Secrets configured. To add more secrets for Actions:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the same secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

## Troubleshooting

### Terraform says "NoCredentialProviders"
- Make sure secrets are added to **Codespaces** secrets (not just Actions)
- Restart your Codespace after adding secrets
- Run `echo $AWS_ACCESS_KEY_ID` to verify the variable is set

### GitHub Actions workflow fails with auth error
- Add secrets to **Actions** secrets (not Codespaces)
- Verify secret names match exactly: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

## References
- [GitHub Codespaces Secrets Documentation](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-secrets-for-your-codespaces)
- [GitHub Actions Secrets Documentation](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [Terraform AWS Provider Authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)
