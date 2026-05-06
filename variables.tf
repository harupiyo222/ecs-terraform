# プロジェクト設定
variable "project_name" {
  description = "プロジェクト名"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "環境名"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

# ネットワーク設定
variable "vpc_cidr" {
  description = "VPC CIDR ブロック"
  type        = string
  default     = "10.0.0.0/21"
}

variable "alb_subnet_cidrs" {
  description = "ALB subnet CIDRs (multi-AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "protected_subnet_cidrs" {
  description = "Protected subnet CIDRs for ECS (multi-AZ)"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for RDS (multi-AZ)"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

# ECS 設定
variable "ecs_cluster_name" {
  description = "ECS クラスタ名"
  type        = string
  default     = "app-cluster"
}

variable "ecs_task_family" {
  description = "ECS タスク定義ファミリー名"
  type        = string
  default     = "app-server"
}

variable "container_image" {
  description = "コンテナイメージ URI (ECR)"
  type        = string
}

variable "container_port" {
  description = "コンテナのポート番号"
  type        = number
  default     = 8080
}

variable "container_memory" {
  description = "コンテナメモリ（MB）"
  type        = number
  default     = 512
}

variable "container_cpu" {
  description = "コンテナ CPU ユニット"
  type        = number
  default     = 256
}

# Auto Scaling 設定
variable "asg_desired_count" {
  description = "目的のタスク数"
  type        = number
  default     = 2
}

variable "asg_min_count" {
  description = "最小タスク数"
  type        = number
  default     = 2
}

variable "asg_max_count" {
  description = "最大タスク数"
  type        = number
  default     = 4
}

# RDS 設定
variable "db_name" {
  description = "データベース名"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "DBユーザー名"
  type        = string
  default     = "dbadmin"
}

variable "db_instance_class" {
  description = "DBインスタンスクラス"
  type        = string
  default     = "db.t3.micro"
}

# ドメイン設定
variable "domain_name" {
  description = "Domain name"
  type        = string
}

# ヘルスチェック
variable "health_check_path" {
  description = "ヘルスチェックパス"
  type        = string
  default     = "/"
}
