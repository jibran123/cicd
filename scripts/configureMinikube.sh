#!/bin/sh
echo "This script will ensure that all pre-requisites are met to deploy on minikube setup."
echo "=============1. VirtualBox============="
echo "Checking if Virtual box is installed or not."
if [ -z /usr/bin/virtualbox -a -z /usr/local/bin/virtualbox ]; then
    echo "VirtualBox is not installed. Proceeding to install virtual box."
    yum install https://download.virtualbox.org/virtualbox/6.0.4/VirtualBox-6.0-6.0.4_128413_el7-1.x86_64.rpm -y
    #If above url does not work visit - https://www.virtualbox.org/wiki/Linux_Downloads to get the updated URL
    if [ -z /usr/bin/virtualbox -a -z /usr/local/bin/virtualbox ]; then
        echo "Failed to Install virtualbox. Please install virtual box manually. Visit https://www.virtualbox.org/wiki/Linux_Downloads for steps. Exiting...."
        exit 1
    else
        echo "Successfully Installed virtualbox. Proceeding to next step."
    fi
else
    echo "VirtualBox is already installed. Proceeding to next step."
fi
echo "=============2. kubectl============="
echo "Checking if kubectl is installed or not."
if [ -z /usr/bin/kubectl -a -z /usr/local/bin/kubectl ]; then
    echo "kubectl is not installed. Proceeding to install kubectl."
    cp scripts/kubernetes.repo /etc/yum.repos.d/kubernetes.repo
    yum install kubectl -y
    if [ -z /usr/bin/kubectl -a -z /usr/local/bin/kubectl ]; then
        echo "Failed to install kubectl. Please install kubectl manually. Visit https://kubernetes.io/docs/tasks/tools/install-kubectl/ for detailed steps. Exiting..."
        exit 1
    else
        echo "Successfully installed kubectl. Proceeding to next step."
    fi
else
    echo "kubectl is already installed. Proceeding to next step."
fi
echo "=============3. minikube============="
echo "Checking if minikube is installed or not."
if [ -z /usr/bin/minikube -a -z /usr/local/bin/minikube ]; then
    echo "Minikube is not installed. Proceeding to install minikube"
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
    cp minikube /usr/local/bin && rm minikube
    if [ -z /usr/bin/minikube -a -z /usr/local/bin/minikube ]; then
        echo "Failed to install minikube. Please install minikube manually. Refer https://kubernetes.io/docs/tasks/tools/install-minikube/ for more details. Exiting.."
        exit 1
    else
        echo "Successfully Installed minikube. Minikube is now ready to use"
    fi
else
    echo "Minikube is already installed and ready to use."
fi
echo "=============4. Initiating minikube============="
echo "Checking if minikube is up and running"
minikubeStatus=`minikube status | grep host | awk '{print $2}'`
if [ "$minikubeStatus" == "Running" ]; then
    echo "Minikube is up and running. Checking for kubectl now!!!"
    kubectlStatus=`minikube status | grep kubectl | awk '{print $2,$3}'`
    if [ "$kubectlStatus" == "Correctly Configured:" ]; then
        echo "kubectl is up and running. Minikube is now ready to start deployments"
    else
        echo "Issues with kubectl. Please check if kubectl is correctly configured or now. Exiting.."
        exit 1
    fi
else
    echo "Minikube is not running. Will start minikube now."
    minikube start
    sleep 10
    minikubeStatus=`minikube status | grep host | awk '{print $2}'`
    if [ "$minikubeStatus" == "Running" ]; then
        echo "Minikube is up and running. Checking for kubectl now!!!"
        kubectlStatus=`minikube status | grep kubectl | awk '{print $2,$3}'`
        if [ "$kubectlStatus" == "Correctly Configured:" ]; then
            echo "kubectl is up and running. Minikube is now ready to start deployments"
        else
            echo "Issues with kubectl. Please check if kubectl is correctly configured or now. Exiting.."
            exit 1
        fi
    else
        echo "Failed to start minikube. Please check whether minikube is installed correctly or now. Try removing and re-installing minikube. Exiting.."
        exit 1
    fi
fi