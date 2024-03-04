terraform {
  backend "s3" {
    bucket      = "pchoon-s3"
    key         = "ec2/terraform.tfstate"
    region      = "ap-northeast-2"
    max_retries = 3
    encrypt     = true
  }
}
