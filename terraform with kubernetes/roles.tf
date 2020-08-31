resource "kubernetes_role" "dev-role" {
  metadata {
    name = "dev-role"
    namespace = kubernetes_namespace.dev.metadata[0].name
  }

  rule {
    api_groups     = ["*"]
    resources      = ["*"]
    verbs          = ["*"]
  }
}

resource "kubernetes_role" "test-role" {
  metadata {
    name = "test-role"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  rule {
    api_groups     = ["*"]
    resources      = ["*"]
    verbs          = ["*"]
  }
}