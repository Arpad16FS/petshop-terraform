output "alb_dns_name" {
  description = "DNS del Load Balancer para acceder a la app"
  value       = aws_lb.petshop_alb.dns_name
}
