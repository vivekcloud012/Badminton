#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}
REGION=${2:-us-east-1}

echo "Deploying Badminton Analysis to $ENVIRONMENT in $REGION"

# Initialize and plan
terraform init -backend-config="env/$ENVIRONMENT.backend"

terraform plan \
  -var="environment=$ENVIRONMENT" \
  -var="aws_region=$REGION" \
  -out="tfplan.$ENVIRONMENT"

# Apply
terraform apply "tfplan.$ENVIRONMENT"

# Output endpoints
echo "Deployment complete!"
echo "API Gateway URL: $(terraform output -raw api_gateway_url)"
echo "S3 Bucket: $(terraform output -raw s3_bucket_name)"
