data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "pchoon-s3"
    key    = "vpc/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
