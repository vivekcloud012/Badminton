import json
import boto3
import uuid
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    print("=== UPLOAD LAMBDA INVOCATION ===")
    print(f"Full event: {json.dumps(event, indent=2)}")
    
    try:
        # Debug: Print all event keys
        print(f"Event keys: {list(event.keys())}")
        
        # Handle API Gateway proxy integration
        if 'queryStringParameters' in event:
            query_params = event.get('queryStringParameters', {}) or {}
            print(f"Query params: {query_params}")
            filename = query_params.get('filename', '')
        else:
            # Handle direct invocation
            filename = event.get('filename', '')
        
        print(f"Extracted filename: '{filename}'")
        
        if not filename:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'filename is required in query parameters',
                    'debug_info': {
                        'received_query_params': event.get('queryStringParameters', {}),
                        'event_structure': list(event.keys())
                    }
                })
            }
        
        # Generate unique key
        file_extension = filename.split('.')[-1] if '.' in filename else 'mp4'
        unique_key = f"videos/{uuid.uuid4()}.{file_extension}"
        
        bucket_name = os.environ.get('BUCKET_NAME', 'badminton-analysis-dev-videos')
        print(f"Using bucket: {bucket_name}")
        
        # Generate pre-signed URL
        presigned_url = s3.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': bucket_name,
                'Key': unique_key,
                'ContentType': 'video/mp4'
            },
            ExpiresIn=3600
        )
        
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'upload_url': presigned_url,
                'video_key': unique_key,
                'expires_in': 3600,
                'bucket': bucket_name
            })
        }
        
        print(f"Success response: {json.dumps(response, indent=2)}")
        return response
        
    except Exception as e:
        print(f"Error generating upload URL: {str(e)}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e),
                'type': type(e).__name__
            })
        }
