resource "aws_iam_role" "irsa_s3_reader_role" {
  name = "${var.name_prefix}-irsa-s3-reader"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:ml:s3-reader"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "s3_readonly_policy" {
  name = "${var.name_prefix}-s3-readonly"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "irsa_attach" {
  role       = aws_iam_role.irsa_s3_reader_role.name
  policy_arn = aws_iam_policy.s3_readonly_policy.arn
}