locals {
  db_name     = "reservas_db"
  db_username = "reservas_admin"

  tags = {
    Project   = var.project_name
    Owner     = "Matheus Maciel de Paula"
    RA        = "6325065"
    ManagedBy = "Terraform"
  }
}

# 1. Rede
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  tags         = local.tags
}

# 2. Security Groups (recebe a VPC)
module "security_group" {
  source = "./modules/security-group"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  tags              = local.tags
}

# 3. Banco (recebe as subnets privadas e o SG do RDS)
module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.security_group.rds_sg_id
  db_name               = local.db_name
  db_username           = local.db_username
  db_password           = var.db_password
  tags                  = local.tags
}

# 4. Servidor da API (recebe subnet publica, SG da EC2 e o endereco do RDS)
module "ec2" {
  source = "./modules/ec2"

  project_name      = var.project_name
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.ec2_sg_id
  key_name          = var.key_name
  repo_url          = var.repo_url

  db_host     = module.rds.address
  db_port     = module.rds.port
  db_name     = local.db_name
  db_user     = local.db_username
  db_password = var.db_password

  tags = local.tags
}