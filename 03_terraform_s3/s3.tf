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
    id = "delete_raw_data"

    expiration {
      days = 2
    }


    noncurrent_version_expiration {
      noncurrent_days = 2
    }

    filter {
      prefix = "raw_data/"
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

## bucket replication 
resource "aws_s3_bucket" "bucket_s3_avengers_replication" {
  bucket = "pags-${var.project}-${lookup(var.enviorment, var.env)}-replication"
  tags   = var.tags
}


resource "aws_s3_bucket_versioning" "bucket_s3_avengers_replication_versioning" {

  bucket = aws_s3_bucket.bucket_s3_avengers_replication.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "bucket_replication_assume_s3" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = "pags-${var.project}-bucket-replication-role"
  assume_role_policy = data.aws_iam_policy_document.bucket_replication_assume_s3.json
}

data "aws_iam_policy_document" "aws_s3_bucket_avengers" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.bucket_s3_avengers.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.bucket_s3_avengers.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.bucket_s3_avengers_replication.arn}/*"]
  }
}

resource "aws_iam_policy" "aws_s3_bucket_avengers_policy" {
  name   = "pags-${var.project}-bucket-replication-policy"
  policy = data.aws_iam_policy_document.aws_s3_bucket_avengers.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.aws_s3_bucket_avengers_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "bucket_s3_avengers_raw_data" {
  provider   = aws.east
  depends_on = [aws_s3_bucket_versioning.bucket_s3_avengers_versioning, aws_s3_bucket_versioning.bucket_s3_avengers_replication_versioning]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.bucket_s3_avengers.id

  rule {
    id = "raw_data"

    filter {
      prefix = "raw_data/"
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.bucket_s3_avengers_replication.arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }
}