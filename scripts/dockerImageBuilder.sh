#!/bin/sh
checkLogin=`docker login -u "$1" -p "$2"`
if [[ "$checkLogin" =~ "Login Succeeded" ]]; then
    echo "Successfully Logged into Docker hub account"
    wget https://registry.hub.docker.com/v1/repositories/"$1/$3"/tags
    exitCode=`echo $?`
    if [ "$exitCode" -ne 0 ]; then
        echo "$3 image repository does not exists in Dockerhub account for user $1. Creating a new repository now...."
        if [ "$4" == "yes" ]; then
            initVersion="1.0"
            dockerBuild=`docker build docker/"$3"/ -t "$1"/"$3":"$initVersion"`
            if [[ "$dockerBuild" =~ "Successfully built" ]]; then
                echo "Docker image build successfully"
                echo "Image Name - $1/$3:$initVersion"
                dockerPush=`docker push "$1"/"$3":"$initVersion"`
                if [ `echo "$?"` -eq 0 ]; then
                    echo "Successfully Pushed the docker image to dockerhub. Now ready for Kubernetes Deployment"
                else
                    echo "Failed to push image to remote. Please try again"
                    exit 1
                fi
            else
                echo "Failed to create docker image. Please try again"
                exit 1
            fi
        else
            initVersion="0.1"
            dockerBuild=`docker build docker/"$3"/ -t "$1"/"$3":"$initVersion"`
            if [[ "$dockerBuild" =~ "Successfully built" ]]; then
                echo "Docker image build successfully"
                echo "Image Name - $1/$3:$initVersion"
                dockerPush=`docker push "$1"/"$3":"$initVersion"`
                if [ `echo "$?"` -eq 0 ]; then
                    echo "Successfully Pushed the docker image to dockerhub. Now ready for Kubernetes Deployment"
                else
                    echo "Failed to push image to remote. Please try again"
                    exit 1
                fi
            else
                echo "Failed to create docker image. Please try again"
                exit 1
            fi
        fi
    else
        echo "Found Docker image in registry. Pulling all tags now!!"
        wget -q https://registry.hub.docker.com/v1/repositories/"$1/$3"/tags -O - | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n' | awk -F: '{print $3}' > /tmp/allVersions.txt
        latestVersion=`tail -n 1 /tmp/allVersions.txt`
        if [ "$4" == "yes" ]; then
            echo "Incrementing the major version for the docker image"
            tempNewVersion=`printf "%.0f" "$latestVersion"`
            tempCompare=`echo "$tempNewVersion > $latestVersion" | bc`
            newVersion=
            if [ "$tempCompare" -eq 1 ]; then
                newVersion="$tempNewVersion"
            else
                newVersion=`expr $tempNewVersion + 1`
            fi
            dockerBuild=`docker build -t "$1"/"$3":"$newVersion".0 docker/"$3"/`
            if [[ "$dockerBuild" =~ "Successfully built" ]]; then
                echo "Docker image build successfully"
                echo "Image Name - $1/$3:$newVersion.0"
                dockerPush=`docker push "$1"/"$3":"$newVersion".0`
                if [ `echo "$?"` -eq 0 ]; then
                    echo "Successfully Pushed the docker image to dockerhub. Now ready for Kubernetes Deployment"
                else
                    echo "Failed to push image to docker hub. Please try again"
                    exit 1
                fi
            else
                echo "Failed to create docker image. Please try again"
                exit 1
            fi
        else
            currentVersion=$latestVersion
            preDecimalNumber="${currentVersion%%.*}"
            dotPos="$(( ${#preDecimalNumber} + 1 ))"
            postDecimalNumber=${currentVersion:$dotPos}
            newVersionPostDecimal=`expr $postDecimalNumber + 1`
            newVersion="$preDecimalNumber.$newVersionPostDecimal"
            dockerBuild=`docker build -t "$1"/"$3":"$newVersion" docker/"$3"/`
            if [[ "$dockerBuild" =~ "Successfully built" ]]; then
                echo "Docker image build successfully"
                echo "Image Name - $1/$3:$newVersion"
                dockerPush=`docker push "$1"/"$3":"$newVersion"`
                if [ `echo "$?"` -eq 0 ]; then
                    echo "Successfully Pushed the docker image to dockerhub. Now ready for Kubernetes Deployment"
                else
                    echo "Failed to push image to remote. Please try again"
                    exit 1
                fi
            else
                echo "Failed to create docker image. Please try again"
                exit 1
            fi
        fi
        rm -f /tmp/allVersions.txt
        rm -f tags*
    fi
else
    echo "Login Failed. Exitting NOw..."
    exit 1
fi
