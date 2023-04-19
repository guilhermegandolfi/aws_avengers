resource "aws_sqs_queue" "queue" {
  name = "s3-event-notification-queue-avengers-raw-data"
  tags = var.tags
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_avengers" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.aws_iam_policy_document_sqs_avengers.json
}


data "aws_iam_policy_document" "aws_iam_policy_document_sqs_avengers" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    sid       = "1"
    actions   = ["sqs:SendMessage", ]
    resources = ["${aws_sqs_queue.queue.arn}", ]

    condition {
      test     = "ArnEquals"
      values   = ["${aws_s3_bucket.bucket_s3_avengers.arn}"]
      variable = "aws:SourceArn"
    }

  }

}



