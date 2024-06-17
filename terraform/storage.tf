resource "aws_efs_file_system" "efs-001" {
  creation_token = "efs-wp"
  tags           = var.default_tags_estagio
}

resource "aws_efs_mount_target" "a" {
  file_system_id  = aws_efs_file_system.efs-001.id
  subnet_id       = aws_subnet.pb-002.id
  security_groups = [aws_security_group.sg-003.id]
}

resource "aws_efs_mount_target" "b" {
  file_system_id  = aws_efs_file_system.efs-001.id
  subnet_id       = aws_subnet.pb-001.id
  security_groups = [aws_security_group.sg-003.id]
}
