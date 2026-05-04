# ==================================================
# Auto Scaling ターゲット
# ==================================================
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.asg_max_count
  min_capacity       = var.asg_min_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ==================================================
# CPU使用率に基づくスケーリングポリシー
# ==================================================
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${local.app_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value        = 70.0
    scale_out_cooldown  = 300
    scale_in_cooldown   = 300
  }
}
