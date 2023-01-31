output "s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = try(aws_s3_bucket.anyscale_managed_s3_bucket[0].arn, "")
}

output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = try(aws_s3_bucket.anyscale_managed_s3_bucket[0].id, "")
}

output "s3_bucket_region" {
  description = "The AWS region this bucket resides in."
  value       = try(aws_s3_bucket.anyscale_managed_s3_bucket[0].region, "")
}
