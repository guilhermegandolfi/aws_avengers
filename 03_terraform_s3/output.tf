output "output_aws_iam_access_key_iron_man" {
  value = aws_iam_access_key.aws_iam_access_key_iron_man.id
}

# how to print the sensitive value
# terraform output output_aws_iam_secret_key_iron_man
output "output_aws_iam_secret_key_iron_man" {
  value     = aws_iam_access_key.aws_iam_access_key_iron_man.secret
  sensitive = true
}