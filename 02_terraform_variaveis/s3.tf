resource "aws_s3_bucket" "bucket_s3_avengers" {
  bucket = "pags-${var.project}-${lookup(var.enviorment, var.env)}"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "bucket_s3_avengers_versioning" {
  bucket = aws_s3_bucket.bucket_s3_avengers.id
  versioning_configuration {
    status = "Enabled"
  }
}
