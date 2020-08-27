resource "kubernetes_namespace" "build" {
  metadata {
    annotations = {
      type = "build"
    }

    labels = {
      type = "build"
    }

    name = "build"
  }
}

resource "kubernetes_namespace" "test" {
  metadata {
    annotations = {
      type = "test"
    }

    labels = {
      type = "test"
    }

    name = "test"
  }
}

resource "kubernetes_namespace" "dev" {
  metadata {
    annotations = {
      type = "dev"
    }

    labels = {
      type = "dev"
    }

    name = "dev"
  }
}