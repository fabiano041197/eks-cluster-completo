# Gera chaves para autenticação da instancia
resource "tls_private_key" "key_pair" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
    key_name   = "linux-key-pair"  
    public_key = tls_private_key.key_pair.public_key_openssh
}
# Sava o arquivo
resource "local_file" "ssh_key" {
    filename = "dados/${aws_key_pair.key_pair.key_name}.pem"
    content  = tls_private_key.key_pair.private_key_pem
}

#AMI da imagem do RHEL
data "aws_ami" "rhel_8_5" {
    most_recent = true
    owners = ["309956199498"] 
    filter {
        name   = "name"
        values = ["RHEL-8.5*"]
    }
    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}


# Grupo de segurança para a instancia
resource "aws_security_group" "git_lab_sg" {
    name        = "gitlab-linux-sg"
    description = "Permite trafico incoming para a instancia"
    vpc_id      = aws_vpc.main.id
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow incoming HTTP connections"
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow incoming SSH connections"
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "gitlab_instance" {
    ami                           = data.aws_ami.rhel_8_5.id
    instance_type                 = "t3.xlarge"
    subnet_id                     = aws_subnet.subnet_publica_1.id
    vpc_security_group_ids        = [aws_security_group.git_lab_sg.id]
    associate_public_ip_address   = true
    source_dest_check             = false
    key_name                      = aws_key_pair.key_pair.key_name
    #Executa script de instalação do gitlab
    user_data                     = file("templates/gitlab-setup.sh")
  
    # Root disco
    root_block_device {
        volume_size           = "20"
        volume_type           = "gp2"
        delete_on_termination = true
        encrypted             = false
    }
    #disco extra
    ebs_block_device {
        device_name           = "/dev/xvda"
        volume_size           = "20"
        volume_type           = "gp2"
        encrypted             = false
        delete_on_termination = true
    }

    tags = {
        Name = "gitlab-ci"
    }
}


#Busca pela zona atual
data "aws_route53_zone" "zona_playground" {
  name         = local.zone_dns
  private_zone = false
}

#Registra um dominio para o gitlab
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zona_playground.zone_id
  name    = "gitlab.${data.aws_route53_zone.zona_playground.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.gitlab_instance.public_ip]
}