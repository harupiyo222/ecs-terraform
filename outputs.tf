# ===== VPC 出力 =====
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR ブロック"
  value       = aws_vpc.main.cidr_block
}

# ===== ALB 出力 =====
output "alb_dns_name" {
  description = "ALB DNS 名（ブラウザからアクセスするエンドポイント）"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "ALB ゾーン ID"
  value       = aws_lb.main.zone_id
}

# ===== ECS 出力 =====
output "ecs_cluster_name" {
  description = "ECS クラスタ名"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECS クラスタ ARN"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "ECS サービス名"
  value       = aws_ecs_service.api.name
}

output "ecs_task_definition_arn" {
  description = "ECS タスク定義 ARN"
  value       = aws_ecs_task_definition.api.arn
}

output "ecs_task_definition_revision" {
  description = "ECS タスク定義リビジョン"
  value       = aws_ecs_task_definition.api.revision
}

# ===== Auto Scaling 出力 =====
output "asg_resource_id" {
  description = "Auto Scaling グループリソース ID"
  value       = aws_appautoscaling_target.ecs_target.resource_id
}

output "current_task_count" {
  description = "現在のタスク数"
  value       = aws_ecs_service.api.desired_count
}

output "min_task_count" {
  description = "最小タスク数"
  value       = var.asg_min_count
}

output "max_task_count" {
  description = "最大タスク数"
  value       = var.asg_max_count
}

# ===== ネットワーク出力 =====
output "nat_gateway_ip" {
  description = "NAT Gateway Elastic IP"
  value       = aws_eip.nat.public_ip
}

output "alb_subnet_ids" {
  description = "ALB サブネット IDs"
  value       = aws_subnet.alb[*].id
}

output "api_subnet_ids" {
  description = "API サブネット IDs"
  value       = aws_subnet.api[*].id
}

# ===== セキュリティグループ出力 =====
output "alb_security_group_id" {
  description = "ALB セキュリティグループ ID"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS セキュリティグループ ID"
  value       = aws_security_group.ecs.id
}

# ===== ログ出力 =====
output "cloudwatch_log_group_name" {
  description = "CloudWatch ロググループ名"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch ロググループ ARN"
  value       = aws_cloudwatch_log_group.ecs.arn
}

# ===== IAM 出力 =====
output "ecs_task_execution_role_arn" {
  description = "ECS タスク実行ロール ARN"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ECS タスクロール ARN"
  value       = aws_iam_role.ecs_task_role.arn
}

# ===== アクセス情報 =====
output "application_url" {
  description = "アプリケーションへのアクセス URL"
  value       = "http://${aws_lb.main.dns_name}"
}
