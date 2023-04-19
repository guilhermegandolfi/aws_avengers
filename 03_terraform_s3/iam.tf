resource "aws_iam_user" "aws_iam_user_iron_man" {
  name = "${var.project}_iron_man"
  tags = var.tags
}

resource "aws_iam_access_key" "aws_iam_access_key_iron_man" {
  user = aws_iam_user.aws_iam_user_iron_man.name
}

data "aws_iam_policy_document" "aws_iam_policy_document_iron_man" {

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket_s3_avengers.id}",
      "arn:aws:s3:::${aws_s3_bucket.bucket_s3_avengers.id}/*",
    ]
  }

}


resource "aws_iam_policy" "policy" {
  name   = "iam_policy_permission_s3"
  tags   = var.tags
  policy = data.aws_iam_policy_document.aws_iam_policy_document_iron_man.json
}


resource "aws_iam_policy_attachment" "aws_iam_policy_attachment_iron_man" {
  name       = "iam_policy_permission_s3_att"
  users      = [aws_iam_user.aws_iam_user_iron_man.name]
  policy_arn = aws_iam_policy.policy.arn
}

