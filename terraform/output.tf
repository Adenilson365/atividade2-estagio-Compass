

output "dns_efs" {
  value = aws_efs_file_system.efs-001.dns_name
}

output "db_address" {
  value = aws_db_instance.default.address
}


output "alb_dns" {
  value = aws_lb.lb001.dns_name
}