# ==================================================
# Project
# ==================================================
project_name = "aws"
environment  = "prod"
aws_region   = "ap-northeast-1"

# ==================================================
# Network
# ==================================================
vpc_cidr               = "10.0.0.0/21"
alb_subnet_cidrs       = ["10.0.1.0/24", "10.0.2.0/24"]
protected_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
private_subnet_cidrs   = ["10.0.5.0/24", "10.0.6.0/24"]

# ==================================================
# ECS
# ==================================================
ecs_cluster_name = "app-cluster"
ecs_task_family  = "app-server"
container_image = "904469541992.dkr.ecr.ap-northeast-1.amazonaws.com/todo-app:latest"
container_port      = 3000
container_memory = 512
container_cpu    = 256

# ==================================================
# Auto Scaling
# ==================================================
asg_desired_count = 1
asg_min_count     = 1
asg_max_count     = 2

# ==================================================
# RDS
# ==================================================
db_name           = "appdb"
db_username       = "dbadmin"
db_instance_class = "db.t3.micro"

# ==================================================
# Domain
# ==================================================
domain_name            = "haru-aws.link"
cloudfront_domain_name = "d3a34epgrtx905.cloudfront.net"

# ==================================================
# Health Check
# ==================================================
health_check_path = "/api/health"
