import json
import boto3
import os
from datetime import datetime

s3 = boto3.client('s3')
bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-east-1')

def lambda_handler(event, context):
    print("=== ANALYSIS LAMBDA INVOCATION ===")
    print(f"Full event: {json.dumps(event, indent=2)}")
    
    try:
        # Handle API Gateway proxy integration
        body = {}
        if 'body' in event and event['body']:
            if isinstance(event['body'], str):
                try:
                    body = json.loads(event['body'])
                except json.JSONDecodeError:
                    body = {}
            else:
                body = event['body']
        
        print(f"Parsed body: {json.dumps(body, indent=2)}")
        
        # Get video information
        bucket_name = body.get('bucket', os.environ.get('BUCKET_NAME', 'badminton-analysis-dev-videos'))
        video_key = body.get('video_key', '')
        analysis_type = body.get('analysis_type', 'shot_accuracy')
        
        print(f"Bucket: {bucket_name}, Video Key: {video_key}, Analysis Type: {analysis_type}")
        
        if not video_key:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'success': False,
                    'error': 'video_key is required in request body',
                    'received_data': body
                })
            }
        
        # Process the video
        result = analyze_badminton_video(bucket_name, video_key, analysis_type)
        
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'success': True,
                'analysis_id': f"analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
                'results': result,
                'video_key': video_key,
                'analysis_type': analysis_type
            })
        }
        
        print(f"Success response: {json.dumps(response, indent=2)}")
        return response
        
    except Exception as e:
        print(f"Error in analysis lambda: {str(e)}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'success': False,
                'error': str(e),
                'type': type(e).__name__
            })
        }

def analyze_badminton_video(bucket_name, video_key, analysis_type):
    video_url = f"s3://{bucket_name}/{video_key}"
    print(f"Analyzing video: {video_url}")
    
    # Mock analysis data for now
    if analysis_type == 'shot_accuracy':
        return {
            'shot_breakdown': {
                'clears': '15 attempts, 12 successful (80%)',
                'drops': '10 attempts, 8 successful (80%)', 
                'smashes': '8 attempts, 6 successful (75%)',
                'net_shots': '12 attempts, 10 successful (83%)'
            },
            'accuracy_percentages': {
                'overall': '80%',
                'clears': '80%',
                'drops': '80%',
                'smashes': '75%',
                'net_shots': '83%'
            },
            'strengths': [
                'Excellent clear shots with good depth',
                'Accurate net play and drop shots',
                'Good shot selection in rallies'
            ],
            'areas_for_improvement': [
                'Increase smash power and accuracy',
                'Improve footwork for better court coverage',
                'Work on backhand consistency'
            ],
            'overall_score': '8/10',
            'recommendations': [
                'Practice power smashes 3 times per week',
                'Focus on footwork drills for 15 minutes daily',
                'Work on backhand technique with a coach'
            ]
        }
    elif analysis_type == 'player_form':
        return {
            'footwork': 'Good court coverage but could improve recovery speed',
            'racket_technique': 'Solid grip and swing technique with good follow-through',
            'body_positioning': 'Excellent anticipation and positioning for most shots',
            'stamina': 'Good endurance throughout the match',
            'recommendations': [
                'Practice shadow footwork drills',
                'Focus on recovery after each shot',
                'Work on split-step timing'
            ],
            'score_breakdown': {
                'footwork': '7/10',
                'technique': '8/10',
                'positioning': '9/10',
                'stamina': '8/10'
            }
        }
    else:
        return {
            'overall_assessment': 'Strong technical foundation with good tactical awareness',
            'technical_skills': 'Excellent basic techniques across all shot types',
            'tactical_awareness': 'Good understanding of game situations',
            'physical_conditioning': 'Good endurance and movement',
            'recommendations': [
                'Develop more shot variety',
                'Improve tactical decision-making under pressure',
                'Work on mental toughness in crucial points'
            ],
            'overall_rating': '8.5/10'
        }
