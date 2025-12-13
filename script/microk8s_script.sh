#!/bin/bash

sudo apt update;
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common python3-pip virtualenv python3-setuptools conntrack;
sudo install -m 0755 -d /etc/apt/keyrings;
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc;
sudo chmod a+r /etc/apt/keyrings/docker.asc;

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update;

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin;
sudo groupadd docker;
sudo usermod -aG docker $USER;
echo $DOCKER_LOGIN_TOKEN | docker login --username juliette-mathivet --password-stdin registry.git.step.polymtl.ca;

docker pull registry.git.step.polymtl.ca/log8100/equipe11/tp3:latest;

#kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl";
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl;


#microk8s
if snap list microk8s >/dev/null 2>&1; then
    echo "Package microk8s is installed."
else
    echo "Package microk8s is NOT installed."
    sudo snap install microk8s --classic --channel=1.25/stable
fi

sudo microk8s enable dns;
sudo microk8s enable storage;
sudo microk8s enable ingress;

cd ../kubernetes;

sudo microk8s kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/home/ubuntu/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson;

sudo microk8s kubectl apply -f webgoat-deployment.yaml;
sudo microk8s kubectl apply -f webgoat-service.yaml;
sudo microk8s kubectl apply -f webgoat-ingress.yaml;
echo "Please give a few minutes for the ingress to setup";


