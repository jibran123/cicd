#!/bin/sh
newVersion=`wget -q https://registry.hub.docker.com/v1/repositories/"$1"/"$2"/tags -O - | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n' | awk -F: '{print $3}' | tail -n 1`
sed "s/newTag/$newVersion/g" k8-manifests/"$2"/"$2.yaml" > k8-manifests/"$2"/"$2_new.yaml"
ls k8-manifests/"$2"/"$2_new.yaml"
exitCode=`echo $?`
if [[ $exitCode -eq 0 ]]; then
    rm -f k8-manifests/"$2"/"$2.yaml"
    mv k8-manifests/"$2"/"$2_new.yaml" k8-manifests/"$2"/"$2.yaml"
else
    echo "Failed to update the correct version in manifest"
    exit 1
fi