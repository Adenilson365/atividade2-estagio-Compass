
#SG ALB 
resource "aws_security_group" "sg-001" {
  name        = "security-tf"
  description = "Security group test tf"
  vpc_id      = aws_vpc.vpc-tf.id
  tags        = var.default_tags_estagio
}


resource "aws_vpc_security_group_egress_rule" "saida" {
  security_group_id = aws_security_group.sg-001.id
  description       = "Regra de saida total"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.sg-001.id
  description       = "Allow http from my ip"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


# SG EC2
resource "aws_security_group" "sg-002" {
  name        = "security-tf-ec2-to-alb"
  description = "Security group test tf"
  vpc_id      = aws_vpc.vpc-tf.id
  tags        = var.default_tags_estagio
}

resource "aws_vpc_security_group_egress_rule" "saida-total" {
  security_group_id = aws_security_group.sg-002.id
  description       = "Regra de saida total"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#80 aberta para ELB
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb" {
  security_group_id            = aws_security_group.sg-002.id
  description                  = "Allow http from alb"
  referenced_security_group_id = aws_security_group.sg-001.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_rds" {
  security_group_id            = aws_security_group.sg-002.id
  description                  = "round-trip-rds-ec2"
  referenced_security_group_id = aws_security_group.sg-004.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.sg-002.id
  description       = "Allow ssh from my ip"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_nfs_from_nfs_udp" {
  security_group_id            = aws_security_group.sg-002.id
  description                  = "Allow ec2 from efs"
  referenced_security_group_id = aws_security_group.sg-003.id
  from_port                    = 2049
  ip_protocol                  = "udp"
  to_port                      = 2049
}
resource "aws_vpc_security_group_ingress_rule" "allow_nfs_from_nfs_tcp" {
  security_group_id            = aws_security_group.sg-002.id
  description                  = "Allow ec2 from efs"
  referenced_security_group_id = aws_security_group.sg-003.id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049
}

# SG EFS

resource "aws_security_group" "sg-003" {
  name        = "group-003-efs"
  description = "Sg para anexar ao efs"
  vpc_id      = aws_vpc.vpc-tf.id
  tags        = var.default_tags_estagio
}

resource "aws_vpc_security_group_ingress_rule" "allow_nfs_from_ec2_tcp" {
  security_group_id            = aws_security_group.sg-003.id
  description                  = "Allow nfs from ec2"
  referenced_security_group_id = aws_security_group.sg-002.id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049
}
resource "aws_vpc_security_group_ingress_rule" "allow_nfs_from_ec2_udp" {
  security_group_id            = aws_security_group.sg-003.id
  description                  = "Allow nfs from ec2"
  referenced_security_group_id = aws_security_group.sg-002.id
  from_port                    = 2049
  ip_protocol                  = "udp"
  to_port                      = 2049
}

resource "aws_vpc_security_group_egress_rule" "saida_total_efs" {
  security_group_id            = aws_security_group.sg-003.id
  description                  = "Regra de saida total"
  referenced_security_group_id = aws_security_group.sg-002.id
  ip_protocol                  = "-1"
}


#Security Group RDS <-> EC2
resource "aws_security_group" "sg-004" {
  name        = "security-rds-roundTrip-ec2"
  description = "SG do RDS aberto para EC2"
  vpc_id      = aws_vpc.vpc-tf.id
  tags        = var.default_tags_estagio
}


resource "aws_vpc_security_group_egress_rule" "allow_all_exit_rds" {
  security_group_id = aws_security_group.sg-004.id
  description       = "allow all exit"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ec2" {
  security_group_id            = aws_security_group.sg-004.id
  description                  = "rds to ec2 security group"
  referenced_security_group_id = aws_security_group.sg-002.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}