#!/bin/bash

sudo apt update;
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common python3-pip virtualenv python3-setuptools conntrack;
sudo install -m 0755 -d /etc/apt/keyrings;
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc;
sudo chmod a+r /etc/apt/keyrings/docker.asc;

# sudo tee /etc/apt/sources.list.d/docker.sources <<EOF Types: deb URIs: https://download.docker.com/linux/ubuntu Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") Components: stable Signed-By: /etc/apt/keyrings/docker.asc EOF

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF;

sudo apt update;

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin;
# sudo systemctl status docker
sudo groupadd docker;
sudo usermod -aG docker $USER;
# newgrp docker
echo STEP-EmE3IDFNLh_iPVx5BOM_Sm86MQp1Om95CA.01.0y0h33awk | docker login --username juliette-mathivet --password-stdin registry.git.step.polymtl.ca;

docker pull registry.git.step.polymtl.ca/log8100/equipe11/tp3:latest;

#kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl";
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl;

#microk8s
sudo snap install -y microk8s --classic --channel=1.25/stable;
sudo usermod -a -G microk8s ubuntu;
sudo chown -f -R ubuntu ~/.kube;
newgrp microk8s;

microk8s enable dns;
microk8s enable dashboard;
microk8s enable storage;



cd ../kubernetes;

# kubectl create secret docker-registry regcred 
#         --docker-server=registry.git.step.polymtl.ca
#         --docker-username=juliette-mathivet
#         --docker-password=STEP-EmE3IDFNLh_iPVx5BOM_Sm86MQp1Om95CA.01.0y0h33awk
#         --docker-email=juliette.mathivet@etud.polymtl.ca

microk8s kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/home/ubuntu/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson;

microk8s kubectl apply -f webgoat-deployment.yaml;

microk8s kubectl expose deployment webgoat-deployment --type=NodePort --name=webgoat --port=8080;
microk8s kubectl port-forward service/webgoat 8080:80;


