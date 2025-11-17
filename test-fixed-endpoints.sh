#!/bin/bash

# Get the API URL from Terraform output
API_URL=$(terraform output -raw api_gateway_url)
echo "API Base URL: $API_URL"
echo ""

echo "=== Testing Upload URL Endpoint ==="
UPLOAD_URL="${API_URL}upload-url?filename=test-video.mp4"
echo "Testing: $UPLOAD_URL"
curl -v -X GET "$UPLOAD_URL"
echo -e "\n"

echo "=== Testing Analyze Endpoint ==="
ANALYZE_URL="${API_URL}analyze"
echo "Testing: $ANALYZE_URL"
curl -v -X POST "$ANALYZE_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "video_key": "videos/test-video.mp4",
    "analysis_type": "shot_accuracy",
    "bucket": "badminton-analysis-dev-videos"
  }'
echo -e "\n"

echo "=== Testing OPTIONS (CORS) ==="
curl -v -X OPTIONS "$UPLOAD_URL"
echo -e "\n"
