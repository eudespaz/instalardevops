utor: Eudes Paz (eudespaz@live.com)
#Script para instalar docker-compose, racher, build das imagens redis, node, nginx
# 16/05/2021 hora 13:04 

echo "Fazer build das imagens, rodar docker-compose."

#iremos construir as imagens dos containers que iremos usar, colocar elas para rodar em conjunto com o docker-compose.
#Sempre que aparecer , você precisa substituir pelo seu usuário no DockerHub.
#Entrar no host MANAGER, e instalar os pacotes abaixo, que incluem Git, Python, Pip e o Docker-compose.

#com o docker já instalado
 
usermod -aG docker eudes

git config --global user.email "eudespaz@live.com"

git config --global user.name "eudespaz"

curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#Com os pacotes instalados, agora iremos baixar o código fonte e começaremos a fazer os build's e rodar os containers.

cd /home/eudes

git clone https://github.com/eudespaz/devops

cd devops/exercicios/app

#Container=REDIS
echo "Iremos fazer o build da imagem do Redis para a nossa aplicação."

cd redis

docker build -t eudespaz/redis:devops .

docker run -d --name redis -p 6379:6379 eudespaz/redis:devops

docker ps

docker logs redis

#Com isso temos o container do Redis rodando na porta 6379.

#Container=NODE
echo "Iremos fazer o build do container do NodeJs, que contém a nossa aplicação."

cd ../node

docker build -t eudespaz/node:devops .

echo "Agora iremos rodar a imagem do node, fazendo a ligação dela com o container do Redis."

docker run -d --name node -p 8080:8080 --link redis eudespaz/node:devops

docker ps 

docker logs node

#Com isso temos nossa aplicação rodando, e conectada no Redis. A api para verificação pode ser acessada em /redis.

#Container=NGINX
echo "Iremos fazer o build do container do nginx, que será nosso balanceador de carga."

cd ../nginx

docker build -t eudespaz/nginx:devops .

echo "Criando o container do nginx a partir da imagem e fazendo a ligação com o container do Node"

docker run -d --name nginx -p 80:80 --link node eudespaz/nginx:devops

docker ps

#Podemos acessar então nossa aplicação nas portas 80 e 8080 no ip da nossa instância.

echo "Iremos acessar a api em /redis para nos certificar que está tudo ok, e depois iremos limpar todos os containers e volumes."

docker rm -f $(docker ps -a -q)

docker volume rm $(docker volume ls)

#DOCKER-COMPOSE
#Nesse exercício que fizemos agora, colocamos os containers para rodar, e interligando eles, foi possível observar como funciona nossa aplicação que tem um contador de acessos. Para rodar nosso docker-compose, precisamos remover todos os containers que estão rodando e ir na raiz do diretório para rodar.
#É preciso editar o arquivo docker-compose.yml, onde estão os nomes das imagens e colocar o seu nome de usuário.
#Linha 8 = /nginx:devops
#Linha 18 = image: /redis:devops
#Linha 37 = image: /node:devops
#Após alterar e colocar o nome correto das imagens, rodar o comando de up -d para subir a stack toda.

cd ..

#$ vi docker-compose.yml

docker-compose -f docker-compose.yml up -d

#curl <ip>:80 
#	----------------------------------
#	This page has been viewed 29 times
#	----------------------------------
#Se acessarmos o IP:80, iremos acessar a nossa aplicação. Olhar os logs pelo docker logs, e fazer o carregamento do banco em /load
#Para terminar nossa aplicação temos que rodar o comando do docker-compose abaixo:

docker-compose down

#Aula 6 - Rancher - Single Node
#Instalar Rancher - Single Node
#Nesse exercício iremos instalar o Rancher 2.2.5 versão single node. Isso significa que o Rancher e todos seus componentes estão em um container.

echo "hospedar o Rancher Server. Iremos verficar se não tem nenhum container rodando ou parado, e depois iremos instalar o Rancher."

docker ps -a

docker run -d --name rancher --restart=unless-stopped -v /opt/rancher:/var/lib/rancher  -p 80:80 -p 443:443 rancher/rancher:v2.4.3
