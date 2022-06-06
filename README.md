# Cluster EKS com Prometheus + Grafana + External DNS + GitlabCI com terraform


# INTRODUÇÃO
O objetivo deste projeto é criar um cluster completo de kubernetes juntamente com observabilidade com Grafana + Prometheus e um external DNS para configuração das rotas do ELB

## Expecificação do projeto

O projeto foi contruido utilizando dua subnets publicas e duas subnets privadas, as subnets publicas foram anexadas a um internet gateway para acesso completo a internet. 
As subnets privadas, foram anexadas a um nat gateway anexadas as subnets publicas, liberado trafego para a internet unilateralmente

Os nos foram contruidos utilizando node groups, anexos as redes privadas(com acesso unilateral para a internet)

O cluster, está habilitado para provisionar ELB, e para a criação dos registros no route53, foi utilizado o plugin "External DNS" indicado pela propria AWS

Juntamente com o cluster, foi prosionado uma instancia do Gitlab como ferramenta de CI, esse instancia, está anexa a uma sunnet publica com visibilidade ao cluster, e com uma security group expecifica para isolamento do acesso

## Pre-requisitos
1.  Usuario de acesso aws com permissão de administração do EKS
2.  Zone de DNS configurada na conta
3.  AWS cli instalado localmente
4.  Para a codificação IAC foi utilizado a versão do terraform v1.2.1

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

## Pos execução 
Uma vez instalado o cluster, será preciso configurar o runner master inicial com acesso ao gerenciamento do cluster, sendo sendo assim, apos a execução uma chave PEM será gerada na pasta dados, ultilize-a para acessar a instancia do gitlab e configurar as credenciais da AWS e do kubectl

Em seguida, siga os passo do gitlab para registrar um runner do tipo shell na maquina do gitlab