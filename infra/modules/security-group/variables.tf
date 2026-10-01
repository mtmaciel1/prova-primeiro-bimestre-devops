variable "project_name" {
  description = "Prefixo usado nos nomes dos recursos"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde os SGs serao criados (output do modulo vpc)"
  type        = string
}

variable "api_port" {
  description = "Porta em que a API escuta"
  type        = number
  default     = 3000
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs autorizados a acessar a porta 22"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos do modulo"
  type        = map(string)
  default     = {}
}