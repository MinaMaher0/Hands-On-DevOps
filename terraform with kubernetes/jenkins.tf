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
        
        service_account_name = kubernetes_service_accountjenkins-account.metadata[0].name
        automount_service_account_token = true
        
        init_container {
          name = "install-kubectl"
          image = "allanlei/kubectl"

          command = ["cp", "/usr/local/bin/kubectl", "/data/kubectl"]

          volume_mount {
              mount_path = "/data"
              name = "kubectl-docker-bin"
          }
        }

        init_container {
          name = "install-dockercli"
          image = "docker"

          command = ["cp", "/usr/local/bin/docker", "/data/docker"]

          volume_mount {
              mount_path = "/data"
              name = "kubectl-docker-bin"
          }
        }

        security_context {
          fs_group = "1000"
        }
        container {
          image = "minamaher0/jenkins-ansible:1.0"
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
          volume_mount {
              mount_path = "/usr/local/bin/kubectl"
              sub_path = "kubectl"
              name = "kubectl-docker-bin"
          }

          volume_mount {
              mount_path = "/usr/local/bin/docker"
              sub_path = "docker"
              name = "kubectl-docker-bin"
          }
          volume_mount {
            mount_path = "/var/run/docker.sock"
            name       = "docker-sock-volume"
          }

          # volume_mount {
          #   mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          #   name       = kubernetes_service_account.jenkins-account.default_secret_name
          #   read_only  = true
          # }
        }
        volume {
            name = "jenins-volume"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.jenkins-pvc.metadata[0].name
            }
        }
        volume {
            name = "kubectl-docker-bin"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.jenkins-ref-pvc.metadata[0].name
            }
        }

        volume {
            name = "docker-sock-volume"
            host_path {
              path = "/var/run/docker.sock"
              type = "File"
            }
        }
        
        # volume {
        #   name = kubernetes_service_account.jenkins-account.default_secret_name

        #   secret {
        #     secret_name = kubernetes_service_account.jenkins-account.default_secret_name
        #   }
        # }
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

resource "kubernetes_persistent_volume_claim" "jenkins-ref-pvc" {
  metadata {
    name = "jenkins-ref-pvc"
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