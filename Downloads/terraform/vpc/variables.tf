variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "리소스가 생성될 리전"
}
variable "name" {
  type        = string
  default     = "pchoon"
  description = "공통으로 사용할 이름"
}
variable "tag" {
  type        = string
  default     = "pchoon@mz.co.kr"
  description = "태그 이름"
}
variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "VPC IP 대역"
}
variable "public_subnets" {
  type = map(any)
  default = {
    public_subnet_a = {
      az   = "ap-northeast-2a"
      cidr = "192.168.0.0/24"
    }
    public_subnet_c = {
      az   = "ap-northeast-2c"
      cidr = "192.168.1.0/24"
    }
  }
  description = "퍼블릭 서브넷이 사용할 IP대역과, 가용영역"
}
variable "private_subnets" {
  type = map(any)
  default = {
    private_subnet_a = {
      az   = "ap-northeast-2a"
      cidr = "192.168.128.0/24"
    }
    private_subnet_c = {
      az   = "ap-northeast-2c"
      cidr = "192.168.129.0/24"
    }
  }
  description = "프라이빗 서브넷이 사용할 IP대역과, 가용영역"
}
