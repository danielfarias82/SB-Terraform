module "aurora_mysql" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name              = var.database_name
  engine            = "aurora-mysql"
  engine_mode       = "serverless"
  storage_encrypted = true

  vpc_id                = var.vpc_id
  subnets               = var.database_subnets
  create_security_group = true
  allowed_cidr_blocks   = var.database_subnets_cidr_blocks

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  allowed_security_groups = ["${var.cluster_sg_id}"]

  db_parameter_group_name         = aws_db_parameter_group.mysql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql.id

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 1
    max_capacity             = 1
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  enable_http_endpoint = true
  database_name        = var.database_name

  create_random_password = false
  master_username        = var.db_username
  master_password        = var.db_password
}

resource "aws_db_parameter_group" "mysql" {
  name        = "${var.database_name}-aurora-db-mysql-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.database_name}-aurora-db-mysql-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "mysql" {
  name        = "${var.database_name}-aurora-mysql-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.database_name}-aurora-mysql-cluster-parameter-group"
}