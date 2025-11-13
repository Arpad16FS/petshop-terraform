output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.petshop_alb.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint for the petshop database"
  value       = aws_db_instance.petshop_rds.address
}
