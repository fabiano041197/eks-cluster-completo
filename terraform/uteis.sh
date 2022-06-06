#Comando para fazer o reset da senha do gitlab
sudo gitlab-rake "gitlab:password:reset[root]"

#Comando para registrar o gitlab-runner no gitlab 
sudo gitlab-runner register --url http://gitlab.playground.betha.cloud/ --registration-token <token>


#Comando para configurar as credenciais da AWS no gitlab
aws configure

#Depois de configurar o aws cli dentro do cluster, utilizar o comando abaixo para configurar o kubectl
aws eks update-kubeconfig --region  us-east-1 --name eks # <- Nome do cluster


#Comando para forçar a destruição de um pod
kubectl delete pods noome-do-pod --grace-period=0 --force