#!/bin/bash

# AWS Account Cleanup Script
# WARNING: This script will DELETE all resources in your AWS account!
# Use with caution in test/non-production environments only

set -e

AWS_REGION="ap-southeast-1"

echo "⚠️  WARNING: This script will DELETE ALL AWS resources in region: $AWS_REGION"
echo "This action cannot be undone!"
read -p "Type 'DELETE_ALL' to confirm: " confirmation

if [ "$confirmation" != "DELETE_ALL" ]; then
    echo "Cancelled."
    exit 0
fi

echo "Starting AWS account cleanup in region: $AWS_REGION..."

# 1. Delete Auto Scaling Groups
echo "[1/15] Deleting Auto Scaling Groups..."
aws autoscaling describe-auto-scaling-groups --region $AWS_REGION --query 'AutoScalingGroups[].AutoScalingGroupName' --output text | xargs -I {} aws autoscaling delete-auto-scaling-group --auto-scaling-group-name {} --force-delete --region $AWS_REGION 2>/dev/null || true

# 2. Delete EC2 Instances
echo "[2/15] Terminating EC2 Instances..."
aws ec2 describe-instances --region $AWS_REGION --query 'Reservations[].Instances[].InstanceId' --output text | xargs -I {} aws ec2 terminate-instances --instance-ids {} --region $AWS_REGION 2>/dev/null || true

# Wait for instances to terminate
echo "Waiting for EC2 instances to terminate (this may take a few minutes)..."
aws ec2 wait instance-terminated --region $AWS_REGION 2>/dev/null || true

# 3. Delete Load Balancers (ALB/NLB)
echo "[3/15] Deleting Load Balancers..."
aws elbv2 describe-load-balancers --region $AWS_REGION --query 'LoadBalancers[].LoadBalancerArn' --output text | xargs -I {} aws elbv2 delete-load-balancer --load-balancer-arn {} --region $AWS_REGION 2>/dev/null || true

# 4. Delete Classic Load Balancers
echo "[4/15] Deleting Classic Load Balancers..."
aws elb describe-load-balancers --region $AWS_REGION --query 'LoadBalancerDescriptions[].LoadBalancerName' --output text | xargs -I {} aws elb delete-load-balancer --load-balancer-name {} --region $AWS_REGION 2>/dev/null || true

# 5. Delete Target Groups
echo "[5/15] Deleting Target Groups..."
aws elbv2 describe-target-groups --region $AWS_REGION --query 'TargetGroups[].TargetGroupArn' --output text | xargs -I {} aws elbv2 delete-target-group --target-group-arn {} --region $AWS_REGION 2>/dev/null || true

# 6. Delete RDS Instances
echo "[6/15] Deleting RDS Instances..."
aws rds describe-db-instances --region $AWS_REGION --query 'DBInstances[].DBInstanceIdentifier' --output text | xargs -I {} aws rds delete-db-instance --db-instance-identifier {} --skip-final-snapshot --region $AWS_REGION 2>/dev/null || true

# 7. Delete DynamoDB Tables
echo "[7/15] Deleting DynamoDB Tables..."
aws dynamodb list-tables --region $AWS_REGION --query 'TableNames[]' --output text | xargs -I {} aws dynamodb delete-table --table-name {} --region $AWS_REGION 2>/dev/null || true

# 8. Delete Lambda Functions
echo "[8/15] Deleting Lambda Functions..."
aws lambda list-functions --region $AWS_REGION --query 'Functions[].FunctionName' --output text | xargs -I {} aws lambda delete-function --function-name {} --region $AWS_REGION 2>/dev/null || true

# 9. Delete SNS Topics
echo "[9/15] Deleting SNS Topics..."
aws sns list-topics --region $AWS_REGION --query 'Topics[].TopicArn' --output text | xargs -I {} aws sns delete-topic --topic-arn {} --region $AWS_REGION 2>/dev/null || true

