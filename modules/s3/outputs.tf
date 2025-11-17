# modules/s3/outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.video_storage.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.video_storage.arn
}
