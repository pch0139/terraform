terraform {
  backend "s3" {
    bucket      = "pchoon-s3"
    key         = "vpc/terraform.tfstate"
    region      = "ap-northeast-2"
    max_retries = 3
    encrypt     = true
  }
}
