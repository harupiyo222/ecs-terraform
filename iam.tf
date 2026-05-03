# ==================================================
# ECS タスク実行ロール
# ==================================================
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.app_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.app_name}-ecs-task-execution-role"
  }
}

# ECS タスク実行ロール - 基本ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECR アクセス権限の追加
resource "aws_iam_role_policy" "ecs_ecr_access" {
  name = "${local.app_name}-ecs-ecr-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Logs アクセス権限の追加
resource "aws_iam_role_policy" "ecs_logs_policy" {
  name = "${local.app_name}-ecs-logs-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/ecs/*"
      }
    ]
  })
}

# ==================================================
# ECS タスクロール（アプリケーション用）
# ==================================================
resource "aws_iam_role" "ecs_task_role" {
  name = "${local.app_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.app_name}-ecs-task-role"
  }
}

# アプリケーション用の権限を追加（必要に応じてカスタマイズ）
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${local.app_name}-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}
