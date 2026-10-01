variable "project_name" {
  description = "Prefixo dos recursos (minusculas, numeros e hifen; usado no identificador do RDS)"
  type        = string
  default     = "technova-reservas"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.project_name))
    error_message = "Use apenas letras minusculas, numeros e hifen, comecando com letra."
  }
}

variable "db_password" {
  description = "Senha do usuario mestre do RDS (definir em terraform.tfvars, que esta no .gitignore)"
  type        = string
  sensitive   = true
}

variable "repo_url" {
  description = "Repositorio publico clonado pela EC2 no user_data"
  type        = string
  default     = "https://github.com/mtmaciel1/prova-primeiro-bimestre-devops.git"
}

variable "key_name" {
  description = "Key pair para SSH. No Learner Lab existe a 'vockey'. null = sem chave"
  type        = string
  default     = "vockey"
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs autorizados na porta 22"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}