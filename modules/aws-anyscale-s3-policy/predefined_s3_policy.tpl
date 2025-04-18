{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${anyscale_bucket_name}",
        "arn:aws:s3:::${anyscale_bucket_name}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    },
    {
      "Sid": "AllowAnyscaleResources",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::${anyscale_bucket_name}",
        "arn:aws:s3:::${anyscale_bucket_name}/*"
      ],
      "Principal": {
        "AWS": [
          "${anyscale_controlplane_role}",
          "${anyscale_dataplane_role}"
        ]
      }
    }
  ]
}
