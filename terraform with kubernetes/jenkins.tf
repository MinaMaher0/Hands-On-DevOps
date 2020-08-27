resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "jenkins"
    labels = {
      app = "jenkins"
    }
    namespace = kubernetes_namespace.build.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }

      spec {

        security_context {
          fs_group = "1000"
        }
        container {
          image = "jenkins/jenkins:lts"
          name  = "jenkins"

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

          volume_mount {
              mount_path = "/var/jenkins_home"
              name = "jenins-volume"
          }

        }
        volume {
            name = "jenins-volume"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.jenkins-pvc.metadata[0].name
            }
        }

      }
    }
  }
}


resource "kubernetes_service" "jenkins_svc" {
  metadata {
    name = "jenkins-svc"
    namespace = kubernetes_namespace.build.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.jenkins.spec[0].selector[0].match_labels.app
    }
    port {
      port        = 8080
      target_port = 8080
      node_port = 30007
    }

    type = "NodePort"
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins-pvc" {
  metadata {
    name = "jenkins-pvc"
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