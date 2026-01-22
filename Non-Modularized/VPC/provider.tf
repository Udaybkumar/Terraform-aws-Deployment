# AWS Provider Configuration
# AWS credentials are automatically picked up from environment variables:
# - AWS_ACCESS_KEY_ID (from GitHub Codespaces Secrets)
# - AWS_SECRET_ACCESS_KEY (from GitHub Codespaces Secrets)

provider "aws" {
  region = "ap-southeast-1"
}