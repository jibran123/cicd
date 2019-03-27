#!/bin/sh
checkLogin=`docker login -u "$1" -p "$2"`
if [[ "$checkLogin" =~ "Login Succeeded" ]]; then
    echo "Successfully Logged into Docker hub account"
    wget https://registry.hub.docker.com/v1/repositories/"$1/$3"/tags
    exitCode=`echo $?`
    echo "exit code $exitCode"
    if [ "$exitCode" -ne 0 ]; then
        echo "$3 image repository does not exists in Dockerhub account for user $1. Creating a new repository now...."
        if [ "$4" == "yes" ]; then
            initVersion="1.0"
            docker build -t "$1/$3:$initVersion docker/$3"
            docker push "$1/$3:$initVersion"
        else
            initVersion="0.1"
            docker build -t "$1/$3:$initVersion docker/$3"
            docker push "$1/$3:$initVersion"
        fi
    else
        echo "Found Docker image in registry. Pulling all tags now!!"
        wget -q https://registry.hub.docker.com/v1/repositories/"$1/$3"/tags -O - | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n' | awk -F: '{print $3}' > /tmp/allVersions.txt
        latestVersion=`tail -n 1 /tmp/allVersions.txt`
        olderVersion=`tail -n 2 /tmp/allVersions.txt | head -n 1`
        if [ "$4" == "yes" ]; then
            echo "Incrementing the major version for the docker image"
            tempNewVersion=`printf "%.0f" "$latestVersion"`
            tempCompare=`echo "$tempNewVersion > $latestVersion" | bc`
            if [ "$tempCompare" -eq 1 ]; then
                newVersion="$tempNewVersion"
                docker build -t "$1/$3:$newVersion.0 docker/$3"
                docker push "push $1/$3:$newVersion.0"
            else
                newVersion=`expr $tempNewVersion + 1`
                docker build -t "$1/$3:$newVersion.0 docker/$3"
                docker push "push $1/$3:$newVersion.0"
            fi
        else
            newVersion=`echo "$latestVersion + ($latestVersion - $olderVersion)" | bc`
            compare=`echo "$newVersion < 1" | bc`
            if [ "$compare" -eq 1 ]; then
                newVersion=`echo "0$newVersion"`
                docker build -t "$1/$3:$newVersion.0 docker/$3"
                docker push "push $1/$3:$newVersion.0"
            else
                docker build -t "$1/$3:$newVersion.0 docker/$3"
                docker push "push $1/$3:$newVersion.0"
            fi
        fi
        rm -f /tmp/allVersions.txt
    fi
else
    echo "Login Failed. Exitting NOw..."
fi
