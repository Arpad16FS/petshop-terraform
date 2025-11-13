# =====================================
# VPC por defecto
# =====================================
data "aws_vpc" "default" {
  default = true
}

# =====================================
# Subredes existentes (ajusta los IDs reales de tus subredes)
# =====================================
# Puedes obtener los IDs en la consola de AWS → VPC → Subnets
# o con el comando: aws ec2 describe-subnets --filters "Name=vpc-id,Values=<tu-vpc-id>"

data "aws_subnet" "public_1" {
  id = "subnet-02e2c54158706f1ce" # ← reemplaza con tu Subnet 1 (AZ: us-east-1a)
}

data "aws_subnet" "public_2" {
  id = "subnet-08d3544ba8bf8fb1c" # ← reemplaza con tu Subnet 2 (AZ: us-east-1b)
}

# =====================================
# Internet Gateway (ya existe en la VPC por defecto)
# =====================================
data "aws_internet_gateway" "default_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# =====================================
# Tabla de ruteo pública (ya existe, pero puedes crear una nueva si quieres control)
# =====================================
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default_igw.id
  }

  tags = {
    Name = "petshop-public-rt"
  }
}

# =====================================
# Asociaciones de tabla de ruteo
# =====================================
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = data.aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = data.aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

