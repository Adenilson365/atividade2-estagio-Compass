resource "aws_ssm_parameter" "parameter001" {
  name  = "dns_efs_parameter"
  type  = "String"
  value = aws_efs_file_system.efs-001.dns_name
  tags  = var.default_tags_estagio
}

resource "aws_ssm_parameter" "parameter002" {
  name       = "rds_parameter"
  type       = "StringList"
  value      = join(",", [aws_db_instance.default.address, aws_db_instance.default.username, aws_db_instance.default.password, aws_db_instance.default.db_name])
  depends_on = [aws_db_instance.default]
}

resource "aws_ssm_parameter" "parameter003" {
  name       = "alb_dns"
  type       = "String"
  value      = aws_lb.lb001.dns_name
  depends_on = [aws_lb.lb001]
}