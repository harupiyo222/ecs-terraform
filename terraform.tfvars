# 環境設定
project_name = "myapp"
environment  = "production"
aws_region   = "ap-northeast-1"

# ネットワーク設定
vpc_cidr            = "10.0.0.0/21"
alb_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]   # Public
api_subnet_cidrs    = ["10.0.3.0/24", "10.0.4.0/24"]   # Private

# ECS 設定
ecs_cluster_name   = "api-cluster"
ecs_task_family    = "api-server"
# ← 以下の container_image を自分の ECR イメージ URI に変更してください
# 例：123456789.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:latest
container_image    = ""
container_port     = 8080
container_memory   = 512  # MB
container_cpu      = 256  # CPU Units

# Auto Scaling 設定
asg_desired_count = 2  # 常に実行するタスク数
asg_min_count     = 2  # 最小タスク数
asg_max_count     = 4  # 最大タスク数

# ヘルスチェック設定
health_check_path = "/"  # ヘルスチェックパス（アプリで対応しているパスを指定）
