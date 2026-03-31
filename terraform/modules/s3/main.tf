resource "aws_s3_bucket" "this" {
  bucket = var.bucket
  acl    = "log-delivery-write"

  versioning { enabled = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "logs-expire"
    enabled = true
    expiration { days = 365 }
  }
}

 