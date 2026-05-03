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
  description = "ALB サブネット CIDR（複数AZ）"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "api_subnet_cidrs" {
  description = "API サブネット CIDR（複数AZ）"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

# ECS 設定
variable "ecs_cluster_name" {
  description = "ECS クラスタ名"
  type        = string
  default     = "api-cluster"
}

variable "ecs_task_family" {
  description = "ECS タスク定義ファミリー名"
  type        = string
  default     = "api-server"
}

variable "container_image" {
  description = "コンテナイメージ URI"
  type        = string
  default     = ""
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

# ヘルスチェック
variable "health_check_path" {
  description = "ヘルスチェックパス"
  type        = string
  default     = "/"
}
