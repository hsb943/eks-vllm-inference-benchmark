output "irsa_role_arn" {
  value = aws_iam_role.irsa_s3_reader_role.arn
}
