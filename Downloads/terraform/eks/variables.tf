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
