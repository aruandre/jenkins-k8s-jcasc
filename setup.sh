#! /bin/sh

minikube_min_version="1.32.0"
terraform_min_version="1.5.0"
minikube_ip="192.168.58.10"
memory="4096"
cpus="2"

# Detect host OS and install required pacakges
# Currently supports only linux (deb) and MacOS
# Assuming Docker is already installed
case $(uname | tr '[:upper:]' '[:lower:]') in
  darwin*)
    echo "OS type: OSX"
    echo "Checking if minikube exists..."
    if ! which minikube; then
        echo "Installing minikube"
        brew install socket_vmnet
        brew tap homebrew/services
        HOMEBREW=$(which brew) && sudo "${HOMEBREW}" services start socket_vmnet
        brew install minikube
    fi

    echo "Checking minikube version..."
    if [ "$(minikube version --short | tr -d "v")" \< $minikube_min_version ]; then
        echo "Minikube $(minikube version --short) found. Minimum required version is $minikube_min_version, please upgrade manually. Exiting..."
        exit 1
    fi

    minikube version | head -1
    minikube start --driver qemu --memory $memory --cpus $cpus
    # minikube dashboard

    echo "Checking if terraform exists..."
    if ! which terraform; then
        echo "Installing terraform"
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    fi

    echo "Checking terraform version..."
    if [ "$(terraform version | head -1 | sed 's/Terraform v//')" \< $terraform_min_version ]; then
        echo "$(terraform version | head -1) found. Minimum required version is $terraform_min_version, please upgrade manually. Exiting..."
        exit 1
    fi

    terraform version | head -1
  ;;
  linux*)   # For now let's assume it's deb
    echo "OS type: LINUX"
    echo "Checking if minikube exists..."
    if ! which minikube; then
        if [ "$(uname -m)" = "x86_64" ]; then
            cpu_arch="amd64"
        fi

        sudo apt update -y && sudo apt upgrade -y
        sudo apt install -y curl wget apt-transport-https qemu qemu-system
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_"$cpu_arch".deb
        sudo dpkg -i minikube_latest_"$cpu_arch".deb
    fi
    
    echo "Checking minikube version..."
    if [ "$(minikube version --short | tr -d "v")" \< $minikube_min_version ]; then
        echo "Minikube $(minikube version --short) found. Minimum required version is $minikube_min_version, please upgrade manually. Exiting..."
        exit 1
    fi

    minikube version
    minikube start --driver docker --memory $memory --cpus $cpus
    #minikube dashboard

    echo "Checking if terraform exists..."
    if ! which terraform; then
        sudo apt install -y gnupg software-properties-common
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install -y terraform
        terraform version
    fi

    echo "Checking terraform version..."
    if [ "$(terraform version | head -1 | sed 's/Terraform v//')" \< $terraform_min_version ]; then
        echo "$(terraform version | head -1) found. Minimum required version is $terraform_min_version, please upgrade manually. Exiting..."
        exit 1
    fi

    terraform version | head -1
  ;;
#   solaris*) echo "SOLARIS" ;;
#   bsd*)     echo "BSD" ;;
#   msys*)    echo "WINDOWS" ;;
#   cygwin*)  echo "ALSO WINDOWS" ;;
  *)        echo "Not supported OS type: $OSTYPE" ;;
esac

# Deploy
terraform init
terraform apply -auto-approve

minikube service jenkins -n jenkins

echo "Jenkins admin user: $(kubectl get secret jenkins -n jenkins -o jsonpath='{.data.jenkins-admin-user}' | base64 -d)"
echo "Jenkins admin password: $(kubectl get secret jenkins -n jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d)"
