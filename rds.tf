# ==================================================
# Secrets Manager - Root User (auto-managed by RDS)
# Note: Created automatically via manage_master_user_password = true
# ==================================================

# ==================================================
# Secrets Manager - App User
# Note: Not named to avoid 7-day deletion wait
# ==================================================
resource "aws_secretsmanager_secret" "rds_app" {
  name_prefix = "${local.app_name}-rds-app-"
  description = "Secret for RDS app user (${local.app_name})"

  tags = {
    Name = "${local.app_name}-rds-app-secret"
  }
}

resource "random_password" "rds_app" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret_version" "rds_app" {
  secret_id = aws_secretsmanager_secret.rds_app.id
  secret_string = jsonencode({
    database = var.db_name
    username = var.db_username
    password = random_password.rds_app.result
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
  })
}

# ==================================================
# DB Subnet Group
# ==================================================
resource "aws_db_subnet_group" "main" {
  name        = "${local.app_name}-rds-subgrp"
  description = "${local.app_name}-rds-subgrp"
  subnet_ids  = aws_subnet.private[*].id

  tags = {
    Name = "${local.app_name}-rds-subgrp"
  }
}

# ==================================================
# DB Parameter Group
# ==================================================
resource "aws_db_parameter_group" "main" {
  name        = "${local.app_name}-rds-pg"
  description = "${local.app_name}-rds-pg"
  family      = "mysql8.0"

  tags = {
    Name = "${local.app_name}-rds-pg"
  }
}

# ==================================================
# RDS Instance
# ==================================================
resource "aws_db_instance" "main" {
  identifier        = "${local.app_name}-rds"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  storage_encrypted = true

  backup_retention_period = 7

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = "${local.app_name}-rds"
  }
}
