output "alb_dns_name" {
  description = "Public ALB DNS address to hit in your browser"
  value       = aws_lb.external_alb.dns_name
}

output "rds_endpoint" {
  description = "Internal DB Endpoint in VPC-B"
  value       = aws_db_instance.postgres.endpoint
}
