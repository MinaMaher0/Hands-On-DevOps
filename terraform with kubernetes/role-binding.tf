resource "kubernetes_role_binding" "dev-bind" {
  metadata {
    name      = "dev-bind"
    namespace = kubernetes_namespace.dev.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.dev-role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins-account.metadata[0].name
    namespace = kubernetes_namespace.build.metadata[0].name
  }
}

resource "kubernetes_role_binding" "test-bind" {
  metadata {
    name      = "test-bind"
    namespace = kubernetes_namespace.test.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.test-role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins-account.metadata[0].name
    namespace = kubernetes_namespace.build.metadata[0].name
  }
}