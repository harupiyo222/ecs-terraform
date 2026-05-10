# ==================================================
# DBパスワード自動生成
# ==================================================
resource "random_password" "db" {
  length  = 16
  special = false
}

# ==================================================
# SSM Parameter Store にパスワードを保存
# ==================================================
resource "aws_ssm_parameter" "db_password" {
  name  = "/${local.app_name}/db/password"
  type  = "SecureString"
  value = random_password.db.result

  tags = {
    Name = "${local.app_name}-db-password"
  }
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
  password = random_password.db.result

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
