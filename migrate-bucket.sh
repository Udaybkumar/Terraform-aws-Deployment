#!/bin/bash

# Script to migrate S3 bucket from us-east-1 to ap-southeast-1
# Make sure you have AWS CLI installed and configured

OLD_BUCKET="my-ews-buket1"
NEW_BUCKET="my-ews-buket1-apse1"  # New bucket name (must be globally unique)
OLD_REGION="us-east-1"
NEW_REGION="ap-southeast-1"

echo "Starting S3 bucket migration..."
echo "Old Bucket: $OLD_BUCKET (Region: $OLD_REGION)"
echo "New Bucket: $NEW_BUCKET (Region: $NEW_REGION)"

# Step 1: Create new bucket in ap-southeast-1
echo -e "\n[Step 1] Creating new bucket in $NEW_REGION..."
aws s3api create-bucket \
  --bucket "$NEW_BUCKET" \
  --region "$NEW_REGION" \
  --create-bucket-configuration LocationConstraint="$NEW_REGION"

# Step 2: Copy all objects from old bucket to new bucket
echo -e "\n[Step 2] Syncing objects from old bucket to new bucket..."
aws s3 sync "s3://$OLD_BUCKET" "s3://$NEW_BUCKET" --region "$OLD_REGION"

# Step 3: Enable versioning on new bucket (if needed for state files)
echo -e "\n[Step 3] Enabling versioning on new bucket..."
aws s3api put-bucket-versioning \
  --bucket "$NEW_BUCKET" \
  --versioning-configuration Status=Enabled

# Step 4: Enable encryption on new bucket
echo -e "\n[Step 4] Enabling encryption on new bucket..."
aws s3api put-bucket-encryption \
  --bucket "$NEW_BUCKET" \
  --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

echo -e "\n✓ Migration complete!"
echo "Next steps:"
echo "1. Update your backend.tf to use: bucket = \"$NEW_BUCKET\""
echo "2. Run: terraform init"
echo "3. Verify state is accessible"
echo "4. Delete old bucket: aws s3 rb s3://$OLD_BUCKET --region $OLD_REGION"
