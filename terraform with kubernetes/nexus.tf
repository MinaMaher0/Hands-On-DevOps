resource "kubernetes_deployment" "nexus" {
  metadata {
    name = "nexus"
    labels = {
      app = "nexus"
    }
    namespace = kubernetes_namespace.build.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nexus"
      }
    }

    template {
      metadata {
        labels = {
          app = "nexus"
        }
      }

      spec {
        security_context {
          fs_group = "200"
        }
        container {
          image = "sonatype/nexus3:3.26.1"
          name  = "nexus"

          resources {
            limits {
              cpu    = "1"
              memory = "2Gi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          volume_mount {
            mount_path = "/nexus-data"
            name = "nexus-volume"
          }

        }
        volume {
            name = "nexus-volume"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.nexus-pvc.metadata[0].name
            }
        }
        
      }
    }
  }
}


resource "kubernetes_service" "nexus_svc" {
  metadata {
    name = "nexus-svc"
    namespace = kubernetes_namespace.build.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.nexus.spec[0].selector[0].match_labels.app
    }
    port {
      port        = 8081
      target_port = 8081
      node_port = 30010
    }

    type = "NodePort"
  }
}

resource "kubernetes_persistent_volume_claim" "nexus-pvc" {
  metadata {
    name = "nexus-pvc"
    namespace = kubernetes_namespace.build.metadata[0].name

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