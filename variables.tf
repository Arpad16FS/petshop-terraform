###############################################
# VARIABLES GENERALES DE AWS
###############################################
variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}

###############################################
# VARIABLES DE RED (VPC, SUBNETS, ROUTES)
###############################################
variable "vpc_cidr" {
  description = "Rango CIDR principal de la VPC."
  type        = string
  default     = "10.0.0.0/16"
}



variable "subnet_ids" {
  description = "Subredes existentes en distintas zonas de disponibilidad"
  type        = list(string)
  default     = ["subnet-02e2c54158706f1ce", "subnet-08d3544ba8bf8fb1c"]
}


###############################################
# VARIABLES DE SEGURIDAD
###############################################
variable "app_sg_id" {
  description = "ID del Security Group para las instancias de aplicación (opcional)."
  type        = string
  default     = ""
}

variable "alb_sg_id" {
  description = "ID del Security Group para el Application Load Balancer (opcional)."
  type        = string
  default     = ""
}

variable "allow_ssh_from" {
  description = "Rango de IPs permitidas para SSH. Usa '' para deshabilitar."
  type        = string
  default     = ""
}

###############################################
# VARIABLES DE INSTANCIAS EC2 / AUTOSCALING
###############################################
variable "instance_type" {
  description = "Tipo de instancia EC2."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID (opcional). Si está vacío, Terraform buscará la más reciente de Amazon Linux 2."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Nombre del par de claves SSH (opcional)."
  type        = string
  default     = ""
}

variable "instance_profile" {
  description = "Instance profile existente para asociar con las instancias (opcional)."
  type        = string
  default     = ""
}

###############################################
# VARIABLES DE IDENTIFICACIÓN
###############################################

variable "vpc_id" {
  description = "VPC existente por defecto"
  type        = string
  default     = "vpc-0086f91881fb8c96c"
}

###############################################
# VARIABLES DE SUBREDES PÚBLICAS
###############################################
variable "public_subnet_1_cidr" {
  description = "Rango CIDR de la primera subred pública (AZ us-east-1a)"
  type        = string
  default     = "172.31.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "Rango CIDR de la segunda subred pública (AZ us-east-1b)"
  type        = string
  default     = "172.31.2.0/24"
}



