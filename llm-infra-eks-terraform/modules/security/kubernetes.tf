resource "kubernetes_namespace" "ml" {
  metadata {
    name = "ml"
  }

  depends_on = [aws_iam_role.irsa_s3_reader_role]
}

resource "kubernetes_service_account" "s3_reader" {
  metadata {
    name      = "s3-reader"
    namespace = kubernetes_namespace.ml.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa_s3_reader_role.arn
    }
  }
}

resource "kubernetes_pod" "test_pod" {
  metadata {
    name      = "irsa-test"
    namespace = kubernetes_namespace.ml.metadata[0].name
  }

  spec {
    service_account_name = kubernetes_service_account.s3_reader.metadata[0].name

    container {
      name    = "awscli"
      image   = "amazon/aws-cli"
      command = ["sleep", "3600"]
    }
  }
}
