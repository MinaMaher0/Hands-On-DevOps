resource "kubernetes_deployment" "mysql-test" {
  metadata {
    name = "mysql-test"
    labels = {
      app = "mysql-test"
    }
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql-test"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql-test"
        }
      }

      spec {
        container {
          image = "mysql:8.0.21"
          name  = "mysql-test"

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value =  "root"            
          }

          env {
            name = "MYSQL_DATABASE"
            value =  "vodafone-test"
          }

          env {
            name = "MYSQL_USER"
            value_from {
              secret_key_ref {
                key = "username"
                name = kubernetes_secret.mysql-test-secrets.metadata[0].name
              }
            }
          }

          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                key = "password"
                name = kubernetes_secret.mysql-test-secrets.metadata[0].name
              }
            }
          }



          # liveness_probe {
          #   http_get {
          #     path = "/nginx_status"
          #     port = 80

          #     http_header {
          #       name  = "X-Custom-Header"
          #       value = "Awesome"
          #     }
          #   }

          #   initial_delay_seconds = 3
          #   period_seconds        = 3
          # }
          volume_mount {
            mount_path = "/var/lib/mysql"
            name = "mysql-test-volume"
          }
        }
        volume {
            name = "mysql-test-volume"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.mysql-test-pvc.metadata[0].name
            }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql-test-pvc" {
  metadata {
    name = "mysql-test-pvc"
    namespace = kubernetes_namespace.test.metadata[0].name

  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}


resource "kubernetes_secret" "mysql-test-secrets" {
  metadata {
    name = "mysql-test-secrets"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  data = {
    username = "mina"
    password = "123456"
  }
}