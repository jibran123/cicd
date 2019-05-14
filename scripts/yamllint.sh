#!/bin/sh
if [ -f /usr/bin/yamllint ]; then
    echo "yamllint is already installed. Proceeding to test the k8 manifests"
else
    yumSearch=`yum list | grep yamllint`
    if [ -z "$yumSearch" ]; then
        echo "yamllint package not available in yum repository. Installing epel repository!!!!"
        yum install epel-release -y
        echo "epel repository installed. Proceeding to install yamllint"
    else
        echo "Found yamllint in yum repository proceeding to install yamllint"
    fi
    yum install yamllint -y
    yaml=`yamllint --version`
    if [ -z "$yaml" ]; then
        echo "Failed to install yamllint"
        exit 1
    else
        echo "Successfully Installed yamllint with version - $yaml"
    fi
fi
yamlint=`yamllint k8-manifests/"$1"/`
if [ -z "$yamllint" ]; then
    echo "All k8 manifests have passed yamllint tests"
else
    echo "One or more manifest have failed yamllint test cases please check logs for more details"
    exit 1
fi
