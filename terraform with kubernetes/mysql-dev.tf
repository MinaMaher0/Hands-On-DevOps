resource "kubernetes_deployment" "mysql-dev" {
  metadata {
    name = "mysql-dev"
    labels = {
      app = "mysql-dev"
    }
    namespace = kubernetes_namespace.dev.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql-dev"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql-dev"
        }
      }

      spec {
        container {
          image = "mysql:8.0.21"
          name  = "mysql-dev"

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
            value =  "vodafone-dev"
          }

          env {
            name = "MYSQL_USER"
            value_from {
              secret_key_ref {
                key = "username"
                name = kubernetes_secret.mysql-dev-secrets.metadata[0].name
              }
            }
          }

          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                key = "password"
                name = kubernetes_secret.mysql-dev-secrets.metadata[0].name
              }
            }
          }

          volume_mount {
            mount_path = "/var/lib/mysql"
            name = "mysql-dev-volume"
          }

        }
        volume {
            name = "mysql-dev-volume"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.mysql-dev-pvc.metadata[0].name
            }
        }
        
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql-dev-pvc" {
  metadata {
    name = "mysql-dev-pvc"
    namespace = kubernetes_namespace.dev.metadata[0].name

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

resource "kubernetes_secret" "mysql-dev-secrets" {
  metadata {
    name = "mysql-dev-secrets"
    namespace = kubernetes_namespace.dev.metadata[0].name
  }

  data = {
    username = "mina"
    password = "123456"
  }
} 