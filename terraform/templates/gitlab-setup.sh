#! /bin/bash

###########################################################
### SCRIPT PARA INSTALAÇÃO DO GITLAB NO CENTOS/REDHAT 8 ###
###########################################################

#Instalação do AWS_CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

#Instalação do kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#Atualiza lista de distrubuição e Instala e configura dependencias necessárias
dnf update & sudo dnf install -y curl policycoreutils openssh-server perl

#Instala postfix
sudo dnf install postfix -y & sudo systemctl enable postfix 
sudo systemctl start postfix

#Adiciona repositorios do GitLab
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

sudo EXTERNAL_URL="http://$(hostname -i | cut -d' ' -f2)" dnf install -y gitlab-ee

#Gera uma senha inicial para o usuário root
#/etc/gitlab/initial_root_password

#Instalação do gitlab-runner dentro do gitlab
# Download the binary for your system
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash

sudo yum install gitlab-runner -y

sudo systemctl enable gitlab-runner

