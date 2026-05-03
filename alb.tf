# ==================================================
# Application Load Balancer
# ==================================================
resource "aws_lb" "main" {
  name               = "${local.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.alb[*].id

  enable_deletion_protection = false

  tags = {
    Name = "${local.app_name}-alb"
  }
}

# ==================================================
# ALBターゲットグループ
# ==================================================
resource "aws_lb_target_group" "api" {
  name        = "${local.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
  }

  tags = {
    Name = "${local.app_name}-tg"
  }
}

# ==================================================
# ALBリスナー
# ==================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# HTTPS リスナー（オプション：証明書が必要）
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = "arn:aws:acm:ap-northeast-1:ACCOUNT_ID:certificate/CERTIFICATE_ID"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.api.arn
#   }
# }
