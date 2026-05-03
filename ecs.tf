# ==================================================
# CloudWatch ロググループ
# ==================================================
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.app_name}"
  retention_in_days = 7

  tags = {
    Name = "${local.app_name}-log-group"
  }
}

# ==================================================
# ECS クラスタ
# ==================================================
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${local.app_name}-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# ==================================================
# ECS タスク定義
# ==================================================
resource "aws_ecs_task_definition" "api" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.ecs_task_family
      image     = var.container_image != "" ? var.container_image : "nginx:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      # ヘルスチェック（オプション）
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${local.app_name}-task-definition"
  }
}

# ==================================================
# ECS サービス
# ==================================================
resource "aws_ecs_service" "api" {
  name            = "${local.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.asg_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.api[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = var.ecs_task_family
    container_port   = var.container_port
  }

  # サービスの更新時の設定
  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  # サービスディスカバリーの有効化（オプション）
  # service_registries {
  #   registry_arn = aws_service_discovery_service.api.arn
  # }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy.ecs_ecr_access
  ]

  tags = {
    Name = "${local.app_name}-service"
  }
}
