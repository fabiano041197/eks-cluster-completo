# Criação de um cluster EKS com Prometheus + Grafana + External DNS + GitlabCI


# INTRODUÇÃO
O objetivo deste projeto é criar um cluster completo de kubernetes juntamente com observabilidade com Grafana + Prometheus e um external DNS para configuração das rotas do ELB

## Pre-requisitos
1 - Usuario de acesso aws com permissão de administração do EKS
2 - Zone de DNS configurada na conta
3 - AWS cli instalado localmente
4 - Para a codificação IAC foi utilizado a versão do terraform v1.2.1

## Execução
Para executar esse projeto, crie um usuário com o nome de eks-cluster com privilegios de gerenciamento do EKS na AWS

Configure o arquivo variables.tf, de acordo com os parametros exigidos

Inicializar o terraform e modulos
```
terraform init
```

Checar componentes a serem criados
```
terraform plan
```

Criar infraestrutura
```
terraform apply -auto-approve
```