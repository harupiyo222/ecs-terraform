terraform {
  backend "s3" {
    bucket  = "aws-tfstate-20260505"
    key     = "ecs-terraform/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
