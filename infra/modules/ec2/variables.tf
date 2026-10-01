variable "project_name" {
  description = "Prefixo usado nos nomes dos recursos"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instancia"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet publica onde a EC2 sera criada (output do modulo vpc)"
  type        = string
}

variable "security_group_id" {
  description = "SG da EC2 (output do modulo security-group)"
  type        = string
}

variable "instance_profile_name" {
  description = "Instance profile pre-existente do Learner Lab"
  type        = string
  default     = "LabInstanceProfile"
}

variable "key_name" {
  description = "Key pair para SSH (no Learner Lab existe a 'vockey'). null = sem SSH por chave"
  type        = string
  default     = null
}

variable "repo_url" {
  description = "URL HTTPS do repositorio publico com a pasta app/"
  type        = string
}

variable "repo_branch" {
  description = "Branch a ser clonada"
  type        = string
  default     = "main"
}

variable "api_port" {
  description = "Porta da API"
  type        = number
  default     = 3000
}

variable "db_host" {
  description = "Hostname do RDS, SEM a porta (output address do modulo rds)"
  type        = string
}

variable "db_port" {
  description = "Porta do PostgreSQL"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Nome do banco"
  type        = string
}

variable "db_user" {
  description = "Usuario do banco"
  type        = string
}

variable "db_password" {
  description = "Senha do banco"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos do modulo"
  type        = map(string)
  default     = {}
}