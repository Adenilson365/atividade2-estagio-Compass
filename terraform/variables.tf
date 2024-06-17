variable "default_tags_estagio" {
  type        = map(string)
  description = "Tags Padrão do programa de estagio AWS"
  default = {}
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ami_default" {
  type    = string
  default = "ami-0d191299f2822b1fa"
}

variable "profile" {
  type = string
}

variable "default-region" {
  type    = string
  default = "us-east-1"
}

variable "key-name" {
  type = string

}

variable "db_pass" {
  type = string
}

variable "db_user" {
  type = string
}
variable "db_name" {
  type = string

}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}