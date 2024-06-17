resource "aws_db_instance" "default" {
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  username               = var.db_user
  password               = var.db_pass
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  tags                   = var.default_tags_estagio
  db_subnet_group_name   = aws_db_subnet_group.db-group-subs.name
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.sg-004.id]


}


resource "aws_db_subnet_group" "db-group-subs" {
  name       = "db-subnets-group"
  subnet_ids = [aws_subnet.pvt-001.id, aws_subnet.pvt-002.id]

  tags = var.default_tags_estagio

}

