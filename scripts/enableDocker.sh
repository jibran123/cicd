#!/bin/sh
echo "Starting with system configuration."
echo "This script will ensure that docker is installed and running."
echo "=======================1. Checking if docker is intalled.==================="
if [ -f /usr/bin/docker -o -f /usr/local/bin/docker ]; then
    echo "Docker is installed. Proceeding to check if docker.service is running or not"
else
    echo "Docker is not Installed in the system. Will attempt to install it now.."
    yum install epel-release docker -y
    if [ -f /usr/bin/docker -o -f /usr/local/bin/docker ]; then
        echo "Docker is installed. Proceeding to check if docker.service is running or not"
    else
        echo "Failed to install docker. Please install docker manually and start again.."
    fi
fi
echo "=======================2. Checking if docker is running.==================="
dockerServiceStatus=`systemctl status docker.service | grep Active | awk '{print $2}'`
if [ "$dockerServiceStatus" == "active" ]; then
    echo "Docker is already up and running. Proceeding to check minikube now..."
else
    systemctl start docker.service
    sleep 10s
    dockerServiceStatusCheck=`systemctl status docker.service | grep Active | awk '{print $2}'`
    if [ "$dockerServiceStatusCheck" == "active" ]; then
        echo "Docker is now up and running. Proceeding to check minikube now..."
    else
        echo "Failed to start/install docker. Please install and start docker manually and try again"
    fi
fi