# 10. Delete SQS Queues
echo "[10/15] Deleting SQS Queues..."
aws sqs list-queues --region $AWS_REGION --query 'QueueUrls[]' --output text | xargs -I {} aws sqs delete-queue --queue-url {} --region $AWS_REGION 2>/dev/null || true

# 11. Delete S3 Buckets
echo "[11/15] Deleting S3 Buckets..."
aws s3api list-buckets --query 'Buckets[].Name' --output text | while read bucket; do
    # Empty bucket first
    aws s3 rm "s3://$bucket" --recursive --region $AWS_REGION 2>/dev/null || true
    # Delete bucket
    aws s3api delete-bucket --bucket "$bucket" --region $AWS_REGION 2>/dev/null || true
done

# 12. Delete CloudWatch Log Groups
echo "[12/15] Deleting CloudWatch Log Groups..."
aws logs describe-log-groups --region $AWS_REGION --query 'logGroups[].logGroupName' --output text | xargs -I {} aws logs delete-log-group --log-group-name {} --region $AWS_REGION 2>/dev/null || true

# 13. Delete IAM Roles (keep default roles)
echo "[13/15] Deleting IAM Roles..."
aws iam list-roles --query 'Roles[].RoleName' --output text | while read role; do
    # Skip AWS service roles
    if [[ ! "$role" =~ ^AWS ]]; then
        # Delete inline policies
        aws iam list-role-policies --role-name "$role" --query 'PolicyNames[]' --output text | xargs -I {} aws iam delete-role-policy --role-name "$role" --policy-name {} 2>/dev/null || true
        # Detach managed policies
        aws iam list-attached-role-policies --role-name "$role" --query 'AttachedPolicies[].PolicyArn' --output text | xargs -I {} aws iam detach-role-policy --role-name "$role" --policy-arn {} 2>/dev/null || true
        # Delete role
        aws iam delete-role --role-name "$role" 2>/dev/null || true
    fi
done

# 14. Delete Security Groups (keep default)
echo "[14/15] Deleting Security Groups..."
aws ec2 describe-security-groups --region $AWS_REGION --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text | xargs -I {} aws ec2 delete-security-group --group-id {} --region $AWS_REGION 2>/dev/null || true

# 15. Delete VPCs (keep default)
echo "[15/15] Deleting VPCs..."
aws ec2 describe-vpcs --region $AWS_REGION --query 'Vpcs[?IsDefault==`false`].VpcId' --output text | while read vpc; do
    # Delete subnets
    aws ec2 describe-subnets --region $AWS_REGION --filters "Name=vpc-id,Values=$vpc" --query 'Subnets[].SubnetId' --output text | xargs -I {} aws ec2 delete-subnet --subnet-id {} --region $AWS_REGION 2>/dev/null || true
    # Delete route tables
    aws ec2 describe-route-tables --region $AWS_REGION --filters "Name=vpc-id,Values=$vpc" --query 'RouteTables[].RouteTableId' --output text | xargs -I {} aws ec2 delete-route-table --route-table-id {} --region $AWS_REGION 2>/dev/null || true
    # Delete internet gateways
    aws ec2 describe-internet-gateways --region $AWS_REGION --filters "Name=attachment.vpc-id,Values=$vpc" --query 'InternetGateways[].InternetGatewayId' --output text | xargs -I {} aws ec2 detach-internet-gateway --internet-gateway-id {} --vpc-id "$vpc" --region $AWS_REGION 2>/dev/null || true
    aws ec2 describe-internet-gateways --region $AWS_REGION --filters "Name=attachment.vpc-id,Values=$vpc" --query 'InternetGateways[].InternetGatewayId' --output text | xargs -I {} aws ec2 delete-internet-gateway --internet-gateway-id {} --region $AWS_REGION 2>/dev/null || true
    # Delete VPC
    aws ec2 delete-vpc --vpc-id "$vpc" --region $AWS_REGION 2>/dev/null || true
done

echo ""
echo "✅ Cleanup complete!"
echo "Remaining resources:"
echo "  - Default VPC"
echo "  - Default Security Group"
echo "  - AWS Service Roles"
echo "  - Default subnets"
