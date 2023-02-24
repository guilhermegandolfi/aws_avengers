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

## bucket log
resource "aws_s3_bucket" "bucket_s3_avengers_log" {
  bucket = "pags-${var.project}-${lookup(var.enviorment, var.env)}-log"
  tags   = var.tags
}


## policy
resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_avengers_log" {
  bucket = aws_s3_bucket.bucket_s3_avengers_log.id
  policy = data.aws_iam_policy_document.aws_iam_policy_document_avengers_s3_log.json
}

data "aws_iam_policy_document" "aws_iam_policy_document_avengers_s3_log" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.bucket_s3_avengers_log.arn,
      "${aws_s3_bucket.bucket_s3_avengers_log.arn}/*",
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [aws_s3_bucket.bucket_s3_avengers.arn,    
      ]
    }


  }
}

resource "aws_s3_bucket_logging" "aws_s3_bucket_logging_avengers" {
  bucket = aws_s3_bucket.bucket_s3_avengers.id

  target_bucket = aws_s3_bucket.bucket_s3_avengers_log.id
  target_prefix = "log/"
}

## lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "aws_s3_bucket_lifecycle_configuration_avengers" {
  bucket = aws_s3_bucket.bucket_s3_avengers.id

  rule {
    id = "delete_raw_aata"

    expiration {
      days = 10
    }

     noncurrent_version_expiration {
      noncurrent_days = 30
    }

    filter {
      and {
        prefix = "raw_data/"
        tags = var.tags
    }

   

  }

  status = "Enabled"

}

}


## notification 
resource "aws_s3_bucket_notification" "aws_s3_bucket_notification_avengers" {
  bucket = aws_s3_bucket.bucket_s3_avengers.id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "raw_data/"
  }
}
