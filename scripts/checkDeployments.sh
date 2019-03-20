#!/bin/sh
namespace=$1
kubectl get pods -n $namespace | awk 'FNR > 1 {print $0}' > /tmp/kubePodsOutput
flag=$false
while read pods
do
    podStatus=`echo $pods | awk '{print $3}'`
    podName=`echo $pods | awk '{print $1}'`
    if [ $podStatus == "Running" -o $podStatus == "Completed" ]
    then
        echo "pod '$podName' is in desired state"
    else
        echo "$podName is in failed state. execute \"kubectl logs $podName -n $namespace\" to troubleshoot"
        flag=$true
    fi
done < /tmp/kubePodsOutput
rm -f /tmp/kubePodsOutput
if [ $flag ]; then
    exit 1
fi