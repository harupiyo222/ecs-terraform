# ==================================================
# Gateway Endpoint: S3 (ECR image layers) ※無料
# ==================================================
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.protected.id]

  tags = {
    Name = "${local.app_name}-vpce-s3"
  }
}
