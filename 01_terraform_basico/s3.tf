resource "aws_s3_bucket" "bucket_s3_avengers" {
  bucket = "pags-avengers"
  tags = {
    Name        = "pags_avengers"
    Environment = "Dev"
    
  }
}