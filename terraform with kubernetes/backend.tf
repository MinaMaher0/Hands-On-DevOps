terraform{
  backend "s3" {
    bucket = "terraform-task-vodafone"
    key    = "k8s/terraform.tfstate"
    region = "us-east-2"
  }
}