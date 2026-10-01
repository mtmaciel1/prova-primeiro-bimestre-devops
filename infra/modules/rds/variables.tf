variable "project_name" {
  description = "Prefixo usado nos nomes dos recursos"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnets privadas (output do modulo vpc). Minimo 2, em AZs diferentes"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "SG do RDS que libera 5432 apenas para o SG da EC2 (output do modulo security-group)"
  type        = string
}

variable "engine_version" {
  description = "Versao do PostgreSQL. A 15 nao exige SSL por padrao, compativel com o Pool da API"
  type        = string
  default     = "15"
}

variable "instance_class" {
  description = "Classe da instancia"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Armazenamento em GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nome do banco criado na inicializacao"
  type        = string
  default     = "reservas_db"
}

variable "db_username" {
  description = "Usuario mestre do banco"
  type        = string
  default     = "reservas_admin"
}

variable "db_password" {
  description = "Senha do usuario mestre (somente letras e numeros, minimo 8)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8 && can(regex("^[A-Za-z0-9]+$", var.db_password))
    error_message = "A senha precisa ter no minimo 8 caracteres, apenas letras e numeros."
  }
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos do modulo"
  type        = map(string)
  default     = {}
}
